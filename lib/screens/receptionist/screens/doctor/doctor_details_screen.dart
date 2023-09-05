import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:kivicare_flutter/components/body_widget.dart';
import 'package:kivicare_flutter/components/cached_image_widget.dart';
import 'package:kivicare_flutter/components/common_row_component.dart';
import 'package:kivicare_flutter/components/role_widget.dart';
import 'package:kivicare_flutter/components/view_all_widget.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/network/auth_repository.dart';
import 'package:kivicare_flutter/network/doctor_list_repository.dart';
import 'package:kivicare_flutter/screens/patient/screens/review/component/review_widget.dart';
import 'package:kivicare_flutter/screens/patient/screens/review/rating_view_all_screen.dart';
import 'package:kivicare_flutter/screens/receptionist/screens/doctor/add_doctor_screen.dart';
import 'package:kivicare_flutter/utils/app_common.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:kivicare_flutter/utils/extensions/string_extensions.dart';
import 'package:kivicare_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

import 'package:kivicare_flutter/model/user_model.dart';

class DoctorDetailScreen extends StatefulWidget {
  final UserModel doctorData;
  final VoidCallback? refreshCall;

  DoctorDetailScreen({Key? key, this.refreshCall, required this.doctorData}) : super(key: key);

  @override
  _DoctorDetailScreenState createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  late UserModel doctor;

  @override
  void initState() {
    super.initState();
    getDoctorData(showLoader: isPatient() ? true : false);
  }

  Future<void> getDoctorData({bool showLoader = true}) async {
    doctor = widget.doctorData;
    if (widget.doctorData.doctorId.validate().isNotEmpty && widget.doctorData.doctorId.validate().toInt() != 0) {
      doctor.iD = widget.doctorData.doctorId.toInt();
    }
    if (showLoader) {
      appStore.setLoading(true);
    }
    getSingleUserDetailAPI(doctor.iD.validate()).then((value) {
      appStore.setLoading(false);
      if (value.iD == null) value.iD = doctor.iD;
      if (value.available == null) value.available = doctor.available;

      if (value.displayName == null) value.displayName = '${value.firstName} ${value.lastName.validate()}';
      doctor = value;
      setState(() {});
    }).catchError((e) {
      appStore.setLoading(false);

      toast(e.toString());
      log("GET DOCTOR ERROR : ${e.toString()} ");
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<void> deleteDoctor(int doctorId) async {
    showConfirmDialogCustom(
      context,
      dialogType: DialogType.DELETE,
      title: locale.lblDoYouWantToDeleteDoctor,
      onAccept: (p0) {
        Map<String, dynamic> request = {
          "doctor_id": doctorId,
        };

        appStore.setLoading(true);

        deleteDoctorAPI(request).then((value) {
          appStore.setLoading(false);
          toast(locale.lblDoctorDeleted);
          finish(context, true);
        }).catchError((e) {
          appStore.setLoading(false);
          toast(e.toString());
          throw e;
        });

        appStore.setLoading(false);
      },
    );
  }

  Widget buildBasicDetailsWidget() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${locale.lblBasicDetails}: ', style: boldTextStyle()),
          8.height,
          if (doctor.displayName.validate().isNotEmpty)
            CommonRowComponent(
              leading: ic_user.iconImage(size: 20),
              title: locale.lblName,
              titleTextStyle: secondaryTextStyle(size: 16),
              value: "${doctor.displayName.validate()}",
              valueTextStyle: primaryTextStyle(),
            ),
          10.height,
          if (doctor.userEmail.validate().isNotEmpty)
            CommonRowComponent(
              leading: ic_message.iconImage(size: 20),
              title: locale.lblEmail,
              titleTextStyle: secondaryTextStyle(size: 16),
              value: "${doctor.userEmail.validate()}",
              valueTextStyle: primaryTextStyle(),
            ),
          10.height,
          Visibility(
              visible: doctor.mobileNumber.validate().isNotEmpty,
              child: CommonRowComponent(
                leading: ic_phone.iconImage(size: 20),
                title: locale.lblContact,
                titleTextStyle: secondaryTextStyle(size: 16),
                value: doctor.mobileNumber.validate(),
                valueTextStyle: primaryTextStyle(),
              )),
          10.height,
          Visibility(
            visible: doctor.noOfExperience.validate().toInt() != 0,
            child: CommonRowComponent(
              leading: ic_experience.iconImage(size: 20),
              title: locale.lblExperience,
              titleTextStyle: secondaryTextStyle(size: 16),
              value: doctor.noOfExperience.validate().toInt() > 1 ? doctor.noOfExperience.validate() + ' ${locale.lblYears}' : ' ${locale.lblYear}',
              valueTextStyle: primaryTextStyle(),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAvailableWeekDaysWidget() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(locale.lblAvailableOn, style: boldTextStyle(size: 16)),
          16.height,
          doctor.available.validate().isNotEmpty
              ? AnimatedWrap(
                  spacing: 16,
                  runSpacing: 10,
                  itemCount: doctor.available!.split(",").length,
                  listAnimationType: listAnimationType,
                  itemBuilder: (context, index) {
                    return Container(
                      width: context.width() / 4 - 20,
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: boxDecorationDefault(color: appStore.isDarkModeOn ? cardDarkColor : context.cardColor),
                      child: Text(
                        '${doctor.available!.split(",")[index].capitalizeFirstLetter()}',
                        style: boldTextStyle(color: primaryColor, size: 14),
                      ),
                    );
                  },
                )
              : Text("Dr. ${doctor.displayName} ${locale.lblWeekDaysDataNotFound}", style: primaryTextStyle())
        ],
      ),
    ).visible(doctor.available.validate().isNotEmpty);
  }

  Widget buildSpecialityWidget() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('${locale.lblSpecialities}: ', style: boldTextStyle()),
        16.height,
        Wrap(
          direction: Axis.vertical,
          children: List.generate(
            doctor.specialties!.length,
            (index) => Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: boxDecorationDefault(shape: BoxShape.circle, color: primaryColor),
                  height: 8,
                  width: 8,
                ),
                8.width,
                Text(doctor.specialties![index].label.validate(), style: primaryTextStyle()),
                16.width,
              ],
            ),
          ),
        ),
      ],
    ).paddingAll(16);
  }

  Widget buildReviewWidget() {
    if (!isProEnabled()) return Offstage();
    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        children: [
          ViewAllLabel(
            label: locale.lblRatingsAndReviews,
            subLabel: locale.lblKnowWhatYourPatientsSaysAboutYou,
            viewAllShowLimit: 5,
            list: doctor.ratingList.validate(),
            onTap: () {
              RatingViewAllScreen(doctorId: doctor.iD.validate()).launch(context);
            },
          ),
          16.height,
          if (doctor.ratingList.validate().isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: doctor.ratingList.validate().length,
              itemBuilder: (context, index) => ReviewWidget(data: doctor.ratingList.validate()[index]),
            )
        ],
      ),
    ).visible(doctor.ratingList.validate().isNotEmpty);
  }

  Widget buildProfileWidget() {
    return Visibility(
      visible: doctor.profileImage.validate().isNotEmpty,
      child: Hero(
        tag: doctor.iD.validate(),
        child: CachedImageWidget(
          height: 120,
          width: 120,
          fit: BoxFit.cover,
          url: doctor.profileImage.validate(),
          circle: true,
        ).center().paddingTop(20).paddingBottom(20),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        locale.lblDoctorDetails,
        textColor: Colors.white,
        systemUiOverlayStyle: defaultSystemUiOverlayStyle(context),
        actions: [
          RoleWidget(
            isShowReceptionist: true,
            child: IconButton(
              icon: FaIcon(Icons.edit, size: 20, color: Colors.white),
              onPressed: () async {
                await AddDoctorScreen(
                  doctorData: doctor,
                  refreshCall: () {
                    widget.refreshCall?.call();
                    getDoctorData();
                  },
                ).launch(context).then(
                      (value) => (value) {
                        widget.refreshCall?.call();
                        getDoctorData();
                      },
                    );
              },
            ),
          ),
          RoleWidget(
            isShowReceptionist: true,
            child: IconButton(
              icon: FaIcon(Icons.delete, size: 20, color: Colors.white),
              onPressed: () {
                ifTester(context, () => deleteDoctor(doctor.iD.validate()), userEmail: doctor.userEmail.validate());
              },
            ).paddingRight(16),
          ),
        ],
      ),
      body: Body(
        visibleOn: appStore.isLoading,
        child: AnimatedScrollView(
          listAnimationType: ListAnimationType.None,
          padding: EdgeInsets.only(bottom: 16),
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          onSwipeRefresh: () async {
            widget.refreshCall?.call();
            getDoctorData();
            return await 1.seconds.delay;
          },
          children: [
            buildProfileWidget(),
            buildBasicDetailsWidget(),
            if (widget.doctorData.specialties != null && widget.doctorData.specialties!.validate().isNotEmpty) buildSpecialityWidget(),
            buildAvailableWeekDaysWidget(),
            buildReviewWidget(),
          ],
        ),
      ),
    );
  }
}
