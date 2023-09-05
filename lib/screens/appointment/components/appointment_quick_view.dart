import 'package:flutter/material.dart';
import 'package:kivicare_flutter/components/common_row_widget.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/upcoming_appointment_model.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:url_launcher/url_launcher_string.dart';

class AppointmentQuickView extends StatelessWidget {
  final UpcomingAppointmentModel upcomingAppointment;

  AppointmentQuickView({required this.upcomingAppointment});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width(),
      padding: EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            8.height,
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${upcomingAppointment.patientName.validate().capitalizeEachWord()}", style: boldTextStyle(color: primaryColor, size: 20)),
                24.height,
                Wrap(
                  runSpacing: 8,
                  children: [
                    if (isReceptionist())
                      SettingItemWidget(
                        padding: EdgeInsets.zero,
                        paddingAfterLeading: 8,
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        title: upcomingAppointment.doctorName.validate().capitalizeEachWord(),
                        leading: Text(locale.lblDoctor, style: secondaryTextStyle()),
                      ),
                    CommonRowWidget(title: locale.lblService, value: '${upcomingAppointment.getVisitTypesInString}'),
                    CommonRowWidget(title: locale.lblDate, value: upcomingAppointment.getAppointmentStartDate),
                    CommonRowWidget(title: locale.lblTime, value: upcomingAppointment.getDisplayAppointmentTime),
                    CommonRowWidget(title: locale.lblDesc, value: upcomingAppointment.description.validate(value: locale.lblNA)),
                  ],
                ),
                24.height,
                DottedBorderWidget(
                  color: appPrimaryColor,
                  gap: 3,
                  radius: 8,
                  strokeWidth: 1,
                  child: Container(
                    decoration: boxDecorationWithRoundedCorners(backgroundColor: context.scaffoldBackgroundColor),
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(locale.lblPRICE.capitalizeFirstLetter(), style: primaryTextStyle()),
                        10.height,
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(
                            upcomingAppointment.visitType.validate().length,
                            (index) => Row(
                              children: [
                                Text(
                                  "${upcomingAppointment.visitType![index].serviceName}",
                                  style: secondaryTextStyle(),
                                ).expand(),
                                Text(
                                  "${appStore.currencyPrefix.validate(value: appStore.currency.validate())}${upcomingAppointment.visitType![index].charges.validate()}${appStore.currencyPostfix.validate()} ",
                                  style: boldTextStyle(color: appStore.isDarkModeOn ? white : appPrimaryColor),
                                ),
                              ],
                            ).paddingSymmetric(vertical: 4),
                          ),
                        ),
                        4.height,
                        Row(
                          children: [
                            Text(locale.lblTotal, style: secondaryTextStyle()).expand(),
                            Text(
                              '${appStore.currencyPrefix.validate(value: appStore.currency.validate())}${upcomingAppointment.allServiceCharges}${appStore.currencyPostfix.validate()}',
                              style: boldTextStyle(color: appStore.isDarkModeOn ? white : appPrimaryColor),
                            ),
                          ],
                        ).paddingSymmetric(vertical: 4),
                      ],
                    ),
                  ),
                ),
                if (upcomingAppointment.appointmentReport.validate().isNotEmpty) Divider(height: 16),
                if (upcomingAppointment.appointmentReport.validate().isNotEmpty) Text(locale.lblMedicalReports, style: boldTextStyle()),
                if (upcomingAppointment.appointmentReport.validate().isNotEmpty)
                  Column(
                    children: List.generate(
                      upcomingAppointment.appointmentReport!.length,
                      (index) {
                        AppointmentReport data = upcomingAppointment.appointmentReport![index];

                        return GestureDetector(
                          onTap: () {
                            commonLaunchUrl(data.url, launchMode: LaunchMode.externalApplication);
                          },
                          child: Container(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: boxDecorationDefault(
                              color: context.cardColor,
                              boxShadow: defaultBoxShadow(spreadRadius: 0, blurRadius: 0),
                              border: Border.all(color: context.dividerColor),
                            ),
                            child: Row(
                              children: [
                                Text('${locale.lblMedicalReports} ${index + 1}', style: boldTextStyle()).expand(),
                                Icon(Icons.arrow_forward_ios_outlined, size: 16),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  )
              ],
            )
          ],
        ),
      ),
    );
  }
}
