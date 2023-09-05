import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/demo_login_model.dart';
import 'package:kivicare_flutter/model/upcoming_appointment_model.dart';
import 'package:kivicare_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

List<LanguageDataModel> languageList() {
  return [
    LanguageDataModel(id: 0, name: locale.lblEnglish, languageCode: 'en', fullLanguageCode: 'en-US', flag: flagsIcUs),
    LanguageDataModel(id: 1, name: locale.lblArabic, languageCode: 'ar', fullLanguageCode: 'ar-AR', flag: flagsIcAr),
    LanguageDataModel(id: 2, name: locale.lblHindi, languageCode: 'hi', fullLanguageCode: 'hi-IN', flag: flagsIcIndia),
    LanguageDataModel(id: 3, name: locale.lblGerman, languageCode: 'de', fullLanguageCode: 'de-DE', flag: flagsIcGermany),
    LanguageDataModel(id: 4, name: locale.lblFrench, languageCode: 'fr', fullLanguageCode: 'fr-FR', flag: flagsIcFrench),
  ];
}

List<DemoLoginModel> demoLoginList() {
  List<DemoLoginModel> demoLoginListData = [];
  demoLoginListData.add(DemoLoginModel(loginTypeImage: "images/icons/user.png"));
  demoLoginListData.add(DemoLoginModel(loginTypeImage: "images/icons/receptionistIcon.png"));
  demoLoginListData.add(DemoLoginModel(loginTypeImage: "images/icons/doctorIcon.png"));

  return demoLoginListData;
}

List<WeeklyAppointment> emptyGraphListMonthly = [
  WeeklyAppointment(x: "W1", y: 0),
  WeeklyAppointment(x: "W2", y: 0),
  WeeklyAppointment(x: "W3", y: 0),
  WeeklyAppointment(x: "W4", y: 0),
  WeeklyAppointment(x: "W5", y: 0),
];

List<WeeklyAppointment> emptyGraphListYearly = [
  WeeklyAppointment(x: locale.lblJan, y: 0),
  WeeklyAppointment(x: locale.lblFeb, y: 0),
  WeeklyAppointment(x: locale.lblMar, y: 0),
  WeeklyAppointment(x: locale.lblApr, y: 0),
  WeeklyAppointment(x: locale.lblMay, y: 0),
  WeeklyAppointment(x: locale.lblJun, y: 0),
  WeeklyAppointment(x: locale.lblJul, y: 0),
  WeeklyAppointment(x: locale.lblAug, y: 0),
  WeeklyAppointment(x: locale.lblSep, y: 0),
  WeeklyAppointment(x: locale.lblOct, y: 0),
  WeeklyAppointment(x: locale.lblNov, y: 0),
  WeeklyAppointment(x: locale.lblDec, y: 0),
];
