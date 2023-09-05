import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class CommonRowWidget extends StatelessWidget {
  final String title;
  final Color? titleColor;
  final String value;
  final Color? valueColor;
  final int? valueSize;
  final int? titleSize;
  final bool isMarquee;

  CommonRowWidget({required this.title, required this.value, this.isMarquee = false, this.valueColor, this.titleColor, this.valueSize, this.titleSize});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FittedBox(
          alignment: Alignment.centerLeft,
          clipBehavior: Clip.antiAlias,
          fit: BoxFit.scaleDown,
          child: Text(title, style: secondaryTextStyle(size: valueSize ?? 14, color: titleColor), textAlign: TextAlign.center),
        ).expand(),
        4.width,
        (isMarquee
                ? Marquee(
                    child: Text(value, style: boldTextStyle(size: 14, color: valueColor)),
                  )
                : Text(value, style: boldTextStyle(color: valueColor, size: valueSize ?? textBoldSizeGlobal.toInt())))
            .expand(flex: 4),
      ],
    );
  }
}
