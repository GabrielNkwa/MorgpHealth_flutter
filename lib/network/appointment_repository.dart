import 'dart:convert';
import 'dart:io';

import 'package:kivicare_flutter/config.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/appoinment_model.dart';
import 'package:kivicare_flutter/model/appointment_slot_model.dart';
import 'package:kivicare_flutter/model/confirm_appointment_response_model.dart';
import 'package:kivicare_flutter/model/upcoming_appointment_model.dart';
import 'package:kivicare_flutter/network/auth_repository.dart';
import 'package:kivicare_flutter/network/network_utils.dart';
import 'package:kivicare_flutter/utils/app_common.dart';
import 'package:kivicare_flutter/utils/cached_value.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:kivicare_flutter/model/encounter_model.dart';

Future<List<UpcomingAppointmentModel>> getPatientAppointmentList(
  int? patientId, {
  String status = 'All',
  required List<UpcomingAppointmentModel> appointmentList,
  page,
  Function(bool)? lastPageCallback,
}) async {
  if (!appStore.isConnectedToInternet) {
    return [];
  }

  List<String> param = [];
  param.add(patientId != null ? '&patient_id=$patientId' : '');
  param.add('status=$status');

  EncounterModel res = EncounterModel.fromJson(
    await handleResponse(await buildHttpResponse(getEndPoint(endPoint: 'kivicare/api/v1/appointment/get-appointment', page: page, params: param))),
  );

  if (page == 1) appointmentList.clear();

  lastPageCallback?.call(res.upcomingAppointmentData.validate().length != PER_PAGE);

  appointmentList.addAll(res.upcomingAppointmentData.validate());
  cachedPatientAppointment = res.upcomingAppointmentData.validate();
  appStore.setLoading(false);

  return appointmentList;
}

Future<List<UpcomingAppointmentModel>> getAppointment({
  int pages = 1,
  int perPage = PER_PAGE,
  String? todayDate,
  String? startDate,
  String? endDate,
  required List<UpcomingAppointmentModel> appointmentList,
  Function(bool)? lastPageCallback,
}) async {
  if (!appStore.isConnectedToInternet) {
    return [];
  }

  AppointmentModel value;
  String page = "?page=$pages";
  String limit = "&limit=$perPage";
  String todayDates = todayDate != null ? "&date=$todayDate" : "";
  String start = startDate != null ? "&start=$startDate" : "";
  String end = endDate != null ? "&end=$endDate" : "";
  value = AppointmentModel.fromJson(await (handleResponse(await buildHttpResponse('kivicare/api/v1/appointment/get-appointment$page$limit$todayDates$start$end'))));
  if (pages == 1) appointmentList.clear();

  appointmentList.addAll(value.appointmentData.validate());
  lastPageCallback?.call(value.appointmentData.validate().length != perPage);
  cachedDoctorAppointment = appointmentList;

  return appointmentList;
}

Future<List<UpcomingAppointmentModel>> getReceptionistAppointmentList({
  bool isPast = false,
  String? todayDate,
  String? startDate,
  String? endDate,
  required List<UpcomingAppointmentModel> appointmentList,
  String status = 'All',
  int? page,
  Function(bool)? lastPageCallback,
}) async {
  if (!appStore.isConnectedToInternet) {
    return [];
  }

  List<String> param = [];
  param.add('status=$status');
  param.add('page=$page');
  param.add('limit=$PER_PAGE');

  if (todayDate == null) {
    if (startDate != null) param.add('start=$startDate');
    if (endDate != null) param.add('end=$endDate');
  } else {
    if (!isPast) param.add('date=$todayDate');
  }

  AppointmentModel res = AppointmentModel.fromJson(await handleResponse(await buildHttpResponse('kivicare/api/v1/appointment/get-appointment?${param.validate().join('&')}')));

  if (page == 1) appointmentList.clear();

  lastPageCallback?.call(res.appointmentData.validate().length != PER_PAGE);

  appointmentList.addAll(res.appointmentData.validate());

  appStore.setLoading(false);
  cachedReceptionistAppointment = appointmentList;
  return appointmentList;
}

//region Appointment

Future<List<List<AppointmentSlotModel>>> getAppointmentTimeSlotList({String? appointmentDate, String? doctorId, String? clinicId}) async {
  if (!appStore.isConnectedToInternet) {
    return [];
  }
  Iterable it = await (handleResponse(await buildHttpResponse('kivicare/api/v1/doctor/appointment-time-slot?clinic_id=$clinicId&date=$appointmentDate&doctor_id=${doctorId != null ? doctorId : ''}')));

  List<List<AppointmentSlotModel>> list = [];

  it.forEach((element) {
    Iterable v = element;
    list.add(v.map((e) => AppointmentSlotModel.fromJson(e)).toList());
  });

  return list;
}

Future updateAppointmentStatus(Map request) async {
  return await handleResponse(await buildHttpResponse('kivicare/api/v1/appointment/update-status', request: request, method: HttpMethod.POST));
}

Future deleteAppointment(Map request) async {
  return await handleResponse(await buildHttpResponse('kivicare/api/v1/appointment/delete', request: request, method: HttpMethod.POST));
}

//region
Future<ConfirmAppointmentResponseModel> saveAppointmentApi({required Map<String, dynamic> data, List<File>? files}) async {
  var multiPartRequest = await getMultiPartRequest('kivicare/api/v2/appointment/save');

  multiPartRequest.fields.addAll(await getMultipartFields(val: data));

  if (files.validate().isNotEmpty) {
    multiPartRequest.files.addAll(await getMultipartImages(files: files!, name: 'appointment_report_'));
    multiPartRequest.fields['attachment_count'] = files.validate().length.toString();
  }

  log("Multi Part Request : ${jsonEncode(multiPartRequest.fields)} ${multiPartRequest.files.map((e) => e.field + ": " + e.filename.validate())}");

  multiPartRequest.headers.addAll(buildHeaderTokens());

  appStore.setLoading(true);

  return await sendMultiPartRequestNew(multiPartRequest).then((value) {
    appStore.setLoading(false);
    return ConfirmAppointmentResponseModel.fromJson(value);
  }).catchError((e) async {
    appStore.setLoading(false);
    toast(e.toString());
    throw e.toString();
  });
}
