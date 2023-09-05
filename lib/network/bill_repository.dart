import 'package:http/http.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/base_response.dart';
import 'package:kivicare_flutter/model/bill_list_model.dart';
import 'package:kivicare_flutter/model/patient_bill_model.dart';
import 'package:kivicare_flutter/network/network_utils.dart';
import 'package:kivicare_flutter/utils/app_common.dart';
import 'package:nb_utils/nb_utils.dart';

Future<PatientBillModule?>? getBillDetailsAPI({int? encounterId}) async {
  Response response = await buildHttpResponse('kivicare/api/v1/bill/bill-details?encounter_id=$encounterId');
  if (response.statusCode == 200 && response.body.isNotEmpty) return PatientBillModule.fromJson(await handleResponse(response));
  return null;
}

Future<BaseResponses> addPatientBillAPI(Map request) async {
  return BaseResponses.fromJson(await handleResponse(await buildHttpResponse('kivicare/api/v1/bill/add-bill', request: request, method: HttpMethod.POST)));
}

Future<List<BillListData>> getBillListApi({
  int? page,
  Function(bool)? lastPageCallback,
  required List<BillListData> billList,
}) async {
  if (!appStore.isConnectedToInternet) {
    return [];
  }
  List<String> param = [];

  BillListModel res = BillListModel.fromJson(
    await handleResponse(await buildHttpResponse(getEndPoint(endPoint: 'kivicare/api/v1/bill/list', page: page, params: param))),
  );

  cachedBillRecordList = res.billListData.validate();

  if (page == 1) billList.clear();

  lastPageCallback?.call(res.billListData.validate().length != 10);

  billList.addAll(res.billListData.validate());

  appStore.setLoading(false);
  return billList;
}
