import 'package:flutter/material.dart';
import 'package:kivicare_flutter/components/app_setting_widget.dart';
import 'package:kivicare_flutter/config.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/network/auth_repository.dart';
import 'package:kivicare_flutter/screens/about_us_screen.dart';
import 'package:kivicare_flutter/utils/app_common.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:kivicare_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:share/share.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SettingThirdPage extends StatelessWidget {
  const SettingThirdPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      children: [
        // AppSettingWidget(
        //   name: locale.lblTermsAndCondition,
        //   image: ic_termsAndCondition,
        //   subTitle: locale.lblTermsConditionSubTitle,
        //   onTap: () {
        //     launchUrlCustomTab(TERMS_AND_CONDITION_URL);
        //   },
        // ),
        // AppSettingWidget(
        //   name: locale.lblAboutUs,
        //   image: ic_aboutUs,
        //   widget: AboutUsScreen(),
        //   subTitle: "About MorpgHealth",
        // ),
        // AppSettingWidget(
        //   name: locale.lblRateUs,
        //   image: ic_rateUs,
        //   subTitle: locale.lblRateUsSubTitle,
        //   onTap: () async {
        //     commonLaunchUrl(playStoreBaseURL + await getPackageInfo().then((value) => value.packageName.validate()), launchMode: LaunchMode.externalApplication);
        //   },
        // ),
        // AppSettingWidget(
        //   image: ic_helpAndSupport,
        //   name: locale.lblHelpAndSupport,
        //   subTitle: locale.lblHelpAndSupportSubTitle,
        //   onTap: () {
        //     commonLaunchUrl(SUPPORT_URL);
        //   },
        // ),

        // AppSettingWidget(
        //   name: locale.lblShareKiviCare,
        //   image: ic_share,
        //   subTitle: locale.lblReachUsMore,
        //   onTap: () async {
        //     Share.share('${locale.lblShare} $APP_NAME app\n\n$playStoreBaseURL${await getPackageInfo().then((value) => value.packageName.validate())}');
        //   },
        // ),
        AppSettingWidget(
          name: locale.lblDeleteAccount,
          image: ic_delete_icon,
          subTitle: locale.lblDeleteAccountSubTitle,
          onTap: () async {
            showConfirmDialogCustom(
              context,
              customCenterWidget: Container(
                child: Stack(
                  children: [
                    defaultPlaceHolder(
                      context,
                      DialogType.DELETE,
                      136.0,
                      context.width(),
                      appSecondaryColor,
                      shape: RoundedRectangleBorder(borderRadius: radius()),
                    ),
                    Positioned(
                      left: 42,
                      bottom: 12,
                      right: 16,
                      child: Text(locale.lblDeleteAccountNote, style: secondaryTextStyle(size: 10, color: appSecondaryColor)),
                    )
                  ],
                ),
              ),
              dialogType: DialogType.DELETE,
              negativeText: locale.lblNo,
              positiveText: locale.lblYes,
              onAccept: (c) {
                ifNotTester(context, () {
                  appStore.setLoading(true);
                  deleteAccountPermanently().then((value) {
                    logout(isTokenExpired: true);
                  }).catchError((e) {
                    appStore.setLoading(false);
                    throw e;
                  });
                });
              },
              title: 'Do you want to delete account permanently?',
            );
          },
        ),
        AppSettingWidget(
          name: locale.lblLogout,
          subTitle: locale.lblThanksForVisiting,
          image: ic_logout,
          onTap: () async {
            showConfirmDialogCustom(
              context,
              primaryColor: primaryColor,
              negativeText: locale.lblCancel,
              positiveText: locale.lblYes,
              onAccept: (c) {
                appStore.setLoading(true);
                logout().catchError((e) {
                  appStore.setLoading(false);

                  throw e;
                });
              },
              title: locale.lblDoYouWantToLogout,
            );
          },
        ),
        AppSettingWidget(
          name: locale.lblAppVersion,
          image: ic_app_version,
          subTitle: packageInfo.versionName,
        ),
      ],
    );
  }
}
