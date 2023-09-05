import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:kivicare_flutter/components/loader_widget.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/patient_bill_model.dart';
import 'package:kivicare_flutter/network/bill_repository.dart';
import 'package:kivicare_flutter/screens/doctor/screens/add_bill_item_screen.dart';
import 'package:kivicare_flutter/utils/app_common.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../../model/encounter_model.dart';

// ignore: must_be_immutable
class GenerateBillScreen extends StatefulWidget {
  EncounterModel data;

  GenerateBillScreen({required this.data});

  @override
  _GenerateBillScreenState createState() => _GenerateBillScreenState();
}

class _GenerateBillScreenState extends State<GenerateBillScreen> {
  Future<PatientBillModule?>? future;

  late EncounterModel patientEncounterData;

  TextEditingController totalCont = TextEditingController();
  TextEditingController discountCont = TextEditingController(text: '0');
  TextEditingController payableCont = TextEditingController();

  double payableText = 0;
  int? paymentStatusValue;

  bool forEncounterFromList = false;

  List<BillItem> billItemData = [];

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    patientEncounterData = widget.data;

    if (patientEncounterData.paymentStatus != null) {
      paymentStatusValue = patientEncounterData.paymentStatus.toInt();
    }
    if (patientEncounterData.billId != null) {
      appStore.setLoading(true);
      future = getBillDetailsAPI(encounterId: patientEncounterData.encounterId.toInt())?.then((value) {
        paymentStatusValue = value?.paymentStatus == 'paid' ? 1 : 0;
        totalCont.text = value!.totalAmount.validate().toString();
        payableCont.text = value.actualAmount.validate().toString();
        discountCont.text = value.discount.validate();

        appStore.setLoading(false);
        setState(() {});
        return value;
      }).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString());
        throw e;
      });
    }
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void saveFrom() {
    if (billItemData.isNotEmpty) {
      appStore.setLoading(true);
      Map<String, dynamic> request = {
        "id": "${patientEncounterData.billId == null ? "" : patientEncounterData.billId}",
        "encounter_id": "${patientEncounterData.encounterId == null ? "" : patientEncounterData.encounterId}",
        "appointment_id": "${patientEncounterData.appointmentId == null ? "" : patientEncounterData.appointmentId}",
        "total_amount": "${totalCont.text.validate()}",
        "discount": discountCont.text.validate().isEmptyOrNull ? '0' : discountCont.text.validate(),
        "actual_amount": "${payableCont.text.validate()}",
        "payment_status": paymentStatusValue == 0 ? "unpaid" : "paid",
        "billItems": billItemData,
      };

      log(request);

      addPatientBillAPI(request).then((value) {
        appStore.setLoading(false);
        toast(value.message);

        finish(context, paymentStatusValue == 1 ? "paid" : "unpaid");
      }).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString());
        throw e;
      });

      appStore.setLoading(false);
    } else {
      toast(locale.lblAtLeastSelectOneBillItem);
    }
  }

  void getTotal() {
    payableText = 0;
    paymentStatusValue = 0;

    billItemData.forEach((element) {
      payableText += (element.price.validate().toDouble() * element.qty.validate().toInt());
    });

    totalCont.text = payableText.toString();
    payableCont.text = payableText.round().toString();

    setTotalPayable(discountCont.text);
  }

  void setTotalPayable(String v) {
    double discount = double.parse(v);
    if (v.isNotEmpty) {
      payableCont.text = "${payableText - discount}";
    }
    if (v.trim().isEmpty) {
      payableCont.text = payableText.toString();
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        locale.lblGenerateInvoice,
        textColor: Colors.white,
        systemUiOverlayStyle: defaultSystemUiOverlayStyle(context),
        actions: [
          TextIcon(
            text: locale.lblAddBillItem.toUpperCase(),
            textStyle: boldTextStyle(color: Colors.white),
            prefix: Icon(Icons.add, color: white, size: 18),
          ).paddingOnly(right: 16, left: 8).onTap(
            () async {
              bool? res = await AddBillItemScreen(billId: patientEncounterData.billId.toInt(), billItem: billItemData, doctorId: patientEncounterData.doctorId.toInt()).launch(context);
              if (res ?? false) {
                getTotal();
                setState(() {});
              }
            },
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
        ],
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedScrollView(
            listAnimationType: ListAnimationType.None,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(locale.lblNote + " : " + locale.lblSwipeMassage, style: secondaryTextStyle(size: 10, color: appSecondaryColor)).paddingLeft(4),
              8.height,
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                decoration: boxDecorationDefault(
                  color: appStore.isDarkModeOn ? cardDarkColor : selectedColor,
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(8), topRight: Radius.circular(8)),
                ),
                child: Row(
                  children: [
                    Text(locale.lblSRNo, style: boldTextStyle(size: 12, color: primaryColor), textAlign: TextAlign.center).fit(fit: BoxFit.none).expand(),
                    Text("${locale.lblSERVICES}", style: boldTextStyle(size: 12, color: primaryColor), textAlign: TextAlign.start).fit(fit: BoxFit.none).expand(flex: 1),
                    Text("         " + locale.lblPRICE, style: boldTextStyle(size: 12, color: primaryColor), textAlign: TextAlign.end).fit(fit: BoxFit.none).expand(),
                    Text("      " + locale.lblQUANTITY, style: boldTextStyle(size: 12, color: primaryColor), textAlign: TextAlign.end).fit(fit: BoxFit.none).expand(),
                    Text("      " + locale.lblTOTAL, style: boldTextStyle(size: 12, color: primaryColor), textAlign: TextAlign.end).fit(fit: BoxFit.none).expand(flex: 1),
                  ],
                ),
              ),
              if (patientEncounterData.billId == null && billItemData.isEmpty)
                NoDataWidget(
                  retryText: locale.lblAddBillItem,
                  onRetry: () {
                    AddBillItemScreen(billItem: billItemData, doctorId: patientEncounterData.doctorId.toInt()).launch(context).then((value) {
                      forEncounterFromList = true;
                      getTotal();
                      setState(() {});
                    });
                  },
                )
              else
                SnapHelperWidget(
                    future: future,
                    loadingWidget: Offstage(),
                    onSuccess: (data) {
                      if (data != null && billItemData.isEmpty) {
                        billItemData.addAll(data.billItems.validate());
                        getTotal();
                      }
                      return Container(
                        constraints: BoxConstraints(maxHeight: context.height() * 0.46),
                        padding: EdgeInsets.symmetric(vertical: 16),
                        decoration: boxDecorationDefault(
                          color: context.cardColor,
                          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: billItemData.length,
                          itemBuilder: (context, index) {
                            BillItem data = billItemData[index];
                            int total = data.price.validate().toInt() * data.qty.validate().toInt();

                            return Slidable(
                              endActionPane: ActionPane(
                                extentRatio: 0.2,
                                motion: ScrollMotion(),
                                children: [
                                  Icon(
                                    Icons.remove,
                                    color: Colors.grey,
                                    size: 16,
                                  ).paddingAll(4).onTap(() {
                                    int qn = data.qty.toInt();
                                    if (qn > 0) {
                                      qn--;
                                    }
                                    if (qn > 0) {
                                      data.qty = qn.toString();
                                    }
                                    if (qn == 0) {
                                      billItemData.remove(data);
                                    }
                                    getTotal();

                                    setState(() {});
                                  }),
                                  Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 16,
                                  ).paddingSymmetric(horizontal: 8, vertical: 2).onTap(
                                    () {
                                      billItemData.remove(data);
                                      paymentStatusValue = 0;
                                      getTotal();
                                      setState(() {});
                                    },
                                    splashColor: Colors.transparent,
                                    highlightColor: Colors.transparent,
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Text('${index + 1}', style: primaryTextStyle(size: 12), textAlign: TextAlign.center).expand(),
                                  Text(
                                    '${data.label.validate()}',
                                    style: primaryTextStyle(size: 12),
                                    textAlign: TextAlign.left,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ).expand(flex: 2),
                                  Text(
                                    '${appStore.currencyPrefix.validate(value: appStore.currency.validate())}${data.price.validate()}${appStore.currencyPostfix.validate(value: '')}',
                                    style: primaryTextStyle(size: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.start,
                                  ).paddingRight(8).expand(),
                                  Text('${data.qty.validate()}', style: primaryTextStyle(size: 12), textAlign: TextAlign.center).expand(),
                                  Text(
                                    '${appStore.currencyPrefix.validate(value: appStore.currency.validate())}$total${appStore.currencyPostfix.validate(value: '')}',
                                    style: primaryTextStyle(size: 12),
                                    textAlign: TextAlign.center,
                                  ).paddingRight(8).expand(flex: 1),
                                ],
                              ),
                            );
                          },
                          separatorBuilder: (context, index) {
                            return Divider(color: viewLineColor);
                          },
                        ),
                      );
                    }),
              if (forEncounterFromList && billItemData.isNotEmpty)
                Container(
                  constraints: BoxConstraints(maxHeight: context.height() * 0.46),
                  padding: EdgeInsets.symmetric(vertical: 16),
                  decoration: boxDecorationDefault(
                    color: context.cardColor,
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(8), bottomRight: Radius.circular(8)),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: billItemData.length,
                    itemBuilder: (context, index) {
                      BillItem data = billItemData[index];
                      int total = data.price.validate().toInt() * data.qty.validate().toInt();

                      return Slidable(
                        endActionPane: ActionPane(
                          extentRatio: 0.2,
                          motion: ScrollMotion(),
                          children: [
                            Icon(
                              Icons.remove,
                              color: Colors.grey,
                              size: 16,
                            ).paddingAll(4).onTap(() {
                              int qn = data.qty.toInt();
                              if (qn > 0) {
                                qn--;
                              }
                              if (qn > 0) {
                                data.qty = qn.toString();
                              }
                              if (qn == 0) {
                                billItemData.remove(data);
                              }
                              getTotal();

                              setState(() {});
                            }),
                            Icon(
                              Icons.delete,
                              color: Colors.red,
                              size: 16,
                            ).paddingSymmetric(horizontal: 8, vertical: 2).onTap(
                              () {
                                billItemData.remove(data);
                                paymentStatusValue = 0;
                                getTotal();
                                setState(() {});
                              },
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Text('${index + 1}', style: primaryTextStyle(size: 12), textAlign: TextAlign.center).expand(),
                            Text(
                              '${data.label.validate()}',
                              style: primaryTextStyle(size: 12),
                              textAlign: TextAlign.left,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ).expand(flex: 2),
                            Text(
                              '${appStore.currencyPrefix.validate(value: appStore.currency.validate())}${data.price.validate()}${appStore.currencyPostfix.validate(value: '')}',
                              style: primaryTextStyle(size: 12),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.start,
                            ).paddingRight(8).expand(),
                            Text('${data.qty.validate()}', style: primaryTextStyle(size: 12), textAlign: TextAlign.center).expand(),
                            Text(
                              '${appStore.currencyPrefix.validate(value: appStore.currency.validate())}$total${appStore.currencyPostfix.validate(value: '')}',
                              style: primaryTextStyle(size: 12),
                              textAlign: TextAlign.center,
                            ).paddingRight(8).expand(flex: 1),
                          ],
                        ),
                      );
                    },
                    separatorBuilder: (context, index) {
                      return Divider(color: viewLineColor);
                    },
                  ),
                )
            ],
          ).paddingAll(16),
          Positioned(
            bottom: 90,
            right: 16,
            left: 16,
            child: Container(
              padding: EdgeInsets.all(16),
              width: context.width(),
              decoration: boxDecorationDefault(
                borderRadius: radius(),
                color: context.cardColor,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(locale.lblTotal, style: secondaryTextStyle()),
                      Spacer(),
                      Text("${appStore.currencyPrefix.validate(value: appStore.currency.validate(value: ''))}${totalCont.text.toString()}${appStore.currencyPostfix.validate(value: '')}",
                          style: boldTextStyle(), textAlign: TextAlign.right),
                    ],
                  ),
                  16.height,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(locale.lblDiscount, style: secondaryTextStyle()),
                      Spacer(),
                      Container(
                        child: AppTextField(
                          controller: discountCont,
                          textFieldType: TextFieldType.PHONE,
                          keyboardType: TextInputType.number,
                          isValidationRequired: false,
                          textAlign: TextAlign.end,
                          decoration: inputDecoration(context: context, labelText: '').copyWith(filled: true, fillColor: context.scaffoldBackgroundColor),
                          onChanged: setTotalPayable,
                          onFieldSubmitted: setTotalPayable,
                        ),
                      ).expand(),
                    ],
                  ),
                  16.height,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(locale.lblPayableAmount, style: secondaryTextStyle()),
                      Spacer(),
                      Text("${appStore.currencyPrefix.validate(value: appStore.currency.validate(value: ''))}${payableCont.text.toString()}${appStore.currencyPostfix.validate(value: '')}",
                          style: boldTextStyle(), textAlign: TextAlign.right),
                    ],
                  ),
                  16.height,
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(locale.lblPaymentStatus, style: secondaryTextStyle()),
                      Spacer(),
                      TextIcon(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            builder: (context) {
                              return Container(
                                padding: EdgeInsets.all(16),
                                color: context.scaffoldBackgroundColor,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      height: 5,
                                      width: 40,
                                      decoration: boxDecorationDefault(color: context.primaryColor, borderRadius: radius()),
                                    ).center(),
                                    32.height,
                                    Text(locale.lblPaymentStatus, style: boldTextStyle()),
                                    16.height,
                                    Column(
                                      children: [
                                        RadioListTile(
                                          value: 1,
                                          contentPadding: EdgeInsets.zero,
                                          groupValue: paymentStatusValue,
                                          title: Text(locale.lblPaid),
                                          selectedTileColor: context.cardColor,
                                          onChanged: (int? newValue) {
                                            paymentStatusValue = newValue.validate();
                                            setState(() {});
                                            finish(context);
                                          },
                                          activeColor: primaryColor,
                                          selected: true,
                                        ),
                                        RadioListTile(
                                          value: 0,
                                          contentPadding: EdgeInsets.zero,
                                          groupValue: paymentStatusValue,
                                          selectedTileColor: context.cardColor,
                                          title: Text(locale.lblUnPaid),
                                          onChanged: (int? newValue) {
                                            paymentStatusValue = newValue.validate();
                                            setState(() {});

                                            finish(context);
                                          },
                                          activeColor: primaryColor,
                                          selected: true,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                        spacing: 0,
                        suffix: Icon(Icons.arrow_drop_down_outlined, color: primaryColor),
                        textStyle: boldTextStyle(color: paymentStatusValue != null ? primaryColor : textPrimaryColorGlobal, size: 14),
                        text: paymentStatusValue != null
                            ? paymentStatusValue == 0
                                ? locale.lblUnPaid
                                : locale.lblPaid
                            : '${locale.lblSelect} ${locale.lblPaymentStatus}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Positioned(
              bottom: 16,
              right: 16,
              left: 16,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppButton(
                    color: context.scaffoldBackgroundColor,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    shapeBorder: RoundedRectangleBorder(side: BorderSide(color: context.primaryColor), borderRadius: radius()),
                    onTap: () {
                      finish(context);
                    },
                    child: Text(locale.lblCancel.toUpperCase(), style: boldTextStyle(color: context.primaryColor)),
                  ),
                  16.width,
                  AppButton(
                    color: appStore.isDarkModeOn ? cardDarkColor : appSecondaryColor,
                    child: Text(locale.lblSave.toUpperCase(), style: boldTextStyle(color: Colors.white)),
                    onTap: () async {
                      if (paymentStatusValue != null) {
                        if (appStore.isLoading) return;
                        appStore.setLoading(true);

                        saveFrom();
                      } else {
                        toast(locale.lblPleaseSelectPaymentStatus);
                      }
                    },
                  ).expand(flex: 3),
                ],
              )),
          Observer(builder: (context) {
            return LoaderWidget().visible(appStore.isLoading).center();
          })
        ],
      ),
    );
  }
}
