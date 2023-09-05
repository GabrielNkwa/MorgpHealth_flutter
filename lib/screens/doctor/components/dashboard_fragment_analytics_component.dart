import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/dashboard_model.dart';
import 'package:kivicare_flutter/screens/doctor/components/dashboard_count_widget.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

class DashboardFragmentAnalyticsComponent extends StatelessWidget {
  final DashboardModel data;
  DashboardFragmentAnalyticsComponent({required this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        40.height,
        AnimatedWrap(
          itemCount: 3,
          spacing: 14,
          listAnimationType: listAnimationType,
          itemBuilder: (context, index) {
            if (index == 0) {
              return DashBoardCountWidget(
                title: locale.lblTodayAppointments,
                color1: appSecondaryColor,
                count: data.upcomingAppointmentTotal.validate(),
                icon: FontAwesomeIcons.calendarCheck,
              );
            } else if (index == 1) {
              return DashBoardCountWidget(
                title: locale.lblTotalAppointment,
                color1: appPrimaryColor,
                count: data.totalAppointment.validate(),
                icon: FontAwesomeIcons.calendarCheck,
              );
            } else if (index == 2) {
              return DashBoardCountWidget(
                title: locale.lblTotalPatient,
                color1: appSecondaryColor,
                count: data.totalPatient.validate(),
                icon: FontAwesomeIcons.userInjured,
              );
            }

            return Offstage();
          },
        )
      ],
    ).paddingAll(16);
  }
}
