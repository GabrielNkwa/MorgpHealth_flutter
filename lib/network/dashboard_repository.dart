import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/dashboard_model.dart';
import 'package:kivicare_flutter/model/encounter_model.dart';
import 'package:kivicare_flutter/model/static_data_model.dart';
import 'package:kivicare_flutter/model/upcoming_appointment_model.dart';
import 'package:kivicare_flutter/network/network_utils.dart';
import 'package:kivicare_flutter/utils/cached_value.dart';
import 'package:nb_utils/nb_utils.dart';

Future<DashboardModel> getUserDashBoardAPI() async {
  if (!appStore.isConnectedToInternet) {
    return DashboardModel();
  }
  appStore.setLoading(true);

  DashboardModel res = DashboardModel.fromJson(await (handleResponse(await buildHttpResponse('kivicare/api/v1/user/get-dashboard?page=1&limit=5'))));
  appStore.setLoading(false);
  cachedDashboardModel = res;
  appStore.setCurrencyPostfix(res.currencyPostfix.validate());
  appStore.setCurrencyPrefix(res.currencyPrefix.validate());

  appStore.setLoading(false);
  return res;
}

Future<EncounterModel> getEncounterDetailsDashBoardAPI({required int encounterId}) async {
  if (!appStore.isConnectedToInternet) {
    return EncounterModel();
  }
  return EncounterModel.fromJson(await (handleResponse(await buildHttpResponse('kivicare/api/v1/encounter/get-encounter-detail?id=$encounterId'))));
}

Future<StaticDataModel> getStaticDataResponseAPI(String req, {String? searchString}) async {
  List<String> param = [];
  if (searchString.validate().isNotEmpty) param.add('s=$searchString');
  StaticDataModel data = StaticDataModel.fromJson(await (handleResponse(await buildHttpResponse('kivicare/api/v1/staticdata/get-list?type=$req&${param.validate().join('&')}'))));
  if (data.staticData != null) cachedStaticData = data.staticData;
  return data;
}
// get appointment count

Future<List<WeeklyAppointment>> getAppointmentCountAPI({required Map request}) async {
  Iterable it = Iterable.empty();

  it = await handleResponse(await buildHttpResponse('kivicare/api/v1/doctor/get-appointment-count', request: request, method: HttpMethod.POST));

  return it.map((e) => WeeklyAppointment.fromJson(e)).toList();
}
