import 'package:flutter/cupertino.dart';
import 'package:kivicare_flutter/components/step_progress_indicator.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/upcoming_appointment_model.dart';
import 'package:kivicare_flutter/screens/appointment/screen/step1_clinic_selection_screen.dart';
import 'package:kivicare_flutter/screens/appointment/screen/step2_doctor_selection_screen.dart';
import 'package:kivicare_flutter/screens/appointment/screen/step3_final_selection_screen.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:kivicare_flutter/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

Widget stepCountWidget({String? name, int? totalCount, int? currentCount, double percentage = 0.33}) {
  return Row(
    children: [
      Text(name.validate(), style: boldTextStyle(size: titleTextSize)).expand(),
      16.width,
      StepProgressIndicator(stepTxt: "$currentCount/$totalCount", percentage: percentage),
    ],
  );
}

Future<void> appointmentWidgetNavigation(BuildContext context, {UpcomingAppointmentModel? data}) async {
  if (data == null) {
    if (isDoctor()) {
      if (isProEnabled()) {
        Step1ClinicSelectionScreen().launch(context);
      } else {
        Step3FinalSelectionScreen(
          clinicId: userStore.userClinicId.toInt(),
        ).launch(context).then((value) {});
      }
    } else if (isReceptionist()) {
      Step2DoctorSelectionScreen(
        clinicId: userStore.userClinicId.toInt(),
        isForAppointment: true,
      ).launch(context);
    } else if (isPatient()) {
      Step1ClinicSelectionScreen().launch(context);
    }
  } else {
    Step3FinalSelectionScreen(
      clinicId: data.clinicId.toInt(),
      doctorId: data.doctorId.validate().toInt(),
      data: data,
    ).launch(context).then((value) {});
  }
}

Future<void> doctorNavigation(BuildContext context, {int? clinicId, int? doctorId}) async {
  Step3FinalSelectionScreen(
    clinicId: clinicId,
    doctorId: doctorId,
  ).launch(context).then((value) {});
}

Future<void> clinicNavigation(BuildContext context, {int? clinicId}) async {
  if (isDoctor()) {
    if (isProEnabled()) {
      Step3FinalSelectionScreen(
        clinicId: clinicId,
        doctorId: userStore.userId.validate(),
      ).launch(context);
    }
  } else if (isPatient()) {
    Step2DoctorSelectionScreen(
      clinicId: clinicId,
      isForAppointment: true,
    ).launch(context);
  }
}
