import 'package:flutter/material.dart';
import 'package:kivicare_flutter/components/loader_widget.dart';
import 'package:kivicare_flutter/components/price_widget.dart';
import 'package:kivicare_flutter/components/status_widget.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/patient_bill_model.dart';
import 'package:kivicare_flutter/network/bill_repository.dart';
import 'package:kivicare_flutter/utils/app_common.dart';

import 'package:nb_utils/nb_utils.dart';

class BillDetailsScreen extends StatefulWidget {
  final int? encounterId;
  final int? billId;

  BillDetailsScreen({this.encounterId, this.billId});

  @override
  _BillDetailsScreenState createState() => _BillDetailsScreenState();
}

class _BillDetailsScreenState extends State<BillDetailsScreen> {
  Future<PatientBillModule?>? future;

  List<String> list = [locale.lblTotal, locale.lblDiscount, locale.lblAmountDue];

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    future = getBillDetailsAPI(encounterId: widget.encounterId)?.then((value) {
      appStore.setLoading(false);
      return value;
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
      throw e;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        locale.lblInvoiceDetail,
        textColor: Colors.white,
        systemUiOverlayStyle: defaultSystemUiOverlayStyle(context),
      ),
      body: SafeArea(child: body()),
    );
  }

  Widget body() {
    return FutureBuilder<PatientBillModule?>(
      future: future,
      builder: (_, snap) {
        if (snap.hasData) {
          return Stack(
            fit: StackFit.expand,
            children: [
              AnimatedScrollView(
                padding: EdgeInsets.all(16),
                listAnimationType: ListAnimationType.None,
                physics: AlwaysScrollableScrollPhysics(),
                children: [
                  Text(locale.lblClinicDetails.toUpperCase(), style: boldTextStyle(size: 16)),
                  Divider(color: viewLineColor),
                  clinicDetails(patientBillData: snap.data!),
                  Divider(color: viewLineColor),
                  16.height,
                  Text(locale.lblPatientDetails.toUpperCase(), style: boldTextStyle(size: 16)),
                  Divider(color: viewLineColor),
                  if (snap.data != null) patientDetails(patientBillData: snap.data!),
                  Divider(color: viewLineColor),
                  16.height,
                  Text(locale.lblServices.toUpperCase(), style: boldTextStyle(size: 16)),
                  Divider(color: viewLineColor),
                  servicesDetails(patientBillData: snap.data!).paddingBottom(200),
                ],
              ),
              Positioned(
                right: 0,
                left: 0,
                bottom: 0,
                child: Container(
                  decoration: boxDecorationDefault(borderRadius: radiusOnly(topLeft: defaultRadius, topRight: defaultRadius), color: context.cardColor),
                  child: Table(
                    children: <TableRow>[
                      TableRow(
                        children: [
                          Text(locale.lblTotal, style: boldTextStyle(size: 12), textAlign: TextAlign.start).paddingSymmetric(vertical: 8),
                          PriceWidget(
                            price: snap.data!.totalAmount.validate(),
                            textStyle: boldTextStyle(size: 12),
                            textAlign: TextAlign.end,
                          ).paddingSymmetric(vertical: 8),
                        ],
                      ),
                      TableRow(
                        children: [
                          Text(locale.lblDiscount, style: boldTextStyle(size: 12), textAlign: TextAlign.start).paddingSymmetric(vertical: 8),
                          PriceWidget(
                            price: snap.data!.discount.validate(),
                            textStyle: boldTextStyle(size: 12),
                            textAlign: TextAlign.end,
                          ).paddingSymmetric(vertical: 8),
                        ],
                      ),
                      TableRow(
                        children: [
                          Text(locale.lblAmountDue, style: boldTextStyle(size: 12), textAlign: TextAlign.start).paddingSymmetric(vertical: 8),
                          PriceWidget(
                            price: snap.data!.actualAmount.validate(),
                            textStyle: boldTextStyle(size: 12),
                            textAlign: TextAlign.end,
                          ).paddingSymmetric(vertical: 8),
                        ],
                      ),
                    ],
                  ).paddingAll(16),
                ),
              )
            ],
          );
        }
        return snapWidgetHelper(snap, loadingWidget: LoaderWidget());
      },
    );
  }

  Widget clinicDetails({required PatientBillModule patientBillData}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${patientBillData.clinic!.name.validate()}', style: boldTextStyle()),
                4.height,
                RichTextWidget(
                  list: [
                    TextSpan(text: locale.lblInvoiceId + ': ', style: boldTextStyle(size: 12)),
                    TextSpan(text: '#${patientBillData.id.validate()} ', style: primaryTextStyle(size: 12)),
                  ],
                ),
                4.height,
                RichTextWidget(
                  list: [
                    TextSpan(text: locale.lblCreatedAt + ': ', style: boldTextStyle(size: 12)),
                    TextSpan(
                      text: '${patientBillData.createdAt.validate()} ',
                      style: primaryTextStyle(size: 12),
                    ),
                  ],
                ),
              ],
            ).expand(),
            12.width,
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('${patientBillData.clinic!.city.validate()}', style: primaryTextStyle(size: 14)),
                2.height,
                Text('${patientBillData.clinic!.country.validate()}', style: primaryTextStyle(size: 14)),
                2.height,
                Text('${patientBillData.clinic!.email.validate()} ', style: primaryTextStyle(size: 14)),
                2.height,
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(locale.lblPaymentStatus + ': ', style: primaryTextStyle(size: 14)).expand(),
                    StatusWidget(status: patientBillData.paymentStatus == 'paid' ? '1' : '0', isPaymentStatus: true),
                  ],
                ),
              ],
            ).expand(),
          ],
        ),
      ],
    );
  }

  Widget patientDetails({required PatientBillModule patientBillData}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichTextWidget(
          list: [
            TextSpan(text: locale.lblPatientName + ': ', style: boldTextStyle(size: 12)),
            TextSpan(text: '${patientBillData.patient!.displayName.validate()}', style: primaryTextStyle(size: 12)),
          ],
        ),
        6.height,
        RichTextWidget(
          list: [
            TextSpan(text: locale.lblGender2 + ': ', style: boldTextStyle(size: 12)),
            TextSpan(text: '${patientBillData.patient!.gender.validate().capitalizeFirstLetter()}', style: primaryTextStyle(size: 12)),
          ],
        ),
        6.height,
        RichTextWidget(
          list: [
            TextSpan(text: locale.lblDOB + ': ', style: boldTextStyle(size: 12)),
            TextSpan(text: '${patientBillData.patient?.dob.validate()}', style: primaryTextStyle(size: 12)),
          ],
        ),
      ],
    );
  }

  Widget servicesDetails({required PatientBillModule patientBillData}) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 8, bottom: 10, right: 8),
            decoration: boxDecorationDefault(color: context.cardColor, borderRadius: BorderRadius.circular(4)),
            child: Row(
              children: [
                Text(locale.lblSRNo, style: boldTextStyle(size: 12), textAlign: TextAlign.center).fit(fit: BoxFit.none).expand(),
                Text(locale.lblItemName, style: boldTextStyle(size: 12), textAlign: TextAlign.start).fit(fit: BoxFit.none).expand(flex: 2),
                Text(locale.lblPRICE, style: boldTextStyle(size: 12), textAlign: TextAlign.center).fit(fit: BoxFit.none).expand(),
                Text(locale.lblQUANTITY, style: boldTextStyle(size: 12), textAlign: TextAlign.start).fit(fit: BoxFit.none).expand(),
                Text(locale.lblTOTAL, style: boldTextStyle(size: 12), textAlign: TextAlign.end).fit(fit: BoxFit.none).expand(flex: 1),
              ],
            ),
          ),
          16.height,
          if (patientBillData.billItems.validate().isNotEmpty)
            ListView.separated(
              shrinkWrap: true,
              itemCount: patientBillData.billItems!.length,
              physics: NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                BillItem data = patientBillData.billItems![index];
                int total = data.price.validate().toInt() * data.qty.validate().toInt();
                return Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Row(children: [
                    Text('${index + 1}', style: primaryTextStyle(size: 12), textAlign: TextAlign.center).expand(),
                    Text('${data.label.validate()}', style: primaryTextStyle(size: 12), textAlign: TextAlign.start).expand(flex: 1),
                    Text('${appStore.currencyPrefix.validate(value: '')}${data.price.validate()}${appStore.currencyPostfix.validate(value: '')}',
                            style: primaryTextStyle(size: 12), textAlign: TextAlign.center)
                        .expand(),
                    Text('${data.qty.validate()}', style: primaryTextStyle(size: 12), textAlign: TextAlign.center),
                    Text('${appStore.currencyPrefix.validate(value: '')}$total${appStore.currencyPostfix.validate(value: '')}', style: primaryTextStyle(size: 12), textAlign: TextAlign.end)
                        .expand(flex: 1),
                  ]),
                );
              },
              separatorBuilder: (context, index) {
                return Divider(color: viewLineColor);
              },
            )
          else
            NoDataWidget(titleTextStyle: secondaryTextStyle(color: Colors.red), title: locale.lblNoRecordsFound),
        ],
      ),
    );
  }
}
