import 'dart:convert';
import 'dart:io';

import 'package:collection/src/iterable_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kivicare_flutter/components/loader_widget.dart';
import 'package:kivicare_flutter/components/role_widget.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/network/appointment_repository.dart';
import 'package:kivicare_flutter/screens/doctor/fragments/appointment_fragment.dart';
import 'package:kivicare_flutter/screens/patient/screens/web_view_payment_screen.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:kivicare_flutter/utils/constants.dart';
import 'package:kivicare_flutter/utils/extensions/date_extensions.dart';
import 'package:kivicare_flutter/utils/extensions/string_extensions.dart';
import 'package:kivicare_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class ConfirmAppointmentScreen extends StatefulWidget {
  final int? appointmentId;

  ConfirmAppointmentScreen({this.appointmentId});

  @override
  _ConfirmAppointmentScreenState createState() => _ConfirmAppointmentScreenState();
}

class _ConfirmAppointmentScreenState extends State<ConfirmAppointmentScreen> {
  bool isUpdate = false;
  bool mIsConfirmed = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    appStore.setLoading(false);
    isUpdate = widget.appointmentId != null;
  }

  void saveAppointment() {
    Map<String, dynamic> req = {
      "appointment_start_date": appointmentAppStore.selectedAppointmentDate.getFormattedDate(SAVE_DATE_FORMAT),
      "appointment_start_time": appointmentAppStore.mSelectedTime.validate().trim(),
      "doctor_id": appointmentAppStore.mDoctorSelected?.iD.validate().toString().trim(),
      "description": appointmentAppStore.mDescription.validate().trim(),
      "status": "1",
    };
    if (isUpdate) {
      req.putIfAbsent('id', () => widget.appointmentId);
    }

    if (isDoctor() || isReceptionist()) {
      req.putIfAbsent("patient_id", () => appointmentAppStore.mPatientId);
    } else {
      req.putIfAbsent("patient_id", () => userStore.userId.toString());
    }

    if (isProEnabled() && appointmentAppStore.mClinicSelected != null) {
      req.putIfAbsent("clinic_id", () => appointmentAppStore.mClinicSelected!.id.validate());
    } else {
      req.putIfAbsent("clinic_id", () => "${userStore.userClinicId}");
    }

    if (multiSelectStore.selectedService.isNotEmpty) {
      multiSelectStore.selectedService.forEachIndexed((index, element) {
        req.putIfAbsent("visit_type[$index]", () => multiSelectStore.selectedService[index].id.validate());
      });
    }

    log("request = ${jsonEncode(req)}");

    saveAppointmentApi(data: req, files: appointmentAppStore.reportList.map((element) => File(element.path.validate())).toList()).then((value) async {
      if (!value.isAppointmentAlreadyBooked.validate()) {
        if (isUpdate) {
          redirectionCase(context, message: value.message.validate(), finishCount: 2).then((value) {});
        } else {
          if (value.woocommerceRedirect != null) {
            WebViewPaymentScreen(checkoutUrl: value.woocommerceRedirect.validate()).launch(context).then((value) {
              appointmentStreamController.add(true);
            });
          } else {
            redirectionCase(context, message: value.message.validate()).then((value) {});
          }
        }
      } else {
        toast(value.message.validate());
      }
      appStore.setLoading(false);
    }).catchError((error) {
      appStore.setLoading(false);
      appointmentAppStore.clearAll();

      if (isPatient()) {
        for (int i = 0; i < 4; i++) finish(context, true);
      } else {
        for (int i = 0; i < 3; i++) finish(context, true);
      }
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: context.width(),
      child: AnimatedScrollView(
        mainAxisSize: MainAxisSize.min,
        listAnimationType: ListAnimationType.None,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: Icon(Icons.clear).onTap(
              () {
                finish(context, false);
                appStore.setLoading(false);
              },
            ),
          ),
          8.height,
          Image.asset(ic_confirm_appointment, height: 70, width: 70).center(),
          26.height,
          Text("${isDoctor() ? 'Dr. ${userStore.firstName}' : '${userStore.firstName}'}, ${locale.lblAppointmentConfirmation}", style: primaryTextStyle(size: 18), textAlign: TextAlign.center),
          16.height,
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(FontAwesomeIcons.calendarCheck, size: 20),
              8.width,
              Text(appointmentAppStore.selectedAppointmentDate.getFormattedDate(CONFIRM_APPOINTMENT_FORMAT), style: boldTextStyle(size: 20)).flexible(),
            ],
          ),
          20.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(appointmentAppStore.mSelectedTime.validate(), style: boldTextStyle(size: 20), textAlign: TextAlign.end).expand(flex: 3),
              VerticalDivider(color: context.dividerColor, thickness: 2).withHeight(20).expand(flex: 1),
              if (isDoctor() || isReceptionist())
                Text("${appointmentAppStore.mPatientSelected?.validate().capitalizeEachWord()}", style: boldTextStyle(size: 20), textAlign: TextAlign.start).expand(flex: 3)
              else
                Text("${appointmentAppStore.mDoctorSelected?.displayName.validate().split(' ').first.capitalizeEachWord().prefixText(value: 'Dr. ')}",
                        style: boldTextStyle(size: 20), textAlign: TextAlign.start)
                    .expand(flex: 3)
            ],
          ),
          26.height,
          RoleWidget(
            isShowPatient: isProEnabled(),
            child: RichTextWidget(
              list: [
                TextSpan(text: locale.lblClinic, style: primaryTextStyle()),
                TextSpan(text: ": ", style: primaryTextStyle()),
                TextSpan(text: appointmentAppStore.mClinicSelected?.name.validate(), style: boldTextStyle()),
              ],
            ),
          ),
          16.height,
          RoleWidget(
            isShowPatient: appointmentAppStore.mDescription != null,
            isShowReceptionist: appointmentAppStore.mDescription != null,
            isShowDoctor: appointmentAppStore.mDescription != null,
            child: RichTextWidget(
              textAlign: TextAlign.start,
              list: [
                TextSpan(text: locale.lblDesc, style: primaryTextStyle()),
                TextSpan(text: ": ", style: primaryTextStyle()),
                TextSpan(text: appointmentAppStore.mDescription, style: boldTextStyle()),
              ],
            ),
          ),
          32.height,
          Observer(
            builder: (_) => AppButton(
              width: context.width(),
              text: locale.lblConfirmAppointment,
              textStyle: boldTextStyle(color: Colors.white),
              onTap: saveAppointment,
            ).visible(
              !appStore.isLoading,
              defaultWidget: LoaderWidget(size: loaderSize),
            ),
          ),
        ],
      ),
    );
  }
}
