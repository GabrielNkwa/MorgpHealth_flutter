import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kivicare_flutter/components/cached_image_widget.dart';
import 'package:kivicare_flutter/components/status_widget.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/screens/auth/screens/edit_profile_screen.dart';
import 'package:kivicare_flutter/utils/app_common.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:kivicare_flutter/utils/constants.dart';
import 'package:kivicare_flutter/utils/extensions/string_extensions.dart';
import 'package:kivicare_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class EditProfileComponent extends StatelessWidget {
  final VoidCallback? refreshCallback;
  EditProfileComponent({this.refreshCallback});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (userStore.profileImage.validate().isNotEmpty)
              GradientBorder(
                  borderRadius: 65,
                  padding: 2,
                  gradient: LinearGradient(colors: [viewLineColor, viewLineColor]),
                  child: CachedImageWidget(url: userStore.profileImage.validate(), height: 65, circle: true, fit: BoxFit.cover))
            else
              PlaceHolderWidget(
                shape: BoxShape.circle,
                height: 65,
                width: 65,
                border: Border.all(color: context.dividerColor, width: 2),
                alignment: Alignment.center,
                child: Text(userStore.firstName.validate(value: '')[0].capitalizeFirstLetter(), style: boldTextStyle(color: Colors.black, size: 20)),
              ),
            16.width,
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getRoleWiseName(name: "${userStore.firstName.validate()} ${userStore.lastName.validate()}"),
                  style: boldTextStyle(size: titleTextSize),
                ),
                2.height,
                Text(userStore.userEmail.validate(), style: secondaryTextStyle()),
              ],
            ).expand(),
            16.width,
            Container(
              padding: EdgeInsets.all(4),
              decoration: boxDecorationWithRoundedCorners(
                backgroundColor: appPrimaryColor,
                boxShape: BoxShape.circle,
                border: Border.all(color: white, width: 3),
              ),
              child: Image.asset(ic_edit, height: 20, width: 20, color: Colors.white),
            )
          ],
        ).onTap(
          () {
            EditProfileScreen().launch(context).then((value) {
              refreshCallback?.call();
            });
          },
          highlightColor: Colors.transparent,
          splashColor: Colors.transparent,
        ),
        if ((isReceptionist() || isPatient()) && userStore.userClinicName != null) Divider(height: 30),
        if ((isReceptionist() || isPatient()) && userStore.userClinicName != null)
          Observer(builder: (context) {
            return Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(userStore.userClinicName.validate(), style: primaryTextStyle()),
                    2.height,
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        ic_location.iconImage(size: 18).paddingOnly(top: 4, bottom: 4),
                        4.width,
                        Text(userStore.userClinicAddress.validate(), style: secondaryTextStyle()),
                      ],
                    )
                  ],
                ).expand(),
                StatusWidget(status: userStore.userClinicStatus.validate(), isClinicStatus: true)
              ],
            ).paddingSymmetric(vertical: 8);
          })
      ],
    );
  }
}
