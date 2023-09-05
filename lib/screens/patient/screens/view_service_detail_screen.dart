import 'package:flutter/material.dart';
import 'package:kivicare_flutter/components/cached_image_widget.dart';
// ignore: unused_import
import 'package:kivicare_flutter/components/status_widget.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/service_duration_model.dart';
import 'package:kivicare_flutter/model/service_model.dart';
import 'package:kivicare_flutter/model/static_data_model.dart';
import 'package:kivicare_flutter/screens/receptionist/screens/doctor/doctor_details_screen.dart';
import 'package:kivicare_flutter/utils/app_common.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:kivicare_flutter/utils/extensions/string_extensions.dart';
import 'package:kivicare_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class ViewServiceDetailScreen extends StatefulWidget {
  final ServiceData serviceData;

  ViewServiceDetailScreen({required this.serviceData});

  @override
  State<ViewServiceDetailScreen> createState() => _ViewServiceDetailScreenState();
}

class _ViewServiceDetailScreenState extends State<ViewServiceDetailScreen> {
  List<DurationModel> durationList = getServiceDuration();
  Future<StaticDataModel>? future;

  StaticData? category;

  @override
  void initState() {
    super.initState();
    setStatusBarColor(appPrimaryColor);
    init();
  }

  void init() {}

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        systemUiOverlayStyle: defaultSystemUiOverlayStyle(context),
        widget.serviceData.name.validate(),
        textColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 60, left: 16, right: 16, top: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            16.height,
            RichText(
              text: TextSpan(children: [
                TextSpan(text: locale.lblCategory, style: primaryTextStyle()),
                TextSpan(text: " : " + widget.serviceData.type.validate().replaceAll(RegExp('[^A-Za-z]'), ' ').capitalizeEachWord(), style: boldTextStyle()),
              ]),
            ),
            16.height,
            Text(widget.serviceData.doctorList.validate().length > 1 ? locale.lblAvailableDoctors : locale.lblAvailableDoctor, style: boldTextStyle()),
            16.height,
            AnimatedWrap(
              runSpacing: 16,
              listAnimationType: listAnimationType,
              children: widget.serviceData.doctorList.validate().map((doctorData) {
                return GestureDetector(
                  onTap: () {
                    DoctorDetailScreen(doctorData: doctorData).launch(context, pageRouteAnimation: PageRouteAnimation.Fade, duration: 800.milliseconds);
                  },
                  child: Container(
                    decoration: boxDecorationDefault(color: context.cardColor),
                    child: Stack(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Dr. ' + doctorData.displayName.validate(), style: boldTextStyle(size: 14)),
                                8.height,
                                Row(
                                  children: [
                                    SettingItemWidget(
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      title: appStore.currencyPrefix.validate(value: '') + doctorData.charges.validate(value: '') + appStore.currencyPostfix.validate(value: ''),
                                      titleTextStyle: secondaryTextStyle(size: 14),
                                      leading: ic_bill.iconImage(size: 20).paddingRight(6),
                                      padding: EdgeInsets.zero,
                                      paddingAfterLeading: 4,
                                    ).expand(),
                                    if (doctorData.duration != null && doctorData.duration.validate().toInt() != 0)
                                      SettingItemWidget(
                                        splashColor: Colors.transparent,
                                        highlightColor: Colors.transparent,
                                        padding: EdgeInsets.zero,
                                        paddingAfterLeading: 4,
                                        title: durationList.where((element) => element.value == doctorData.duration.toInt()).first.label.validate(),
                                        titleTextStyle: secondaryTextStyle(size: 14),
                                        leading: ic_timer.iconImage(size: 20).paddingRight(6),
                                      ).expand(flex: 2),
                                  ],
                                ),
                                if (doctorData.isTelemed ?? false) 8.height,
                                if (doctorData.isTelemed ?? false)
                                  SettingItemWidget(
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                    padding: EdgeInsets.zero,
                                    paddingAfterLeading: 4,
                                    leading: ic_telemed.iconImage(size: 20),
                                    title: locale.lblTelemedServiceAvailable,
                                    titleTextStyle: secondaryTextStyle(size: 14),
                                  )
                              ],
                            ).expand(flex: 3),
                            if (doctorData.serviceImage.validate().isNotEmpty)
                              CachedImageWidget(
                                url: doctorData.serviceImage.validate(),
                                height: 50,
                                width: 50,
                                radius: 8,
                              ).cornerRadiusWithClipRRect(8)
                          ],
                        ).paddingSymmetric(horizontal: 16, vertical: 8),
                      ],
                    ),
                  ),
                );
              }).toList(),
            )
          ],
        ),
      ),
    );
  }
}
