import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:kivicare_flutter/components/price_widget.dart';
import 'package:kivicare_flutter/components/role_widget.dart';
import 'package:kivicare_flutter/components/side_date_widget.dart';
import 'package:kivicare_flutter/components/status_widget.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/bill_list_model.dart';
import 'package:kivicare_flutter/model/encounter_model.dart';
import 'package:kivicare_flutter/screens/doctor/screens/bill_details_screen.dart';
import 'package:kivicare_flutter/screens/encounter/screen/encounter_dashboard_screen.dart';
import 'package:kivicare_flutter/screens/doctor/screens/generate_bill_screen.dart';
import 'package:kivicare_flutter/screens/encounter/screen/patient_encounter_dashboard_screen.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:kivicare_flutter/utils/constants.dart';
import 'package:kivicare_flutter/utils/extensions/string_extensions.dart';
import 'package:nb_utils/nb_utils.dart';

class BillComponent extends StatelessWidget {
  final BillListData billData;
  final VoidCallback? callToRefresh;

  BillComponent({required this.billData, this.callToRefresh});

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(billData),
      endActionPane: ActionPane(
        extentRatio: 0.6,
        motion: ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (BuildContext context) {
              if (billData.paymentStatus.validate().getBoolInt()) {
                BillDetailsScreen(encounterId: billData.encounterId.validate().toInt()).launch(context);
              } else {
                if (isPatient()) {
                  BillDetailsScreen(encounterId: billData.encounterId.validate().toInt()).launch(context);
                } else {
                  GenerateBillScreen(
                    data: EncounterModel(
                      encounterId: billData.encounterId.validate().toString(),
                      paymentStatus: billData.paymentStatus.validate(),
                      billId: billData.id.validate().toString(),
                    ),
                  ).launch(context).then((value) {
                    callToRefresh?.call();
                  });
                }
              }
            },
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(defaultRadius), bottomLeft: Radius.circular(defaultRadius)),
            icon: FontAwesomeIcons.moneyBillTransfer,
            label: locale.lblBillDetails,
          ),
          SlidableAction(
            borderRadius: BorderRadius.only(topRight: Radius.circular(defaultRadius), bottomRight: Radius.circular(defaultRadius)),
            onPressed: (context) {
              if (isPatient()) {
                PatientEncounterDashboardScreen(
                  id: billData.encounterId.validate().toString(),
                  isPaymentDone: billData.paymentStatus.validate().getBoolInt(),
                ).launch(context);
              } else {
                EncounterDashboardScreen(encounterId: billData.encounterId.validate().toString()).launch(context);
              }
            },
            backgroundColor: appSecondaryColor,
            icon: FontAwesomeIcons.gaugeHigh,
            foregroundColor: Colors.white,
            spacing: 16,
            padding: EdgeInsets.all(8),
            label: locale.lblEncounterDashboard,
          ),
        ],
      ),
      child: Container(
        decoration: boxDecorationDefault(color: context.cardColor),
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RoleWidget(
                      isShowReceptionist: true,
                      isShowDoctor: true,
                      child: Text(billData.patientName.validate(), style: boldTextStyle()),
                    ),
                    RoleWidget(
                      isShowPatient: false,
                      isShowReceptionist: true,
                      isShowDoctor: true,
                      child: 4.height,
                    ),
                    RoleWidget(
                      isShowPatient: true,
                      isShowDoctor: true,
                      child: RichTextWidget(list: [TextSpan(text: billData.clinicName.validate(), style: isDoctor() ? secondaryTextStyle(color: appPrimaryColor) : boldTextStyle(size: 18))]),
                    ),
                    RoleWidget(
                      isShowPatient: true,
                      isShowReceptionist: true,
                      child: Text('${billData.doctorName.validate().capitalizeEachWord().prefixText(value: '${locale.lblDr}. ')}',
                          style: primaryTextStyle(color: appPrimaryColor, size: isPatient() ? 14 : 16)),
                    ),
                    2.height,
                    RichTextWidget(list: [TextSpan(text: locale.lblDate + " : ", style: secondaryTextStyle()), TextSpan(text: billData.createdAt.validate(), style: primaryTextStyle(size: 14))])
                  ],
                ).expand(),
                10.width,
                StatusWidget(status: billData.paymentStatus.validate(), isPaymentStatus: true),
              ],
            ),
            16.height,
            DottedBorderWidget(
              radius: defaultRadius,
              color: context.primaryColor,
              child: Container(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(locale.lblTotal, style: secondaryTextStyle(size: 12)).expand(),
                        4.height,
                        Text(locale.lblDiscount, style: secondaryTextStyle(size: 12)).expand(),
                        4.height,
                        Text(locale.lblAmountDue, style: secondaryTextStyle(size: 12)).expand(),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        PriceWidget(price: billData.totalAmount.validate().toString(), textSize: 14).expand(),
                        PriceWidget(price: billData.discount.validate().toString(), textSize: 14).expand(),
                        PriceWidget(price: billData.actualAmount.validate().toString(), textSize: 14).expand(),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).paddingSymmetric(vertical: 8);
  }
}
