import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kivicare_flutter/components/status_widget.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/encounter_model.dart';
import 'package:kivicare_flutter/screens/doctor/screens/bill_details_screen.dart';
import 'package:kivicare_flutter/screens/encounter/screen/encounter_dashboard_screen.dart';
import 'package:kivicare_flutter/screens/encounter/screen/patient_encounter_dashboard_screen.dart';
import 'package:kivicare_flutter/utils/app_common.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:kivicare_flutter/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

class EncounterComponent extends StatelessWidget {
  final EncounterModel data;
  final Function(int)? deleteEncounter;
  final VoidCallback? callForRefresh;

  EncounterComponent({required this.data, this.deleteEncounter, this.callForRefresh});

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(data.encounterId),
      endActionPane: ActionPane(
        extentRatio: 0.7,
        motion: ScrollMotion(),
        children: [
          if (data.status == ClosedEncounterStatusInt.toString())
            SlidableAction(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              borderRadius: BorderRadius.only(topLeft: Radius.circular(defaultRadius), bottomLeft: Radius.circular(defaultRadius)),
              icon: FontAwesomeIcons.moneyBill,
              label: locale.lblBillDetails,
              onPressed: (BuildContext context) {
                BillDetailsScreen(encounterId: data.encounterId.validate().toInt()).launch(context);
              },
            ),
          SlidableAction(
            borderRadius: BorderRadius.only(topRight: Radius.circular(defaultRadius), bottomRight: Radius.circular(defaultRadius)),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: locale.lblDelete,
            onPressed: (BuildContext context) {
              showConfirmDialogCustom(
                context,
                dialogType: DialogType.DELETE,
                title: locale.lblDoYouWantToDeleteEncounterDetailsOf,
                onAccept: (p0) {
                  ifTester(context, () {
                    deleteEncounter?.call(data.encounterId.toInt());
                  }, userEmail: data.patientEmail);
                },
              );
            },
          ),
        ],
      ),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: boxDecorationDefault(color: context.cardColor, borderRadius: radius()),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if ((isDoctor() || isReceptionist())) Text(data.patientName.validate(), style: boldTextStyle(size: 18)),
                4.height,
                if (isPatient() || isDoctor())
                  RichTextWidget(list: [
                    if (isDoctor()) TextSpan(text: locale.lblClinic + ' : ', style: secondaryTextStyle(size: 14)),
                    TextSpan(text: data.clinicName.validate().capitalizeEachWord(), style: isPatient() ? boldTextStyle() : primaryTextStyle(size: 14)),
                  ])
                else
                  RichTextWidget(list: [
                    TextSpan(text: locale.lblDoctor + ' : ', style: secondaryTextStyle(size: 14)),
                    TextSpan(text: 'Dr. ' + data.doctorName.validate().capitalizeEachWord(), style: primaryTextStyle(size: 14)),
                  ]),
                4.height,
                if (isPatient())
                  RichTextWidget(list: [
                    TextSpan(text: 'Dr. ' + data.doctorName.validate().capitalizeEachWord(), style: primaryTextStyle(size: 14, color: appPrimaryColor)),
                  ]),
                4.height,
                RichTextWidget(list: [
                  TextSpan(text: locale.lblDate + " : ", style: secondaryTextStyle(size: 14)),
                  TextSpan(text: data.encounterDate.validate(), style: primaryTextStyle(size: 14)),
                ]),
                if (data.description.validate().isNotEmpty) 4.height,
                if (data.description.validate().isNotEmpty)
                  RichTextWidget(list: [
                    TextSpan(text: locale.lblDescription + " : ", style: secondaryTextStyle(size: 14)),
                    TextSpan(text: data.description, style: primaryTextStyle(size: 14)),
                  ]),
              ],
            ).expand(flex: 3),
            4.width,
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FaIcon(FontAwesomeIcons.gaugeHigh, color: appSecondaryColor, size: 20).withWidth(20).onTap(
                  () {
                    if (isPatient()) {
                      PatientEncounterDashboardScreen(id: data.encounterId, isPaymentDone: data.status == '0' ? true : false).launch(context);
                    } else {
                      EncounterDashboardScreen(encounterId: data.encounterId).launch(context).then((value) {
                        if (value ?? false) {
                          callForRefresh?.call();
                        }
                      });
                    }
                  },
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                ),
                36.height,
                StatusWidget(
                  status: data.status.validate(),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  isEncounterStatus: true,
                ),
              ],
            ).expand()
          ],
        ),
      ),
    ).paddingSymmetric(vertical: 8);
  }
}
