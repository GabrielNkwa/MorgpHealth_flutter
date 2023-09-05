import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kivicare_flutter/components/app_bar_title_widget.dart';
import 'package:kivicare_flutter/components/dashboard_profile_widget.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/screens/doctor/fragments/patient_list_fragment.dart';
import 'package:kivicare_flutter/Fragments/setting_fragment.dart';
import 'package:kivicare_flutter/screens/receptionist/fragments/r_appointment_fragment.dart';
import 'package:kivicare_flutter/screens/receptionist/screens/doctor/doctor_list_screen.dart';
import 'package:kivicare_flutter/utils/app_common.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:kivicare_flutter/utils/constants.dart';
import 'package:kivicare_flutter/utils/extensions/string_extensions.dart';
import 'package:kivicare_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class RDashBoardScreen extends StatefulWidget {
  @override
  _RDashBoardScreenState createState() => _RDashBoardScreenState();
}

class _RDashBoardScreenState extends State<RDashBoardScreen> {
  int currentIndex = 0;

  double iconSize = 24;

  @override
  void initState() {
    super.initState();
    init();
  }

  init() async {
    afterBuildCreated(() {
      View.of(context).platformDispatcher.onPlatformBrightnessChanged = () {
        if (getIntAsync(THEME_MODE_INDEX) == THEME_MODE_SYSTEM) {
          appStore.setDarkMode(MediaQuery.of(context).platformBrightness == Brightness.light);
        }
      };
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  AppBar? buildAppBarWidget() {
    if (currentIndex == 3) return null;
    return appBarWidget(
      '',
      titleWidget: AppBarTitleWidget(),
      showBack: false,
      color: context.scaffoldBackgroundColor,
      elevation: 0,
      systemUiOverlayStyle: defaultSystemUiOverlayStyle(
        context,
        color: appStore.isDarkModeOn ? context.scaffoldBackgroundColor : appPrimaryColor.withOpacity(0.02),
        statusBarIconBrightness: appStore.isDarkModeOn ? Brightness.light : Brightness.dark,
      ),
      actions: [
        DashboardTopProfileWidget(refreshCallback: () => setState(() {})),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DoublePressBackWidget(
      child: Observer(builder: (context) {
        Color disableIconColor = appStore.isDarkModeOn ? Colors.white : secondaryTxtColor;
        return Scaffold(
          appBar: buildAppBarWidget(),
          body: Container(
            margin: EdgeInsets.only(top: currentIndex != 3 ? 16 : 0),
            child: [
              RAppointmentFragment(),
              PatientListFragment(),
              DoctorListScreen(),
              SettingFragment(),
            ][currentIndex],
          ),
          bottomNavigationBar: Blur(
            blur: 30,
            borderRadius: radius(0),
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                backgroundColor: context.primaryColor.withOpacity(0.02),
                indicatorColor: context.primaryColor.withOpacity(0.1),
                labelTextStyle: MaterialStateProperty.all(primaryTextStyle(size: 10)),
                surfaceTintColor: Colors.transparent,
                shadowColor: Colors.transparent,
              ),
              child: NavigationBar(
                height: 66,
                surfaceTintColor: context.scaffoldBackgroundColor,
                selectedIndex: currentIndex,
                backgroundColor: context.cardColor,
                animationDuration: 1000.milliseconds,
                destinations: [
                  NavigationDestination(
                    icon: Image.asset(ic_calendar, height: iconSize, width: iconSize, color: disableIconColor),
                    label: locale.lblAppointments,
                    selectedIcon: Image.asset(ic_calendar, height: iconSize, width: iconSize, color: primaryColor),
                  ),
                  NavigationDestination(
                    icon: Image.asset(ic_patient, height: iconSize, width: iconSize, color: disableIconColor),
                    label: locale.lblPatients,
                    selectedIcon: Image.asset(ic_patient, height: iconSize, width: iconSize, color: primaryColor),
                  ),
                  NavigationDestination(
                    icon: Image.asset(ic_doctorIcon, height: iconSize, width: iconSize, color: disableIconColor),
                    label: locale.lblDoctor.getApostropheString(apostrophe: false, count: 2),
                    selectedIcon: Image.asset(ic_doctorIcon, height: iconSize, width: iconSize, color: primaryColor),
                  ),
                  NavigationDestination(
                    icon: Image.asset(ic_more_item, height: iconSize, width: iconSize, color: disableIconColor),
                    label: locale.lblSettings,
                    selectedIcon: Image.asset(ic_more_item, height: iconSize, width: iconSize, color: primaryColor),
                  ),
                ],
                onDestinationSelected: (index) {
                  currentIndex = index;
                  setState(() {});
                },
              ),
            ),
          ),
        );
      }),
    );
  }
}
