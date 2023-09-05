import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/user_model.dart';
import 'package:kivicare_flutter/network/network_utils.dart';
// ignore: unused_import
import 'package:kivicare_flutter/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

//region Google Calender

Future<UserModel> getConfigurationAPI() async {
  UserModel value = UserModel.fromJson(await (handleResponse(await buildHttpResponse('kivicare/api/v1/user/get-configuration'))));

  appStore.setUserProEnabled(value.isKivicareProOnName.validate(), initialize: true);
  appStore.setGlobalDateFormat(value.globalDateFormat.validate(), initialize: true);
  appStore.setGlobalUTC(value.utc.validate());

  appStore.setRestrictAppointmentPost(value.restrictAppointment!.post!.validate(value: 0), initialize: true);
  appStore.setRestrictAppointmentPre(value.restrictAppointment!.pre!.validate(value: 365).toInt(), initialize: true);
  return value;
}

//endregion
