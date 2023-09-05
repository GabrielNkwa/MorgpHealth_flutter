import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:kivicare_flutter/config.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/base_response.dart';
import 'package:kivicare_flutter/model/report_model.dart';
import 'package:kivicare_flutter/network/network_utils.dart';
import 'package:kivicare_flutter/utils/app_common.dart';
import 'package:nb_utils/nb_utils.dart';

//Report

Future<ReportModel> getReportDataAPI({int? patientId}) async {
  return ReportModel.fromJson(await (handleResponse(await buildHttpResponse('kivicare/api/v1/patient/get-patient-report?patient_id=$patientId&page=1&limit=10'))));
}

Future<BaseResponses> addReportDataAPI(Map data, {File? file}) async {
  var multiPartRequest = await getMultiPartRequest('kivicare/api/v1/patient/upload-patient-report');

  multiPartRequest.fields['name'] = data['name'];
  if (data['id'] != null) multiPartRequest.fields['id'] = data['id'];
  multiPartRequest.fields['patient_id'] = data['patient_id'];
  multiPartRequest.fields['date'] = data['date'];

  if (file != null) multiPartRequest.files.add(await MultipartFile.fromPath('upload_report', file.path));

  multiPartRequest.headers.addAll(buildHeaderTokens());
  log("Multi Part Request : ${jsonEncode(multiPartRequest.fields)} ${multiPartRequest.files.map((e) => e.field + ": " + e.filename.validate())}");
  Response response = await Response.fromStream(await multiPartRequest.send());

  if (response.statusCode.isSuccessful()) {
    return BaseResponses.fromJson(jsonDecode(response.body));
  } else {
    return BaseResponses.fromJson(jsonDecode(response.body));
  }
}

Future deleteReportAPI(Map request) async {
  return await handleResponse(await buildHttpResponse('kivicare/api/v1/patient/delete-patient-report', request: request, method: HttpMethod.POST));
}

Future<List<ReportData>> getPatientReportListApi({
  int? patientId,
  int? page,
  required List<ReportData> reportList,
  Function(bool)? lastPageCallback,
  Function(int)? getTotalReport,
}) async {
  if (!appStore.isConnectedToInternet) {
    return [];
  }
  appStore.setLoading(true);

  List<String> param = [];
  param.add('patient_id=$patientId');

  ReportModel res = ReportModel.fromJson(await handleResponse(await buildHttpResponse(getEndPoint(endPoint: 'kivicare/api/v1/patient_report/get', page: page, params: param))));
  cachedReportList = res.reportData.validate();
  getTotalReport?.call(res.reportData.validate().length.toInt());

  if (page == 1) reportList.clear();

  lastPageCallback?.call(res.reportData.validate().length != PER_PAGE);

  reportList.addAll(res.reportData.validate());

  appStore.setLoading(false);
  return reportList;
}

//End Report
