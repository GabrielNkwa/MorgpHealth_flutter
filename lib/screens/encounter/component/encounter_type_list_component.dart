import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/encounter_model.dart';
import 'package:kivicare_flutter/model/encounter_type_model.dart';
import 'package:kivicare_flutter/model/prescription_model.dart';
import 'package:kivicare_flutter/model/report_model.dart';
import 'package:kivicare_flutter/screens/doctor/screens/add_prescription_screen.dart';
import 'package:kivicare_flutter/screens/doctor/screens/add_report_screen.dart';
import 'package:kivicare_flutter/screens/encounter/component/encounter_functions.dart';
import 'package:kivicare_flutter/screens/encounter/component/encounter_prescription_component.dart';
import 'package:kivicare_flutter/screens/encounter/component/encounter_type_%20component.dart';
import 'package:kivicare_flutter/screens/encounter/component/report_component.dart';
import 'package:kivicare_flutter/utils/constants.dart';
import 'package:kivicare_flutter/utils/extensions/enums.dart';
import 'package:nb_utils/nb_utils.dart';

class EncounterTypeList extends StatefulWidget {
  final String encounterType;
  final EncounterModel encounterData;
  final VoidCallback? refreshCall;
  final void Function({required int id, required EncounterTypeEnum encounterTypeEnum}) callDelete;

  EncounterTypeList({required this.encounterData, this.refreshCall, required this.encounterType, required this.callDelete});

  @override
  State<EncounterTypeList> createState() => _EncounterTypeListState();
}

class _EncounterTypeListState extends State<EncounterTypeList> {
  @override
  void initState() {
    super.initState();
  }

  Widget buildChild() {
    switch (widget.encounterType) {
      case PROBLEM:
        return buildEncounterTypeOthersList();
      case OBSERVATION:
        return buildEncounterTypeOthersList();
      case NOTE:
        return buildEncounterTypeOthersList();
      case PRESCRIPTION:
        return buildEncounterPrescriptionList();
      case REPORT:
        return buildEncounterReportList();

      default:
        return SizedBox.shrink();
    }
  }

  Widget buildEncounterReportList() {
    if (widget.encounterData.reportData != null && widget.encounterData.reportData.validate().isEmpty) return NoDataWidget(title: locale.lblNoReportsFound);
    return AnimatedWrap(
      spacing: 16,
      runSpacing: 12,
      itemCount: widget.encounterData.reportData.validate().length,
      itemBuilder: (context, index) {
        ReportData reportData = widget.encounterData.reportData.validate()[index];
        return ReportComponent(
          reportData: reportData,
          isForMyReportScreen: false,
          isDeleteOn: widget.encounterData.status == '1',
          deleteReportData: () {
            showConfirmDialogCustom(
              context,
              title: locale.lblDoYouWantToDeleteReport,
              dialogType: DialogType.DELETE,
              onAccept: (p0) {
                widget.callDelete.call(id: reportData.id.validate().toInt(), encounterTypeEnum: EncounterTypeEnum.REPORTS);
              },
            );
          },
        ).onTap(
          () {
            AddReportScreen(
              patientId: widget.encounterData.patientId.toInt(),
              reportData: reportData,
            ).launch(context).then((value) {
              if (value ?? false) {
                widget.refreshCall?.call();
              }
            });
          },
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
        );
      },
    ).paddingSymmetric(vertical: 8);
  }

  Widget buildEncounterPrescriptionList() {
    if (widget.encounterData.prescription.validate().isEmpty) return NoDataWidget(title: locale.lblNoPrescriptionFound);
    return AnimatedWrap(
      spacing: 16,
      runSpacing: 12,
      itemCount: widget.encounterData.prescription.validate().length,
      itemBuilder: (context, index) {
        PrescriptionData prescriptionData = widget.encounterData.prescription.validate()[index];

        return GestureDetector(
          onTap: () {
            AddPrescriptionScreen(encounterId: prescriptionData.encounterId.toInt(), prescriptionData: prescriptionData).launch(context).then((value) {
              if (value ?? false) {
                widget.refreshCall?.call();
              }
            });
          },
          child: EncounterPrescriptionComponent(
            prescriptionData: prescriptionData,
            isDeleteOn: widget.encounterData.status == '1',
            onTap: () {
              showConfirmDialogCustom(
                context,
                title: locale.lblDoYouWantToDeletePrescription,
                dialogType: DialogType.DELETE,
                onAccept: (p0) {
                  setState(() {});
                  widget.refreshCall?.call();
                  widget.callDelete.call(id: prescriptionData.id.toInt(), encounterTypeEnum: EncounterTypeEnum.PRESCRIPTIONS);
                },
              );
            },
          ),
        );
      },
    ).paddingSymmetric(vertical: 8);
  }

  Widget buildEncounterTypeOthersList() {
    var data = getEncounterOtherTypeListData(encounterType: widget.encounterType, encounterData: widget.encounterData);
    if (data.$1.isEmpty) return NoDataWidget(title: data.emptyText);
    return AnimatedWrap(
      spacing: 16,
      runSpacing: 12,
      itemCount: data.$1.length,
      itemBuilder: (context, index) {
        EncounterType encounterData = data.$1[index];
        return EncounterTypeComponent(
          data: encounterData,
          isDeleteOn: widget.encounterData.status == '1',
          onTap: () {
            showConfirmDialogCustom(
              context,
              title: locale.lblDoYouWantToDeleteObservation,
              dialogType: DialogType.DELETE,
              onAccept: (p0) {
                widget.callDelete.call(id: encounterData.id.toInt(), encounterTypeEnum: EncounterTypeEnum.OTHERS);
              },
            );
          },
        );
      },
    ).paddingSymmetric(vertical: 8);
  }

  @override
  Widget build(BuildContext context) {
    return buildChild();
  }
}
