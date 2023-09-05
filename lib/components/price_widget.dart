import 'package:flutter/material.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:nb_utils/nb_utils.dart';

class PriceWidget extends StatelessWidget {
  final String price;
  final TextStyle? textStyle;
  final int? textSize;
  final Color? textColor;
  final String? postFix;
  final TextAlign? textAlign;

  PriceWidget({required this.price, this.textStyle, this.textAlign, this.textSize, this.postFix, this.textColor});

  @override
  Widget build(BuildContext context) {
    return Text(
      '${appStore.currencyPrefix.validate(value: appStore.currency.validate())}$price${appStore.currencyPostfix.validate(value: '')}',
      textAlign: textAlign,
      style: textStyle ?? boldTextStyle(size: textSize ?? textBoldSizeGlobal.toInt(), color: textColor ?? textPrimaryColorGlobal),
    );
  }
}
