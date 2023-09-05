import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:kivicare_flutter/components/empty_error_state_component.dart';
import 'package:kivicare_flutter/components/internet_connectivity_widget.dart';
import 'package:kivicare_flutter/components/loader_widget.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/holiday_model.dart';
import 'package:kivicare_flutter/network/holiday_repository.dart';
import 'package:kivicare_flutter/screens/doctor/screens/holiday/add_holiday_screen.dart';
import 'package:kivicare_flutter/screens/doctor/screens/holiday/components/holiday_widget.dart';
import 'package:kivicare_flutter/screens/shimmer/screen/holiday_shimmer_screen.dart';
import 'package:kivicare_flutter/utils/app_common.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:kivicare_flutter/utils/constants.dart';
import 'package:kivicare_flutter/utils/extensions/string_extensions.dart';
import 'package:kivicare_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class HolidayScreen extends StatefulWidget {
  @override
  _HolidayScreenState createState() => _HolidayScreenState();
}

class _HolidayScreenState extends State<HolidayScreen> {
  Future<HolidayModel>? future;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init({bool showLoader = false}) async {
    if (showLoader) {
      appStore.setLoading(true);
    }
    future = getHolidayResponseAPI().whenComplete(() {
      appStore.setLoading(false);
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      throw e;
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant HolidayScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(locale.lblHolidays, textColor: Colors.white, systemUiOverlayStyle: defaultSystemUiOverlayStyle(context)),
      body: InternetConnectivityWidget(
        retryCallback: () async {
          await 2.seconds.delay;
          setState(() {});
        },
        child: Stack(
          children: [
            SnapHelperWidget<HolidayModel>(
              future: future,
              loadingWidget: HolidayShimmerScreen(),
              errorWidget: ErrorStateWidget(),
              errorBuilder: (error) {
                return NoDataWidget(
                  imageWidget: Image.asset(ic_somethingWentWrong, height: 180, width: 180),
                  title: locale.lblSomethingWentWrong,
                ).center();
              },
              onSuccess: (snap) {
                if (snap.holidayData.validate().isEmpty)
                  return EmptyStateWidget(
                    emptyWidgetTitle: locale.lblNo + " " + locale.lblHolidays + " " + locale.lblSchedule.suffixText(value: 'd'),
                  ).center();
                return AnimatedScrollView(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 80),
                  disposeScrollController: true,
                  listAnimationType: ListAnimationType.None,
                  physics: AlwaysScrollableScrollPhysics(),
                  slideConfiguration: SlideConfiguration(verticalOffset: 400),
                  onSwipeRefresh: () async {
                    init();
                    return await 2.seconds.delay;
                  },
                  children: [
                    Text('${locale.lblNote} : ${locale.lblHolidayTapMsg}', style: secondaryTextStyle(size: 10, color: appSecondaryColor)),
                    8.height,
                    AnimatedWrap(
                      spacing: 16,
                      runSpacing: 16,
                      listAnimationType: listAnimationType,
                      children: snap.holidayData.validate().map(
                        (holidayData) {
                          return HolidayWidget(data: holidayData).onTap(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            () async {
                              bool isPending = getDateDifference(holidayData.holidayEndDate.validate()) < 0;

                              List<DateTime> dates = getDatesBetweenTwoDates(
                                  DateFormat(SAVE_DATE_FORMAT).parse(holidayData.holidayStartDate.validate()), DateFormat(SAVE_DATE_FORMAT).parse(holidayData.holidayEndDate.validate()));
                              bool isOnLeave = dates.contains(DateFormat(SAVE_DATE_FORMAT).parse(DateTime.now().toString()));

                              if (isOnLeave || !isPending) {
                                toast(locale.lblEditHolidayRestriction);
                              }

                              if (isPending && !isOnLeave)
                                await AddHolidayScreen(holidayData: holidayData).launch(context, pageRouteAnimation: PageRouteAnimation.Slide).then((value) {
                                  init(showLoader: true);
                                });
                            },
                          );
                        },
                      ).toList(),
                    ),
                  ],
                );
              },
            ),
            Observer(
              builder: (context) => LoaderWidget().center().visible(appStore.isLoading),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          if (appStore.isConnectedToInternet)
            await AddHolidayScreen().launch(context, pageRouteAnimation: PageRouteAnimation.Slide).then((value) {
              if (value != null) {
                if (value) {
                  init(showLoader: true);
                }
              }
            });
          else {
            toast(locale.lblNoInternetMsg);
          }
        },
      ),
    );
  }
}
