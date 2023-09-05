import 'package:flutter/material.dart';
import 'package:kivicare_flutter/components/image_border_component.dart';
import 'package:kivicare_flutter/model/user_model.dart';
import 'package:kivicare_flutter/screens/receptionist/screens/doctor/doctor_details_screen.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

import 'package:kivicare_flutter/main.dart';

class DoctorListComponent extends StatelessWidget {
  final UserModel data;
  final bool isSelected;
  final VoidCallback? callForRefreshAfterDelete;

  DoctorListComponent({required this.data, this.isSelected = false, this.callForRefreshAfterDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width() - 32,
      decoration: boxDecorationDefault(
        borderRadius: radius(),
        color: context.cardColor,
        border: Border.all(color: isSelected ? context.primaryColor : context.cardColor),
      ),
      child: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              data.profileImage.validate().isEmptyOrNull
                  ? GradientBorder(
                      gradient: LinearGradient(colors: [primaryColor, appSecondaryColor], tileMode: TileMode.mirror),
                      strokeWidth: 2,
                      borderRadius: 42,
                      child: PlaceHolderWidget(
                        shape: BoxShape.circle,
                        height: 40,
                        width: 40,
                        alignment: Alignment.center,
                        child: Text(data.displayName.validate(value: 'D')[0].capitalizeFirstLetter(), style: boldTextStyle(color: Colors.black)),
                      ),
                    )
                  : ImageBorder(height: 40, src: data.profileImage.validate()).paddingTop(8),
              16.width,
              AnimatedWrap(
                runSpacing: 6,
                listAnimationType: ListAnimationType.None,
                crossAxisAlignment: WrapCrossAlignment.start,
                children: [
                  SettingItemWidget(
                    title: "Dr. " + data.displayName.validate(),
                    padding: EdgeInsets.zero,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                  ).paddingTop(6),
                  if (data.specialties.validate().isNotEmpty)
                    SettingItemWidget(
                      title: data.getDoctorSpeciality,
                      titleTextStyle: secondaryTextStyle(),
                      padding: EdgeInsets.zero,
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                    ).paddingTop(4),
                  if (data.noOfExperience.validate().toInt() != 0) Text("${data.noOfExperience.validate()} ${locale.lblYearsOfExperience}", maxLines: 2, style: secondaryTextStyle(size: 14)),
                ],
              ).expand(),
            ],
          ).paddingSymmetric(horizontal: 16, vertical: 12),
          Positioned(
            top: 6,
            right: 12,
            child: AppButton(
              padding: EdgeInsets.zero,
              height: 28,
              width: 60,
              text: locale.lblViewDetails,
              shapeBorder: RoundedRectangleBorder(borderRadius: radius()),
              textStyle: secondaryTextStyle(color: Colors.white, size: 14),
              color: context.primaryColor,
              onTap: () {
                DoctorDetailScreen(
                  doctorData: data,
                  refreshCall: () {
                    callForRefreshAfterDelete?.call();
                  },
                ).launch(context, pageRouteAnimation: PageRouteAnimation.Fade, duration: 800.milliseconds).then(
                  (isDoctorDeleted) {
                    if (isDoctorDeleted ?? false) {
                      callForRefreshAfterDelete?.call();
                      finish(context);
                    }
                  },
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
