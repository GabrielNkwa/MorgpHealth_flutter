import 'package:flutter/material.dart';
import 'package:kivicare_flutter/screens/doctor/screens/sessions/add_session_screen.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:kivicare_flutter/utils/extensions/string_extensions.dart';
import 'package:nb_utils/nb_utils.dart';

import 'package:kivicare_flutter/components/cached_image_widget.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/doctor_session_model.dart';
import 'package:kivicare_flutter/utils/images.dart';

class SessionWidget extends StatelessWidget {
  final SessionData data;
  final VoidCallback? callForRefresh;

  const SessionWidget({required this.data, this.callForRefresh});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: boxDecorationDefault(borderRadius: radius(), color: context.cardColor),
      margin: EdgeInsets.only(top: 8, bottom: 8),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: isReceptionist() ? 20 : 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (isReceptionist())
                data.doctorImage.validate().isNotEmpty
                    ? CachedImageWidget(
                        url: data.doctorImage.validate(),
                        height: 40,
                        width: 40,
                        fit: BoxFit.cover,
                        radius: 80,
                      )
                    : GradientBorder(
                        gradient: LinearGradient(colors: [primaryColor, appSecondaryColor], tileMode: TileMode.mirror),
                        strokeWidth: 2,
                        borderRadius: 80,
                        child: PlaceHolderWidget(
                          height: 40,
                          width: 40,
                          shape: BoxShape.circle,
                          alignment: Alignment.center,
                          child: Text('${data.doctors.validate(value: 'D')[0].capitalizeFirstLetter()}', style: boldTextStyle(size: 22, color: Colors.black)),
                        ),
                      ),
              if (isReceptionist()) 16.width,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (isReceptionist()) Text(data.doctors.validate().prefixText(value: "Dr. "), style: boldTextStyle()),
                  2.height,
                  if (!isReceptionist()) Text(data.clinicName.validate(), style: isReceptionist() ? secondaryTextStyle() : boldTextStyle()),
                  6.height,
                  Text(
                    '${data.days.validate().join(" - ")}'.toUpperCase(),
                    style: secondaryTextStyle(size: 12, color: context.primaryColor),
                  )
                ],
              ).expand(),
            ],
          ),
          16.height,
          Container(
            decoration: boxDecorationDefault(borderRadius: radius(), color: context.scaffoldBackgroundColor),
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ic_morning.iconImage(size: 18, color: Colors.orange).paddingOnly(top: 4),
                      12.width,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(locale.lblMorning, style: secondaryTextStyle()),
                          4.height,
                          Text(data.morningTime, style: boldTextStyle(size: 14)),
                        ],
                      ).expand(),
                    ],
                  ),
                ).expand(),
                8.width,
                Container(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ic_evening.iconImage(size: 18, color: Colors.red).paddingOnly(top: 4),
                      12.width,
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(locale.lblEvening, style: secondaryTextStyle()),
                          4.height,
                          Text(data.eveningTime, style: boldTextStyle(size: 14)),
                        ],
                      ).expand(),
                    ],
                  ),
                ).expand()
              ],
            ),
          ),
          if (isDoctor()) 8.height,
        ],
      ),
    ).onTap(
      () {
        AddSessionsScreen(sessionData: data).launch(context).then((value) {
          if (value ?? false) {
            callForRefresh?.call();
          }
        });
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
    );
  }
}
