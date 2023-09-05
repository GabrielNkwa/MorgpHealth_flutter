import 'package:flutter/material.dart';
import 'package:kivicare_flutter/components/app_setting_widget.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/screens/doctor/screens/holiday/holiday_list_screen.dart';
import 'package:kivicare_flutter/screens/doctor/screens/service/service_list_screen.dart';
import 'package:kivicare_flutter/screens/doctor/screens/sessions/doctor_session_list_screen.dart';
import 'package:kivicare_flutter/screens/encounter/screen/encounter_list_screen.dart';
import 'package:kivicare_flutter/screens/patient/screens/my_bill_records_screen.dart';
import 'package:kivicare_flutter/screens/patient/screens/review/rating_view_all_screen.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:kivicare_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

class DoctorReceptionistGeneralSettingComponent extends StatelessWidget {
  const DoctorReceptionistGeneralSettingComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.start,
      spacing: 16,
      runSpacing: 16,
      children: [
        AppSettingWidget(
          name: locale.lblServices,
          image: ic_services,
          widget: ServiceListScreen(),
          subTitle: locale.lblServicesYouProvide,
        ),
        AppSettingWidget(
          name: locale.lblHoliday,
          image: ic_holiday,
          widget: HolidayScreen(),
          subTitle: locale.lblScheduledHolidays,
        ),
        AppSettingWidget(
          name: locale.lblSessions,
          image: ic_calendar,
          widget: DoctorSessionListScreen(),
          subTitle: locale.lblAvailableSession,
        ),
        AppSettingWidget(
          name: locale.lblEncounters,
          image: ic_services,
          widget: EncounterListScreen(),
          subTitle: locale.lblYourAllEncounters,
        ),
        AppSettingWidget(
          name: locale.lblBillingRecords,
          image: ic_bill,
          widget: MyBillRecordsScreen(),
          subTitle: locale.lblGetYourAllBillsHere,
        ),
        if (isProEnabled() && isDoctor())
          AppSettingWidget(
            name: locale.lblRatingsAndReviews,
            image: ic_rateUs,
            widget: RatingViewAllScreen(doctorId: userStore.userId.validate()),
            subTitle: locale.lblWhatYourCustomersSaysAboutYou,
          ),
      ],
    );
  }
}
