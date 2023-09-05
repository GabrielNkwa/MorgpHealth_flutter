import 'package:kivicare_flutter/main.dart';
import 'package:nb_utils/nb_utils.dart';

import '../model/upcoming_appointment_model.dart';

const DEMO_URL = 'https://kivicare-demo.iqonic.design/';

const DEFAULT_SERVICE_IMAGE_URL =
    'https://img.freepik.com/free-photo/orange-background_23-2147674307.jpg?w=900&t=st=1682404076~exp=1682404676~hmac=d2eaa5ed2910063112dbfa9cdfb15e1d967ac221b518ca7d1dd47f805ea3a7dd';

// ignore: non_constant_identifier_names
List<String> RTLLanguage = ['ar'];

List<WeeklyAppointment> emptyGraphList = [
  WeeklyAppointment(x: locale.lblMonday, y: 0),
  WeeklyAppointment(x: locale.lblTuesday, y: 0),
  WeeklyAppointment(x: locale.lblWednesday, y: 0),
  WeeklyAppointment(x: locale.lblThursday, y: 0),
  WeeklyAppointment(x: locale.lblFriday, y: 0),
  WeeklyAppointment(x: locale.lblSaturday, y: 0),
  WeeklyAppointment(x: locale.lblSunday, y: 0),
];

List<String> appointmentStatusList = [locale.lblAll, locale.lblLatest, locale.lblPending, locale.lblCompleted, locale.lblCancelled, locale.lblPast];

List<String> userRoles = [locale.lblDoctor, locale.lblClinic];

// Loader Size
double loaderSize = 30;

// EmailsWakelock

// local
const receptionistEmail = "calvin@kivicare.com";
const doctorEmail = "doctor@kivicare.com";
const patientEmail = "mike@kivicare.com";

// Live
// const receptionistEmail = "receptionist_jenny@activelife.com";
// const doctorEmail = "doctor_jchristopher@activelife.com";
// const patientEmail = "evadavid@activelife.com";

//Demo Password
const loginPassword = "123456";

/* Theme Mode Type */
const THEME_MODE_LIGHT = 0;
const THEME_MODE_DARK = 1;
const THEME_MODE_SYSTEM = 2;

/* DateFormats */
const FORMAT_12_HOUR = 'hh:mm a';
const ONLY_HOUR_MINUTE = 'HH:mm';
const TIME_WITH_SECONDS = 'hh:mm:ss';
const DISPLAY_DATE_FORMAT = 'dd-MMM-yyyy';
const SAVE_DATE_FORMAT = 'yyyy-MM-dd';

const CONFIRM_APPOINTMENT_FORMAT = "EEEE, MMM dd yyyy";
const GLOBAL_FORMAT = 'dd-MM-yyyy';

const tokenStream = 'tokenStream';

const TOTAL_PATIENT = "Total Patient";
const TOTAL_DOCTOR = "Total Doctors";
const TOTAL_SERVICE = 'Total Service';

// Static DATA
const SPECIALIZATION = "specialization";
const SERVICE_TYPE = "service_type";

// Holidays
const DOCTOR = "doctor";
const CLINIC = "clinic";

const CLINIC_ID = 'CLINIC_ID';

// User Roles
const UserRoleDoctor = 'doctor';
const UserRolePatient = 'patient';
const UserRoleReceptionist = 'receptionist';

// Appointment Status

// Shared preferences keys
const USER_NAME = 'USER_NAME';
const USER_PASSWORD = 'USER_PASSWORD';
const IS_LOGGED_IN = 'IS_LOGGED_IN';
const IS_REMEMBER_ME = 'IS_REMEMBER_ME';
const TOKEN = 'TOKEN';
const LANGUAGE = 'LANGUAGE';
const SELECTED_LANGUAGE = "SELECTED_LANGUAGE";
const USER_ID = "USER_ID";
const USER_DATA = "USER_DATA";
const FIRST_NAME = "FIRST_NAME";
const LAST_NAME = "LAST_NAME";
const USER_EMAIL = "USER_EMAIL";
const USER_DOB = 'USER_DOB';
const USER_LOGIN = "USER_LOGIN";
const USER_MOBILE = 'USER_MOBILE';
const USER_GENDER = 'USER_GENDER';
const SELECTED_PROFILE_INDEX = 'SELECTED_PROFILE_INDEX';

const USER_CLINIC_NAME = 'USER_CLINIC_NAME';
const USER_CLINIC_IMAGE = 'USER_CLINIC_IMAGE';
const USER_CLINIC_ADDRESS = 'USER_CLINIC_ADDRESS';
const USER_CLINIC_STATUS = 'USER_CLINIC_STATUS';

const USER_DISPLAY_NAME = "USER_DISPLAY_NAME";
const PROFILE_IMAGE = "PROFILE_IMAGE";
const DEMO_DOCTOR = "DEMO_DOCTOR";
const DEMO_RECEPTIONIST = "DEMO_RECEPTIONIST";
const DEMO_PATIENT = "DEMO_PATIENT";
const PASSWORD = "PASSWORD";
const USER_ROLE = "USER_ROLE";
const USER_CLINIC = "USER_CLINIC";
const CACHED_DASHBOARD_MODEL = 'CACHED_DASHBOARD_MODEL';
const CACHED_USER_DATA = 'CACHED_USER_DATA';

const USER_PRO_ENABLED = "USER_PRO_ENABLED";
const USER_ENCOUNTER_MODULES = "USER_ENCOUNTER_MODULES";
const USER_PRESCRIPTION_MODULE = "USER_PRESCRIPTION_MODULE";
const USER_MODULE_CONFIG = "USER_MODULE_CONFIG";

const GLOBAL_DATE_FORMAT = "GLOBAL_DATE_FORMAT";
const DATE_FORMAT = 'DATE_FORMAT';
const USER_MEET_SERVICE = "USER_MEET_SERVICE";
const USER_ZOOM_SERVICE = "USER_ZOOM_SERVICE";
const RESTRICT_APPOINTMENT_POST = "RESTRICT_APPOINTMENT_POST";
const RESTRICT_APPOINTMENT_PRE = "RESTRICT_APPOINTMENT_PRE";
const GLOBAL_UTC = 'GLOBAL_UTC';
const CURRENCY = "CURRENCY";
const CURRENCY_POST_FIX = "CURRENCY_POST_FIX";
const CURRENCY_PRE_FIX = 'CURRENCY_PRE_FIX';
const IS_WALKTHROUGH_FIRST = "IS_WALKTHROUGH_FIRST";
const ON = "on";
const OFF = "off";
const SAVE_BASE_URL = "SAVE_BASE_URL";

const PROBLEM = "problem";
const OBSERVATION = "observation";
const NOTE = "note";
const PRESCRIPTION = 'prescription';
const REPORT = 'report';

const UPDATE = "UPDATE";
const DELETE = "DELETE";
const APP_UPDATE = "APP_UPDATE";
const CHANGE_DATE = "CHANGE_DATE";
const DEMO_EMAILS = 'demoEmails';

int titleTextSize = 18;
int fragmentTextSize = 22;

const packageName = "com.iqonic.kivicare";

Future<bool> get isIqonicProduct async => await getPackageName() == packageName;

///LiveStream keys
const UPDATE_APPOINTMENTS = 'UPDATE_APPOINTMENTS';
const UPDATE_ENCOUNTERS = 'UPDATE_ENCOUNTERS';
const UPDATE_BILLS = 'UPDATE_BILLS';
const UPDATE_SESSIONS = 'UPDATE_SESSIONS';

const CACHED_FEEDS_ARTICLES = 'CACHED_FEEDS_ARTICLES';

const DOCTOR_ADD_API_UNSUCCESS_MESSAGE = "Sorry, that email address is already used!";

const PLAYER_ID = "PLAYER_ID";

const ONESIGNAL_API_KEY = 'ONESIGNAL_API_KEY';
const ONESIGNAL_REST_API_KEY = 'ONESIGNAL_REST_API_KEY';
const ONESIGNAL_CHANNEL_KEY = 'ONESIGNAL_CHANNEL_KEY';

const ONESIGNAL_TAG_KEY = 'appType';
const ONESIGNAL_PATIENT_TAG_VALUE = 'patientApp';
const ONESIGNAL_DOCTOR_TAG_VALUE = 'doctorApp';
const ONESIGNAL_RECEPTIONIST_TAG_VALUE = 'receptionistApp';

//APP SETTINGS KEYS
const APP_NOTIFICATIONS = 'APP_NOTIFICATIONS';
const APP_THEME = 'APP_THEME';
const App_LANGUAGE_CODE = 'APP_LANGUAGE_CODE';

//STATUS
const BookedStatus = 'Booked';
const CheckOutStatus = 'Check out';
const CheckInStatus = 'Check in';
const CancelledStatus = 'Cancelled';
const PendingStatus = 'Pending';

const BookedStatusInt = 1;
const CheckOutStatusInt = 3;
const CheckInStatusInt = 4;
const CancelledStatusInt = 0;
const PendingStatusInt = 2;

const ClosedEncounterStatus = 'Closed';
const ActiveEncounterStatus = 'Active';
const InActiveEncounterStatus = 'Inactive';

const ClosedEncounterStatusInt = 0;
const ActiveEncounterStatusInt = 1;
const InActiveEncounterStatusInt = 2;

const ACTIVE_USER_INT_STATUS = 1;
const INACTIVE_USER_INT_STATUS = 0;

const ACTIVE_SERVICE_STATUS = "1";
const INACTIVE_SERVICE_STATUS = "0";

const ACTIVE_CLINIC_STATUS = "1";
const INACTIVE_CLINIC_STATUS = "0";
