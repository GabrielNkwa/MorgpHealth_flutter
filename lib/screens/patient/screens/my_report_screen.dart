import 'package:flutter/material.dart';
import 'package:kivicare_flutter/components/empty_error_state_component.dart';
import 'package:kivicare_flutter/components/internet_connectivity_widget.dart';
// ignore: unused_import
import 'package:kivicare_flutter/components/loader_widget.dart';
import 'package:kivicare_flutter/components/no_data_found_widget.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/report_model.dart';
import 'package:kivicare_flutter/network/report_repository.dart';
import 'package:kivicare_flutter/screens/encounter/component/report_component.dart';
import 'package:kivicare_flutter/screens/shimmer/screen/report_shimmer_screen.dart';
import 'package:kivicare_flutter/utils/app_common.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

class MyReportsScreen extends StatefulWidget {
  @override
  _MyReportsScreenState createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  Future<List<ReportData>>? future;

  List<ReportData> reportList = [];

  int total = 0;
  int page = 1;

  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    future = getPatientReportListApi(
      patientId: userStore.userId,
      page: page,
      getTotalReport: (b) => total = b,
      lastPageCallback: (b) => isLastPage = b,
      reportList: reportList,
    ).then((value) {
      appStore.setLoading(false);
      return value;
    }).catchError((e) {
      appStore.setLoading(false);
      throw e;
    });
  }

  void deleteReportData(String? id) {
    appStore.setLoading(true);

    Map<String, dynamic> res = {"report_id": "$id"};
    deleteReportAPI(res).then((value) {
      appStore.setLoading(false);
      toast(locale.lblReport + " " + locale.lblDeletedSuccessfully);
    }).whenComplete(() {
      appStore.setLoading(false);
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(locale.lblMyReports, textColor: Colors.white, systemUiOverlayStyle: defaultSystemUiOverlayStyle(context), elevation: 0, color: appPrimaryColor),
      body: InternetConnectivityWidget(
        child: SnapHelperWidget<List<ReportData>>(
          future: future,
          loadingWidget: ReportShimmerScreen(),
          errorWidget: ErrorStateWidget().center(),
          onSuccess: (snap) {
            return AnimatedScrollView(
              padding: EdgeInsets.only(bottom: 60, top: 16, left: 16, right: 16),
              children: snap
                  .map((reportData) => ReportComponent(
                        reportData: reportData,
                        isForMyReportScreen: true,
                      ))
                  .toList(),
            ).visible(snap.isNotEmpty,
                defaultWidget: snap.isEmpty && !appStore.isLoading ? NoDataFoundWidget(text: locale.lblNoReportsFound).center() : ReportShimmerScreen().visible(appStore.isLoading));
          },
        ),
        retryCallback: () {
          setState(() {});
        },
      ),
    );
  }
}
