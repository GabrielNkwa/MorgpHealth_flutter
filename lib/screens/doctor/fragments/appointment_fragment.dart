// ignore_for_file: unused_import

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:intl/intl.dart';
import 'package:kivicare_flutter/components/body_widget.dart';
import 'package:kivicare_flutter/components/empty_error_state_component.dart';
import 'package:kivicare_flutter/components/no_data_found_widget.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/upcoming_appointment_model.dart';
import 'package:kivicare_flutter/network/appointment_repository.dart';
import 'package:kivicare_flutter/screens/appointment/appointment_functions.dart';
import 'package:kivicare_flutter/screens/doctor/components/appointment_fragment_appointment_component.dart';
import 'package:kivicare_flutter/screens/shimmer/components/appointment_shimmer_component.dart';
import 'package:kivicare_flutter/utils/cached_value.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:kivicare_flutter/utils/constants.dart';
import 'package:kivicare_flutter/utils/extensions/date_extensions.dart';
import 'package:kivicare_flutter/utils/images.dart';
import 'package:kivicare_flutter/utils/widgets/calender/date_utils.dart';
import 'package:kivicare_flutter/utils/widgets/calender/flutter_clean_calendar.dart';
import 'package:nb_utils/nb_utils.dart';

StreamController appointmentStreamController = StreamController.broadcast();

class AppointmentFragment extends StatefulWidget {
  @override
  State<AppointmentFragment> createState() => _AppointmentFragmentState();
}

class _AppointmentFragmentState extends State<AppointmentFragment> {
  Map<DateTime, List> _events = {};

  Future<List<UpcomingAppointmentModel>>? future;

  List<UpcomingAppointmentModel> appointmentList = [];

  int page = 1;

  bool isLastPage = false;
  bool isRangeSelected = false;

  String startDate = DateTime(DateTime.now().year, DateTime.now().month, 1).getFormattedDate(SAVE_DATE_FORMAT);
  String endDate = DateTime(DateTime.now().year, DateTime.now().month, Utils.lastDayOfMonth(DateTime.now()).day).getFormattedDate(SAVE_DATE_FORMAT);

  DateTime selectedDate = DateTime.now();

  StreamSubscription? updateAppointmentApi;

  @override
  void initState() {
    super.initState();

    updateAppointmentApi = appointmentStreamController.stream.listen((streamData) {
      page = 1;
      init(
        todayDate: selectedDate.getFormattedDate(SAVE_DATE_FORMAT),
        startDate: null,
        endDate: null,
      );
    });
    setState(() {
      isRangeSelected = true;
    });
    init(startDate: startDate, endDate: endDate, isFirst: true);
  }

  Future<void> init({String? todayDate, String? startDate, String? endDate, bool isFirst = false}) async {
    appStore.setLoading(true);
    future = getAppointment(
      pages: page,
      perPage: 20,
      appointmentList: appointmentList,
      lastPageCallback: (b) => isLastPage = b,
      todayDate: todayDate,
      startDate: startDate,
      endDate: endDate,
    ).then((value) {
      checkOnSuccess(value);
      setState(() {});
      appStore.setLoading(false);
      return value;
    }).catchError((e) {
      appStore.setLoading(false);
      throw e;
    });
  }

  Future<void> checkOnSuccess(List<UpcomingAppointmentModel> snap) async {
    if (isRangeSelected && (snap.isNotEmpty)) {
      _events.clear();
      snap.validate().forEachIndexed((element, index) {
        DateTime date = DateFormat(SAVE_DATE_FORMAT).parse(element.appointmentGlobalStartDate.validate());
        _events.addAll({
          DateTime(date.year, date.month, date.day): [{}]
        });
      });
      setState(() {
        isRangeSelected = false;
      });
    }
  }

  Future<void> onSwipeRefresh({bool isFirst = false}) async {
    setState(() {
      isRangeSelected = false;
      page = 1;
    });
    appStore.setLoading(true);
    init(
      todayDate: selectedDate.getFormattedDate(SAVE_DATE_FORMAT),
      startDate: null,
      endDate: null,
    );
    return await 1.seconds.delay;
  }

  void showData(DateTime dateTime) async {
    appStore.setLoading(true);
    if (isRangeSelected) {
      appStore.setLoading(false);
      return;
    }
    800.milliseconds.delay;
    selectedDate = dateTime;
    setState(() {});
    init(
      todayDate: dateTime.getFormattedDate(SAVE_DATE_FORMAT),
      startDate: null,
      endDate: null,
    );
  }

  void onNextPage() {
    if (!isLastPage) {
      appStore.setLoading(true);
      page++;
      init(
        todayDate: selectedDate.getFormattedDate(SAVE_DATE_FORMAT),
        startDate: null,
        endDate: null,
      );
    }
  }

  Future<void> onRangeSelected(Range range) async {
    appStore.setLoading(true);
    isRangeSelected = true;
    page = 1;
    init(
      todayDate: null,
      startDate: range.from.getFormattedDate(SAVE_DATE_FORMAT),
      endDate: range.to.getFormattedDate(SAVE_DATE_FORMAT),
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    if (updateAppointmentApi != null) {
      updateAppointmentApi!.cancel().then((value) {
        log("============== Stream Cancelled ==============");
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedScrollView(
        padding: EdgeInsets.only(bottom: 60),
        onSwipeRefresh: onSwipeRefresh,
        onNextPage: onNextPage,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(locale.lblTodaySAppointments, style: boldTextStyle(size: fragmentTextSize)),
                  8.width,
                  Marquee(child: Text("(${selectedDate.getDateInString(format: CONFIRM_APPOINTMENT_FORMAT)})", style: boldTextStyle(size: 14, color: context.primaryColor))).expand(),
                ],
              ),
              4.height,
              Text(locale.lblSwipeMassage, style: secondaryTextStyle(size: 10, color: appSecondaryColor)),
            ],
          ).paddingOnly(top: 16, right: 16, left: 16),
          Container(
            margin: EdgeInsets.all(16),
            decoration: boxDecorationWithRoundedCorners(backgroundColor: context.cardColor),
            child: CleanCalendar(
              startOnMonday: true,
              weekDays: [locale.lblMon, locale.lblTue, locale.lblWed, locale.lblThu, locale.lblFri, locale.lblSat, locale.lblSun],
              events: _events,
              onDateSelected: (e) {
                showData(e);
              },
              initialDate: selectedDate,
              onRangeSelected: (Range range) {
                onRangeSelected(range);
              },
              isExpandable: true,
              locale: appStore.selectedLanguage,
              isExpanded: false,
              eventColor: appSecondaryColor,
              selectedColor: primaryColor,
              todayColor: primaryColor,
              bottomBarArrowColor: context.iconColor,
              dayOfWeekStyle: TextStyle(color: appStore.isDarkModeOn ? Colors.white : Colors.black, fontWeight: FontWeight.w800, fontSize: 11),
            ),
          ),
          SnapHelperWidget<List<UpcomingAppointmentModel>>(
            initialData: cachedDoctorAppointment,
            future: future,
            errorBuilder: (error) {
              return NoDataWidget(
                imageWidget: Image.asset(
                  ic_somethingWentWrong,
                  height: 180,
                  width: 180,
                ),
                title: error.toString(),
              );
            },
            errorWidget: ErrorStateWidget(),
            loadingWidget: AnimatedWrap(
              listAnimationType: ListAnimationType.None,
              runSpacing: 16,
              spacing: 16,
              children: [
                AppointmentShimmerComponent(),
                AppointmentShimmerComponent(),
                AppointmentShimmerComponent(),
              ],
            ).paddingSymmetric(horizontal: 16),
            onSuccess: (snap) {
              return AppointmentFragmentAppointmentComponent(
                data: snap,
                refreshCallForRefresh: () {
                  onSwipeRefresh(isFirst: true);
                },
              ).visible(
                snap.isNotEmpty,
                defaultWidget: Observer(
                  builder: (context) {
                    if (snap.isEmpty && !appStore.isLoading)
                      return NoDataFoundWidget(
                              text: selectedDate.getFormattedDate(SAVE_DATE_FORMAT) == DateTime.now().getFormattedDate(SAVE_DATE_FORMAT)
                                  ? locale.lblNoAppointmentForToday
                                  : locale.lblNoAppointmentForThisDay)
                          .center();
                    return AnimatedWrap(
                      listAnimationType: ListAnimationType.None,
                      runSpacing: 16,
                      spacing: 16,
                      children: [
                        AppointmentShimmerComponent(),
                        AppointmentShimmerComponent(),
                        AppointmentShimmerComponent(),
                      ],
                    ).paddingSymmetric(horizontal: 16).visible(appStore.isLoading && snap.isEmpty);
                  },
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          if (appStore.isConnectedToInternet) {
            appointmentWidgetNavigation(context);
          } else {
            toast(locale.lblNoInternetMsg);
          }
        },
      ),
    );
  }
}
