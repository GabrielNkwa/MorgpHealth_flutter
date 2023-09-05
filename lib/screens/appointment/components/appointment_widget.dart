import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

import 'package:kivicare_flutter/components/image_border_component.dart';
import 'package:kivicare_flutter/components/loader_widget.dart';
import 'package:kivicare_flutter/components/status_widget.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/upcoming_appointment_model.dart';
import 'package:kivicare_flutter/network/appointment_repository.dart';
import 'package:kivicare_flutter/network/encounter_repository.dart';
import 'package:kivicare_flutter/screens/appointment/appointment_functions.dart';
import 'package:kivicare_flutter/screens/appointment/components/appointment_quick_view.dart';
import 'package:kivicare_flutter/screens/doctor/fragments/appointment_fragment.dart';
import 'package:kivicare_flutter/screens/encounter/screen/encounter_dashboard_screen.dart';
import 'package:kivicare_flutter/screens/encounter/screen/patient_encounter_dashboard_screen.dart';
import 'package:kivicare_flutter/screens/patient/screens/review/add_review_dialog.dart';
import 'package:kivicare_flutter/utils/app_common.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:kivicare_flutter/utils/constants.dart';
import 'package:kivicare_flutter/utils/extensions/int_extensions.dart';
import 'package:kivicare_flutter/utils/extensions/string_extensions.dart';
import 'package:kivicare_flutter/utils/images.dart';

import 'package:nb_utils/nb_utils.dart';

class AppointmentWidget extends StatefulWidget {
  final UpcomingAppointmentModel upcomingData;
  final VoidCallback? refreshCall;

  AppointmentWidget({required this.upcomingData, this.refreshCall});

  @override
  _AppointmentWidgetState createState() => _AppointmentWidgetState();
}

class _AppointmentWidgetState extends State<AppointmentWidget> {
  @override
  void initState() {
    super.initState();
  }

  String nextStatus(String status) {
    if (status.validate().toInt() == 0) return '';
    if (status.validate().toInt() % 4 == 1)
      return locale.lblCheckIn;
    else if (status.validate().toInt() % 4 == 2)
      return locale.lblPending;
    else if (status.validate().toInt() % 4 == 3)
      return locale.lblClose;
    else if (status.validate().toInt() == 4) return locale.lblCheckOut;

    return '';
  }

  void changeAppointmentStatus() async {
    showInDialog(
      context,
      contentPadding: EdgeInsets.zero,
      builder: (p0) {
        return buildChangeStatusWidget();
      },
    );
  }

  void closeEncounter({String? appointmentId, bool isCheckOut = false, required int encounterId}) async {
    Map<String, dynamic> request = {
      "encounter_id": encounterId,
    };
    if (isCheckOut) {
      request.putIfAbsent("appointment_id", () => appointmentId.validate());
      request.putIfAbsent("appointment_status", () => CheckOutStatusInt);
    }
    appStore.setLoading(true);

    await encounterClose(request).then((value) {
      appStore.setLoading(false);
      appointmentStreamController.add(true);
      toast(value.message);
      widget.refreshCall?.call();
      finish(context, isCheckOut);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
    });
  }

  void deleteAppointmentValue(BuildContext context) async {
    showConfirmDialogCustom(
      context,
      dialogType: DialogType.DELETE,
      title: locale.lblDoYouWantToDeleteAppointmentOf,
      onAccept: (p0) => deleteAppointmentById(widget.upcomingData.id.toInt()),
    );
  }

  void updateStatus({int? id, int? status}) async {
    appStore.setLoading(true);

    Map<String, dynamic> request = {
      "appointment_id": id.toString(),
      "appointment_status": status.toString(),
    };

    await updateAppointmentStatus(request).then((value) {
      appointmentStreamController.add(true);
      toast(locale.lblChangedTo + " ${status.getStatus()}");
      appStore.setLoading(false);
      widget.refreshCall?.call();
      finish(context);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
      throw e;
    });
  }

  void deleteAppointmentById(int id) async {
    appStore.setLoading(true);

    Map<String, dynamic> request = {"id": id};

    await deleteAppointment(request).then((value) {
      appointmentStreamController.add(true);

      appStore.setLoading(false);
      widget.refreshCall?.call();
      toast(locale.lblAppointmentDeleted);
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
      throw e;
    });

    appStore.setLoading(false);
    finish(context);
  }

  void _handleViewButton() {
    showInDialog(
      context,
      contentPadding: EdgeInsets.zero,
      title: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: boxDecorationDefault(color: appSecondaryColor),
                child: Image.asset(ic_appointment, fit: BoxFit.cover, height: 22, width: 22, color: white),
              ),
              16.width,
              Text(locale.lblAppointmentSummary, style: boldTextStyle(size: 18)).flexible(),
            ],
          ).paddingOnly(top: 24),
          Positioned(
            right: -12,
            top: -12,
            child: StatusWidget(
              status: widget.upcomingData.status.validate(),
              isAppointmentStatus: true,
            ),
          )
        ],
      ),
      builder: (p0) {
        return AppointmentQuickView(upcomingAppointment: widget.upcomingData);
      },
    );
  }

  void _handleEncounterButton() {
    if (isPatient()) {
      PatientEncounterDashboardScreen(id: widget.upcomingData.encounterId.validate()).launch(context);
    } else {
      EncounterDashboardScreen(encounterId: widget.upcomingData.encounterId.validate()).launch(context).then(
        (value) {
          if (value != null) {
            if (value) {
              widget.refreshCall?.call();
              setState(() {});
              updateStatus(id: widget.upcomingData.encounterId.validate().toInt(), status: CheckOutStatusInt);
            } else {
              widget.refreshCall?.call();
              setState(() {});
            }
          }
        },
      );
    }
  }

  void _handleCheckInOutButton() {
    if (ifCheckIn && widget.upcomingData.encounterStatus == 1) {
      toast(locale.lblPleaseCloseTheEncounterToCheckoutPatient);
    } else {
      if (ifCheckIn && widget.upcomingData.encounterStatus == 0) {
        showConfirmDialogCustom(
          context,
          title: locale.lblDoYouWantToCheckoutAppointment,
          dialogType: DialogType.CONFIRMATION,
          onAccept: (p0) {
            closeEncounter(encounterId: widget.upcomingData.encounterId.toInt(), appointmentId: widget.upcomingData.id, isCheckOut: true);
          },
        );
      } else
        changeAppointmentStatus();
    }
  }

  void _handleReviewButton() async {
    await showInDialog(
      context,
      contentPadding: EdgeInsets.zero,
      builder: (p0) {
        return AddReviewDialog(customerReview: widget.upcomingData.doctorRating, doctorId: widget.upcomingData.doctorId.validate().toInt());
      },
    ).then((value) {
      if (value ?? false) widget.refreshCall?.call();
    });
  }

  //endregion

  bool get isEdit {
    return widget.upcomingData.status.toInt().getStatus() != CheckOutStatus &&
        widget.upcomingData.status.toInt().getStatus() != CancelledStatus &&
        widget.upcomingData.status.toInt().getStatus() != CheckInStatus &&
        (getDateDifference(widget.upcomingData.appointmentGlobalStartDate.validate()) > 0 ||
            DateFormat(SAVE_DATE_FORMAT).parse(DateTime.now().toString()) == DateFormat(SAVE_DATE_FORMAT).parse(widget.upcomingData.appointmentGlobalStartDate.validate()));
  }

  //region Visible Button conditions
  bool get showEncounterButton {
    return (widget.upcomingData.status.toInt() == CheckInStatusInt);
  }

  bool get showCheckInButton {
    bool beforeTime = getDateDifference(widget.upcomingData.appointmentGlobalStartDate.validate()) == 0;
    return ((isDoctor() || isReceptionist()) && (widget.upcomingData.status.toInt() == BookedStatusInt || widget.upcomingData.status.toInt() == CheckInStatusInt) && beforeTime);
  }

  bool get ifCheckIn {
    return ((isDoctor() || isReceptionist()) && widget.upcomingData.status.toInt() == CheckInStatusInt);
  }

  bool get showReviewButton {
    return isPatient() && widget.upcomingData.status.toInt() == CheckOutStatusInt;
  }

  //endregion

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  //region Widgets
  Widget buildChangeStatusWidget() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(ic_appointment, color: Colors.black, fit: BoxFit.cover),
          16.height,
          Text(locale.lblChangingStatusFrom, style: primaryTextStyle(), textAlign: TextAlign.center),
          20.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(getStatus(widget.upcomingData.status.validate()), style: boldTextStyle(size: 20)),
              Container(child: Icon(Icons.arrow_forward, size: 20)),
              Text(nextStatus(widget.upcomingData.status.validate()), style: boldTextStyle(size: 20, color: primaryColor)),
            ],
          ).center(),
          32.height,
          Row(
            children: [
              AppButton(
                color: context.scaffoldBackgroundColor,
                text: locale.lblCancel,
                onTap: () => finish(context),
                shapeBorder: RoundedRectangleBorder(borderRadius: radius(), side: BorderSide(color: context.primaryColor)),
                textColor: context.primaryColor,
              ).expand(),
              16.width,
              Observer(
                builder: (context) {
                  return AppButton(
                    color: context.primaryColor,
                    text: locale.lblChange,
                    onTap: () async {
                      updateStatus(id: widget.upcomingData.id.toInt(), status: 4);
                    },
                  ).expand().visible(!appStore.isLoading, defaultWidget: LoaderWidget(size: 30).expand());
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget commonAppButton(
      {Color? color, Color? buttonTextColor, required String buttonText, int? buttonSize, double? topRight, double? topLeft, double? bottomRight, double? bottomLeft, required Function() onTap}) {
    return Flexible(
      child: AppButton(
        onTap: onTap,
        padding: EdgeInsets.symmetric(horizontal: 24),
        shapeBorder: RoundedRectangleBorder(
          borderRadius: radiusOnly(topRight: topRight ?? 0, topLeft: topLeft ?? 0, bottomRight: bottomRight ?? 0, bottomLeft: bottomLeft ?? 0),
        ),
        child: FittedBox(child: Text(buttonText, style: boldTextStyle(color: buttonTextColor ?? white, size: buttonSize ?? 12)), fit: BoxFit.none),
        color: color ?? appPrimaryColor,
      ),
    );
  }

  Widget buildAppointmentTopWidget() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.upcomingData.doctorProfileImg.validate().isNotEmpty && widget.upcomingData.patientProfileImg.validate().isNotEmpty)
          ImageBorder(src: widget.upcomingData.getProfileImage, height: 40)
        else
          GradientBorder(
            gradient: LinearGradient(colors: [primaryColor, appSecondaryColor], tileMode: TileMode.mirror),
            strokeWidth: 2,
            borderRadius: 80,
            child: PlaceHolderWidget(
              height: 40,
              width: 40,
              shape: BoxShape.circle,
              alignment: Alignment.center,
              child: Text(
                isPatient() ? widget.upcomingData.doctorName.validate(value: 'D')[0].capitalizeFirstLetter() : widget.upcomingData.patientName.validate(value: 'P')[0].capitalizeFirstLetter(),
                style: boldTextStyle(color: Colors.black),
              ),
            ),
          ),
        16.width,
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.upcomingData.id.validate().prefixText(value: "#"), style: secondaryTextStyle(color: primaryColor)),
            Text(getRoleWiseAppointmentFirstText(widget.upcomingData), style: boldTextStyle()),
            1.height,
            if (isReceptionist()) Text(widget.upcomingData.doctorName.validate().prefixText(value: "Dr. "), style: boldTextStyle(size: 12)),
            if (isReceptionist()) 1.height,
            ReadMoreText(
              widget.upcomingData.getVisitTypesInString.capitalizeEachWord(),
              trimLines: 1,
              style: secondaryTextStyle(),
              colorClickableText: Colors.pink,
              trimMode: TrimMode.Line,
              trimCollapsedText: locale.lblReadMore,
              trimExpandedText: locale.lblReadLess,
              locale: Localizations.localeOf(context),
            )
          ],
        ).expand(),
        8.width,
        StatusWidget(
          status: widget.upcomingData.status.validate(),
          isAppointmentStatus: true,
        ),
      ],
    ).paddingOnly(top: 16, left: 8, right: 8);
  }

  Widget buildDateTimeWidget() {
    return Container(
      width: context.width() - 64,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: boxDecorationDefault(color: context.scaffoldBackgroundColor),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ic_appointment.iconImage(size: 16).paddingLeft(16),
          16.width,
          Text('${widget.upcomingData.appointmentDateFormat}', style: primaryTextStyle(size: 14)).expand(),
        ],
      ),
    );
  }

  Widget buildButtonWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
      child: Row(
        children: [
          Row(
            children: [
              commonAppButton(
                buttonText: locale.lblViewDetails,
                onTap: _handleViewButton,
                color: appPrimaryColor,
                topLeft: defaultRadius,
                bottomLeft: defaultRadius,
                topRight: (showEncounterButton || showCheckInButton || showReviewButton) ? 0 : defaultRadius,
                bottomRight: (showEncounterButton || showCheckInButton || showReviewButton) ? 0 : defaultRadius,
              ),
              commonAppButton(
                buttonText: locale.lblEncounter,
                onTap: _handleEncounterButton,
                color: appStore.isDarkModeOn ? context.iconColor.withOpacity(0.2) : context.iconColor,
                topLeft: 0,
                bottomLeft: 0,
                topRight: (showCheckInButton || showReviewButton) ? 0 : defaultRadius,
                bottomRight: (showCheckInButton || showReviewButton) ? 0 : defaultRadius,
              ).visible(showEncounterButton),
              commonAppButton(
                buttonText: ifCheckIn ? locale.lblCheckOut : locale.lblCheckIn,
                onTap: _handleCheckInOutButton,
                color: appSecondaryColor,
                topLeft: 0,
                bottomLeft: 0,
                topRight: showReviewButton ? 0 : defaultRadius,
                bottomRight: showReviewButton ? 0 : defaultRadius,
              ).visible(showCheckInButton),
              commonAppButton(
                buttonText: locale.lblReview,
                onTap: _handleReviewButton,
                color: appSecondaryColor,
                topLeft: 0,
                bottomLeft: 0,
                topRight: defaultRadius,
                bottomRight: defaultRadius,
              ).visible(showReviewButton),
            ],
          ).expand(),
        ],
      ),
    );
  }

  //endregion

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(widget.upcomingData),
      endActionPane: ActionPane(
        extentRatio: 0.7,
        motion: ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (BuildContext context) {
              appointmentWidgetNavigation(context, data: widget.upcomingData).then((value) {
                widget.refreshCall?.call();
              });
            },
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            borderRadius: BorderRadius.only(topLeft: Radius.circular(defaultRadius), bottomLeft: Radius.circular(defaultRadius)),
            icon: Icons.edit,
            label: locale.lblEdit,
          ).visible(isEdit),
          SlidableAction(
            borderRadius: BorderRadius.only(topRight: Radius.circular(defaultRadius), bottomRight: Radius.circular(defaultRadius)),
            onPressed: deleteAppointmentValue,
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: locale.lblDelete,
          ),
        ],
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8),
        decoration: boxDecorationDefault(color: context.cardColor),
        child: Column(
          children: [
            buildAppointmentTopWidget(),
            buildDateTimeWidget().paddingSymmetric(vertical: 8),
            buildButtonWidget(),
          ],
        ),
      ).onTap(() {
        _handleViewButton();
      }, splashColor: Colors.transparent, highlightColor: Colors.transparent),
    );
  }
}
