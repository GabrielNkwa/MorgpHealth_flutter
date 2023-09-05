import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/base_response.dart';
import 'package:kivicare_flutter/model/clinic_list_model.dart';
import 'package:kivicare_flutter/model/user_model.dart';
import 'package:kivicare_flutter/network/google_repository.dart';
import 'package:kivicare_flutter/network/network_utils.dart';
import 'package:kivicare_flutter/screens/auth/screens/sign_in_screen.dart';
import 'package:kivicare_flutter/utils/cached_value.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:kivicare_flutter/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

import 'clinic_repository.dart';

Future<UserModel> loginAPI(Map<String, dynamic> req) async {
  UserModel value = UserModel.fromJson(await handleResponse(await buildHttpResponse('jwt-auth/v1/token', request: req, method: HttpMethod.POST)));
  cachedUserData = value;

  setValue(TOKEN, value.token.validate());

  appStore.setLoggedIn(true);
  if (value.clinic.validate().isNotEmpty) {
    Clinic defaultClinic = value.clinic.validate().first;
    appStore.setCurrency(defaultClinic.extra!.currencyPrefix.validate(), initialize: true);
    userStore.setClinicId(defaultClinic.id.validate(), initialize: true);
  }

  setValue(PASSWORD, req['password']);
  setValue(USER_LOGIN, value.userNiceName.validate());
  setValue(USER_DATA, jsonEncode(value));
  setValue(USER_ENCOUNTER_MODULES, jsonEncode(value.encounterModules));
  setValue(USER_PRESCRIPTION_MODULE, jsonEncode(value.prescriptionModule));
  setValue(USER_MODULE_CONFIG, jsonEncode(value.moduleConfig));

  appStore.setLoggedIn(true);
  userStore.setUserEmail(value.userEmail.validate(), initialize: true);
  userStore.setUserProfile(value.profileImage.validate(), initialize: true);
  userStore.setUserId(value.userId.validate(), initialize: true);
  userStore.setFirstName(value.firstName.validate(), initialize: true);
  userStore.setLastName(value.lastName.validate(), initialize: true);
  userStore.setRole(value.role.validate(), initialize: true);
  userStore.setUserDisplayName(value.userDisplayName.validate(), initialize: true);
  userStore.setUserMobileNumber(value.mobileNumber.validate(), initialize: true);
  userStore.setUserGender(value.gender.validate(), initialize: true);

  appStore.setUserProEnabled(value.isKivicareProOnName.validate(), initialize: true);

  getConfigurationAPI();
  if (isReceptionist() || isPatient()) {
    getSelectedClinicAPI(clinicId: userStore.userClinicId.validate(), isForLogin: true).then((value) {
      userStore.setUserClinicImage(value.profileImage.validate(), initialize: true);
      userStore.setUserClinicName(value.name.validate(), initialize: true);
      userStore.setUserClinicStatus(value.status.validate(), initialize: true);
      String clinicAddress = '';

      if (value.city.validate().isNotEmpty) {
        clinicAddress = value.city.validate();
      }
      if (value.country.validate().isNotEmpty) {
        clinicAddress += ' ,' + value.country.validate();
      }
      userStore.setUserClinicAddress(clinicAddress, initialize: true);
    });
  }
  appStore.setLoading(false);

  return value;
}

Future<BaseResponses> changePasswordAPI(Map<String, dynamic> request) async {
  return BaseResponses.fromJson(await handleResponse(await buildHttpResponse('kivicare/api/v1/user/change-password', request: request, method: HttpMethod.POST)));
}

Future<BaseResponses> deleteAccountPermanently() async {
  return BaseResponses.fromJson(await handleResponse(await buildHttpResponse('kivicare/api/v1/auth/delete', method: HttpMethod.DELETE)));
}

Future<BaseResponses> logOutApi() async {
  Map req = {"player_id": appStore.playerId, "logged_out": 1};
  log(req.toString());
  await removeKey(PLAYER_ID);
  OneSignal.shared.disablePush(true);
  return BaseResponses.fromJson(await handleResponse(await buildHttpResponse('kivicare/api/v1/auth/manage-user-player-ids', request: req, method: HttpMethod.POST)));
}

Future<void> logout({bool isTokenExpired = false}) async {
  if (!isTokenExpired)
    await logOutApi().catchError((e) {
      appStore.setLoading(false);
      throw e;
    });

  await removeKey(TOKEN);
  await removeKey(USER_ID);
  await removeKey(FIRST_NAME);
  await removeKey(LAST_NAME);
  await removeKey(USER_EMAIL);
  await removeKey(USER_DISPLAY_NAME);
  await removeKey(PROFILE_IMAGE);
  await removeKey(USER_MOBILE);
  await removeKey(USER_GENDER);
  await removeKey(USER_ROLE);
  await removeKey(PASSWORD);

  appStore.setLoggedIn(false);
  appStore.setLoading(false);
  push(SignInScreen(), isNewTask: true, pageRouteAnimation: PageRouteAnimation.Fade);
}

Future<UserModel> getSingleUserDetailAPI(int? id) async {
  return UserModel.fromJson(await (handleResponse(await buildHttpResponse('kivicare/api/v1/user/get-detail?ID=$id'))));
}

//Post API Change

Future<BaseResponses> forgotPasswordAPI(Map<String, dynamic> request) async {
  return BaseResponses.fromJson(await handleResponse(await buildHttpResponse('kivicare/api/v1/user/forgot-password', request: request, method: HttpMethod.POST)));
}

Future<void> updateProfileAPI({required Map<String, dynamic> data, File? profileImage, File? doctorSignature}) async {
  var multiPartRequest = await getMultiPartRequest('kivicare/api/v1/user/profile-update');

  multiPartRequest.fields.addAll(await getMultipartFields(val: data));

  log("Multipart ${multiPartRequest.fields}");
  multiPartRequest.headers.addAll(buildHeaderTokens());

  if (profileImage != null) {
    multiPartRequest.files.add(await MultipartFile.fromPath('profile_image', profileImage.path));
  }

  if (doctorSignature != null) {
    String convertedImage = await convertImageToBase64(doctorSignature);
    multiPartRequest.files.add(MultipartFile.fromString('signature_img', convertedImage));
  }
  appStore.setLoading(true);

  await sendMultiPartRequest(multiPartRequest, onSuccess: (temp) async {
    appStore.setLoading(false);

    log("Response: $temp");
    UserModel data = UserModel.fromJson(temp['data']);
    cachedUserData = data;

    userStore.setFirstName(data.firstName.validate(), initialize: true);
    userStore.setLastName(data.lastName.validate(), initialize: true);
    userStore.setUserMobileNumber(data.mobileNumber.validate(), initialize: true);
    if (data.profileImage != null) {
      userStore.setUserProfile(data.profileImage.validate(), initialize: true);
    }
    toast(temp['message'], print: true);
    finish(getContext, true);
  }, onError: (error) {
    toast(error.toString(), print: true);
    appStore.setLoading(false);
  });
}

Future<String> addUpdateDoctorDetailsAPI({required Map<String, dynamic> data}) async {
  var multiPartRequest = await getMultiPartRequest('kivicare/api/v1/doctor/add-doctor');

  multiPartRequest.fields.addAll(await getMultipartFields(val: data));

  log("Multipart ${jsonEncode(multiPartRequest.fields)}");

  multiPartRequest.headers.addAll(buildHeaderTokens());

  appStore.setLoading(true);
  String msg = '';

  await sendMultiPartRequest(
    multiPartRequest,
    onSuccess: (temp) async {
      appStore.setLoading(false);
      log("Response: $temp");
      UserModel data = UserModel.fromJson(temp['data']);
      cachedUserData = data;

      msg = temp['message'];
    },
    onError: (error) {
      msg = error;
      return error;
    },
  );
  return msg;
}

//region CommonFunctions
Future<Map<String, String>> getMultipartFields({required Map<String, dynamic> val}) async {
  Map<String, String> data = {};

  val.forEach((key, value) {
    data[key] = '$value';
  });

  return data;
}

Future<List<MultipartFile>> getMultipartImages({required List<File> files, required String name}) async {
  List<MultipartFile> multiPartRequest = [];

  await Future.forEach<File>(files, (element) async {
    int i = files.indexOf(element);

    multiPartRequest.add(await MultipartFile.fromPath('${'$name' + i.toString()}', element.path));
  });

  return multiPartRequest;
}

//endregion
