import 'package:flutter/material.dart';
import 'package:kivicare_flutter/components/empty_error_state_component.dart';
import 'package:kivicare_flutter/components/internet_connectivity_widget.dart';
import 'package:kivicare_flutter/components/loader_widget.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/encounter_model.dart';
import 'package:kivicare_flutter/model/encounter_type_model.dart';
import 'package:kivicare_flutter/model/prescription_model.dart';
import 'package:nb_utils/nb_utils.dart';

import 'package:kivicare_flutter/components/status_widget.dart';
import 'package:kivicare_flutter/network/dashboard_repository.dart';
import 'package:kivicare_flutter/utils/app_common.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:kivicare_flutter/screens/doctor/screens/bill_details_screen.dart';
import 'package:kivicare_flutter/screens/patient/components/patient_report_component.dart';

class PatientEncounterDashboardScreen extends StatefulWidget {
  final String? id;

  final bool isPaymentDone;

  PatientEncounterDashboardScreen({Key? key, this.id, this.isPaymentDone = false}) : super(key: key);

  @override
  State<PatientEncounterDashboardScreen> createState() => _PatientEncounterDashboardScreenState();
}

class _PatientEncounterDashboardScreenState extends State<PatientEncounterDashboardScreen> {
  Future<EncounterModel>? future;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    future = getEncounterDetailsDashBoardAPI(encounterId: widget.id!.toInt()).then((value) {
      appStore.setLoading(false);
      return value;
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
      throw e;
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Widget buildHeaderWidget({required EncounterModel data}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: boxDecorationDefault(color: context.cardColor),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(locale.lblName, style: secondaryTextStyle(size: 12)),
                Text(data.patientName.validate(), style: boldTextStyle()),
                8.height,
                Text(locale.lblEmail, style: secondaryTextStyle(size: 12)),
                Text(data.patientEmail.validate(), style: boldTextStyle()),
                8.height,
                Text(locale.lblEncounterDate, style: secondaryTextStyle(size: 12)),
                Text(data.encounterDate != null ? data.encounterDate.validate() : '', style: boldTextStyle()),
              ],
            ),
          ).expand(),
          16.width,
          Container(
            decoration: boxDecorationDefault(color: context.cardColor),
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(locale.lblClinicName, style: secondaryTextStyle(size: 12)),
                Text(data.clinicName.validate(), style: boldTextStyle()),
                8.height,
                Text(locale.lblDoctorName, style: secondaryTextStyle(size: 12)),
                Text(data.doctorName.validate(), style: boldTextStyle()),
                8.height,
                Text(locale.lblDescription, style: secondaryTextStyle(size: 12)),
                Text(data.description.validate(value: " -- "), style: boldTextStyle()),
              ],
            ),
          ).expand(),
        ],
      ),
    );
  }

  Widget buildEncounterDetailsWidget({required EncounterModel data}) {
    return Container(
      padding: EdgeInsets.only(top: 16, bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(locale.lblProblems, style: boldTextStyle()),
          16.height,
          if (data.problem.validate().isNotEmpty)
            UL(
              customSymbol: Icon(Icons.done_sharp, color: context.primaryColor, size: 16),
              symbolType: SymbolType.Custom,
              children: List.generate(
                data.problem.validate().length,
                (index) {
                  EncounterType encounterData = data.problem.validate()[index];
                  return Text(encounterData.title.validate(), style: secondaryTextStyle());
                },
              ),
            )
          else
            NoDataWidget(
              title: "${locale.lblNo} ${locale.lblProblems} ${locale.lblFound}!",
              titleTextStyle: secondaryTextStyle(color: Colors.red),
            ),
          32.height,
          Text(locale.lblObservation, style: boldTextStyle()),
          16.height,
          if (data.observation.validate().isNotEmpty)
            UL(
              customSymbol: Icon(Icons.done_sharp, color: context.primaryColor, size: 16),
              symbolType: SymbolType.Custom,
              symbolCrossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                data.observation.validate().length,
                (index) {
                  EncounterType encounterData = data.observation.validate()[index];
                  return Text(encounterData.title.validate(), style: secondaryTextStyle());
                },
              ),
            )
          else
            NoDataWidget(
              title: "${locale.lblNo} ${locale.lblObservation} ${locale.lblFound}",
              titleTextStyle: secondaryTextStyle(color: Colors.red),
            ),
          32.height,
          Text(locale.lblNotes, style: boldTextStyle()),
          16.height,
          if (data.note.validate().isNotEmpty)
            UL(
              customSymbol: Icon(Icons.done_sharp, color: context.primaryColor, size: 16),
              symbolType: SymbolType.Custom,
              children: List.generate(
                data.note.validate().length,
                (index) {
                  EncounterType encounterData = data.note.validate()[index];
                  return Text("${encounterData.title.validate()}", style: secondaryTextStyle());
                },
              ),
            )
          else
            NoDataWidget(
              title: "${locale.lblNo} ${locale.lblNotes} ${locale.lblFound}!",
              titleTextStyle: secondaryTextStyle(color: Colors.red),
            ),
          32.height,
          if (data.prescription != null) ...[
            Text(locale.lblPrescription, style: boldTextStyle()),
            16.height,
            if (data.prescription.validate().isEmpty)
              NoDataWidget(
                title: "${locale.lblNo} ${locale.lblPrescription} ${locale.lblFound}!",
                titleTextStyle: secondaryTextStyle(color: Colors.red),
              )
            else
              UL(
                customSymbol: Icon(Icons.done_sharp, color: context.primaryColor, size: 16),
                symbolType: SymbolType.Numbered,
                symbolCrossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  data.prescription!.validate().length,
                  (index) {
                    PrescriptionData encounterData = data.prescription!.validate()[index];
                    return Table(
                      children: [
                        TableRow(children: [
                          Text(locale.lblName, style: secondaryTextStyle()),
                          Text(encounterData.name.validate(), style: primaryTextStyle()),
                        ]),
                        TableRow(children: [
                          Text(locale.lblFrequency, style: secondaryTextStyle()),
                          Text(encounterData.frequency.validate(), style: primaryTextStyle()),
                        ]),
                        TableRow(children: [
                          Text(locale.lblInstruction, style: secondaryTextStyle()),
                          Text(encounterData.instruction.validate(), style: primaryTextStyle()),
                        ])
                      ],
                    );
                    return Container(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(encounterData.instruction.validate(), style: secondaryTextStyle()),
                      ],
                    ));
                  },
                ),
              ),
          ],
          32.height,
          Text(locale.lblMedicalReports, style: boldTextStyle()),
          16.height,
          PatientReportComponent(reportList: data.reportData.validate())
        ],
      ),
    ).paddingBottom(60);
  }

  Widget buildBodyWidget() {
    return SnapHelperWidget<EncounterModel>(
      future: future,
      errorWidget: ErrorStateWidget(),
      loadingWidget: LoaderWidget(),
      onSuccess: (snap) {
        return AnimatedScrollView(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 0),
          physics: AlwaysScrollableScrollPhysics(),
          onSwipeRefresh: () async {
            init();
            return await 2.seconds.delay;
          },
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: StatusWidget(
                status: snap.status.validate(),
                width: 80,
                isEncounterStatus: true,
              ),
            ).paddingBottom(16),
            buildHeaderWidget(data: snap),
            buildEncounterDetailsWidget(data: snap),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: appBarWidget(
        locale.lblEncounterDashboard,
        textColor: Colors.white,
        systemUiOverlayStyle: defaultSystemUiOverlayStyle(context),
      ),
      body: InternetConnectivityWidget(
        retryCallback: () async {
          init();
          setState(() {});

          return await 1.seconds.delay;
        },
        child: buildBodyWidget(),
      ),
      floatingActionButton: widget.isPaymentDone
          ? Container(
              padding: EdgeInsets.symmetric(horizontal: 28, vertical: 8),
              decoration: boxDecorationDefault(color: appSecondaryColor),
              child: Text(locale.lblBillDetails, style: primaryTextStyle(color: Colors.white)).onTap(
                () {
                  if (widget.isPaymentDone) BillDetailsScreen(encounterId: widget.id.validate().toInt()).launch(context);
                },
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
            )
          : Offstage(),
    );
  }
}
