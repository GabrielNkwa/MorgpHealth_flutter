import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:nb_utils/nb_utils.dart';

class AddressWidget extends StatefulWidget {
  @override
  State<AddressWidget> createState() => _AddressWidgetState();
}

class _AddressWidgetState extends State<AddressWidget> {
  TextEditingController addressCont = TextEditingController();
  TextEditingController countryCont = TextEditingController();
  TextEditingController cityCont = TextEditingController();
  TextEditingController postalCodeCont = TextEditingController();

  FocusNode addressFocus = FocusNode();
  FocusNode cityFocus = FocusNode();
  FocusNode countryFocus = FocusNode();
  FocusNode postalCodeFocus = FocusNode();
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(locale.lblAddressDetail, style: boldTextStyle(color: context.primaryColor, size: 18)),
        Divider(color: viewLineColor),
        Wrap(
          runSpacing: 16,
          children: [
            AppTextField(
              controller: addressCont,
              focus: addressFocus,
              nextFocus: cityFocus,
              textInputAction: TextInputAction.next,
              isValidationRequired: false,
              textFieldType: TextFieldType.MULTILINE,
              minLines: 2,
              maxLines: 4,
              decoration: inputDecoration(context: context, labelText: locale.lblAddress).copyWith(alignLabelWithHint: true),
            ),
            Row(
              children: [
                AppTextField(
                  controller: countryCont,
                  focus: countryFocus,
                  nextFocus: cityFocus,
                  textFieldType: TextFieldType.OTHER,
                  decoration: inputDecoration(context: context, labelText: locale.lblCountry),
                ).expand(),
                16.width,
                AppTextField(
                  controller: cityCont,
                  focus: cityFocus,
                  textInputAction: TextInputAction.next,
                  nextFocus: postalCodeFocus,
                  textFieldType: TextFieldType.OTHER,
                  decoration: inputDecoration(context: context, labelText: locale.lblCity),
                ).expand(),
              ],
            ),
            AppTextField(
              controller: postalCodeCont,
              focus: postalCodeFocus,
              textInputAction: TextInputAction.done,
              textFieldType: TextFieldType.OTHER,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // Only allows digits
              ],
              decoration: inputDecoration(context: context, labelText: locale.lblPostalCode),
            ),
          ],
        ).paddingTop(8)
      ],
    );
  }
}
