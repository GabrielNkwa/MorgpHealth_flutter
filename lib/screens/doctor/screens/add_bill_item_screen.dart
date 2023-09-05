import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/patient_bill_model.dart';
import 'package:kivicare_flutter/model/service_model.dart';
import 'package:kivicare_flutter/network/service_repository.dart';
import 'package:kivicare_flutter/utils/app_common.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:kivicare_flutter/utils/constants.dart';
import 'package:nb_utils/nb_utils.dart';

class AddBillItemScreen extends StatefulWidget {
  List<BillItem>? billItem;
  final int? billId;
  final int? doctorId;

  AddBillItemScreen({this.billItem, this.billId, this.doctorId});

  @override
  _AddBillItemScreenState createState() => _AddBillItemScreenState();
}

class _AddBillItemScreenState extends State<AddBillItemScreen> {
  AsyncMemoizer<ServiceListModel> _memorizer = AsyncMemoizer();

  GlobalKey<FormState> formKey = GlobalKey();

  ServiceData? serviceData;
  TextEditingController priceCont = TextEditingController();
  TextEditingController quantityCont = TextEditingController();
  TextEditingController totalCont = TextEditingController();

  bool isFirstTime = true;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    setStatusBarColor(appPrimaryColor, statusBarIconBrightness: Brightness.light);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget body() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Form(
        key: formKey,
        autovalidateMode: isFirstTime ? AutovalidateMode.disabled : AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            FutureBuilder<ServiceListModel>(
              future: isDoctor() ? _memorizer.runOnce(() => getServiceResponseAPI(doctorId: getIntAsync(USER_ID))) : _memorizer.runOnce(() => getServiceResponseAPI(doctorId: widget.doctorId)),
              builder: (_, snap) {
                if (snap.hasData) {
                  if (snap.data != null && snap.data!.serviceData!.validate().isNotEmpty) {
                    snap.data!.serviceData!.validate().removeWhere((element) => element.name.isEmptyOrNull);
                  }
                  return Column(
                    children: [
                      DropdownButtonFormField<ServiceData>(
                        dropdownColor: context.cardColor,
                        borderRadius: radius(),
                        decoration: inputDecoration(
                          context: context,
                          labelText: locale.lblSelectServices,
                        ),
                        validator: (v) {
                          if (v == null) return locale.lblServiceIsRequired;
                          return null;
                        },
                        items: snap.data!.serviceData!.map((e) => DropdownMenuItem(child: Text(e.name.validate(), style: primaryTextStyle()), value: e)).toList(),
                        onChanged: (ServiceData? e) {
                          serviceData = e;
                          priceCont.text = e!.charges.validate();
                          quantityCont.text = locale.lblOne;
                          totalCont.text = "${e.charges.toInt() * quantityCont.text.toInt()}";
                        },
                      ),
                      16.height,
                      AppTextField(
                        controller: priceCont,
                        textFieldType: TextFieldType.PHONE,
                        decoration: inputDecoration(context: context, labelText: locale.lblPrice),
                        onChanged: (s) {
                          totalCont.text = "${s.toInt() * quantityCont.text.toInt()}";
                        },
                      ),
                      16.height,
                      AppTextField(
                        controller: quantityCont,
                        textFieldType: TextFieldType.PHONE,
                        keyboardType: TextInputType.number,
                        decoration: inputDecoration(context: context, labelText: locale.lblQuantity),
                        onChanged: (s) {
                          totalCont.text = "${priceCont.text.toInt() * s.toInt()}";
                        },
                      ),
                      16.height,
                      AppTextField(
                        controller: totalCont,
                        textFieldType: TextFieldType.PHONE,
                        decoration: inputDecoration(context: context, labelText: locale.lblTotal),
                        readOnly: true,
                      ),
                    ],
                  );
                }
                return snapWidgetHelper(snap).center();
              },
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(locale.lblAddBillItem, textColor: Colors.white, systemUiOverlayStyle: defaultSystemUiOverlayStyle(context)),
      body: body(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.done),
        onPressed: () {
          if (formKey.currentState!.validate()) {
            formKey.currentState!.save();

            bool isAlreadyExist = widget.billItem.validate().any((element) => element.itemId.validate() == serviceData!.id.validate());

            if (isAlreadyExist) {
              int alreadyExistId = widget.billItem.validate().indexWhere((element) => element.itemId.validate() == serviceData!.id.validate());
              widget.billItem.validate()[alreadyExistId].qty = (widget.billItem.validate()[alreadyExistId].qty.toInt() + quantityCont.text.validate().toInt()).toString();
            } else {
              widget.billItem!.add(
                BillItem(
                  id: "",
                  label: serviceData!.name.validate(),
                  billId: widget.billId.validate().toString(),
                  itemId: serviceData!.id.validate(),
                  qty: quantityCont.text.validate(),
                  price: priceCont.text.validate(),
                ),
              );
            }

            finish(context, true);
          } else {
            isFirstTime = !isFirstTime;
            setState(() {});
          }
        },
      ),
    );
  }
}
