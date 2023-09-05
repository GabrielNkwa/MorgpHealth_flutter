import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/upcoming_appointment_model.dart';
import 'package:kivicare_flutter/screens/appointment/components/appointment_widget.dart';
import 'package:nb_utils/nb_utils.dart';

class AppointmentFragmentAppointmentComponent extends StatelessWidget {
  final List<UpcomingAppointmentModel> data;
  final VoidCallback? refreshCallForRefresh;

  AppointmentFragmentAppointmentComponent({required this.data, this.refreshCallForRefresh});

  @override
  Widget build(BuildContext context) {
    return Observer(builder: (context) {
      return Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              listAnimationType: listAnimationType,
              itemCount: data.length,
              itemBuilder: (context, index) {
                return AppointmentWidget(
                  upcomingData: data[index],
                  refreshCall: () {
                    refreshCallForRefresh?.call();
                  },
                ).paddingSymmetric(vertical: 8);
              },
            )
          ],
        ),
      );
    });
  }
}
