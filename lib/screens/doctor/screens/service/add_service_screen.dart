import 'dart:convert';

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kivicare_flutter/components/internet_connectivity_widget.dart';

import 'package:kivicare_flutter/components/loader_widget.dart';
import 'package:kivicare_flutter/model/clinic_list_model.dart';

import 'package:kivicare_flutter/model/service_duration_model.dart';
import 'package:kivicare_flutter/model/user_model.dart';
import 'package:kivicare_flutter/network/dashboard_repository.dart';
import 'package:kivicare_flutter/network/service_repository.dart';
import 'package:kivicare_flutter/screens/appointment/screen/step1_clinic_selection_screen.dart';
import 'package:kivicare_flutter/screens/doctor/screens/service/edit_service_data_screen.dart';
import 'package:kivicare_flutter/utils/constants.dart';
import 'package:kivicare_flutter/utils/extensions/string_extensions.dart';
import 'package:nb_utils/nb_utils.dart';

import 'package:kivicare_flutter/components/cached_image_widget.dart';
import 'package:kivicare_flutter/components/custom_image_picker.dart';
import 'package:kivicare_flutter/components/role_widget.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/service_model.dart';
import 'package:kivicare_flutter/model/static_data_model.dart';
import 'package:kivicare_flutter/utils/app_common.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:kivicare_flutter/utils/extensions/enums.dart';
import 'package:kivicare_flutter/utils/images.dart';
import 'package:kivicare_flutter/screens/receptionist/components/multi_select_doctor_drop_down.dart';

class AddServiceScreen extends StatefulWidget {
  final ServiceData? serviceData;
  final VoidCallback? callForRefresh;

  AddServiceScreen({this.serviceData, this.callForRefresh});

  @override
  State<AddServiceScreen> createState() => _AddServiceScreenState();
}

class _AddServiceScreenState extends State<AddServiceScreen> {
  GlobalKey<FormState> formKey = GlobalKey();

  Future<StaticDataModel>? future;
  List<int> doctorIdsList = [];

  int selectedIndex = -1;

  bool isUpdate = false;

  bool isFirstTime = true;

  bool? isActive;
  bool? isMultiSelection;
  bool? isTelemed;
  bool isDoubleTapped = false;
  StaticData? category;
  DurationModel? selectedDuration;

  List<UserModel> tempDoctorList = [];
  List<UserModel> selectedDoctorList = [];
  List<int> listOfMappingTableId = [];
  List<DurationModel> durationList = getServiceDuration();

  UserModel? selectedDoctorData;
  Clinic? selectedClinic;

  TextEditingController serviceNameCont = TextEditingController();
  TextEditingController serviceCategoryCont = TextEditingController();

  TextEditingController chargesCont = TextEditingController();
  TextEditingController doctorCont = TextEditingController();
  TextEditingController clinicCont = TextEditingController();

  File? selectedProfileImage;

  List<File> serviceImage = [];

  FocusNode serviceCategoryFocus = FocusNode();
  FocusNode serviceNameFocus = FocusNode();
  FocusNode serviceChargesFocus = FocusNode();
  FocusNode doctorSelectionFocus = FocusNode();
  FocusNode serviceDurationFocus = FocusNode();
  FocusNode clinicFocus = FocusNode();

  @override
  void initState() {
    super.initState();

    init();
  }

  void init() async {
    isUpdate = widget.serviceData != null;

    appStore.setLoading(true);
    future = getStaticDataResponseAPI(SERVICE_TYPE).then((value) {
      appStore.setLoading(false);
      return value;
    }).catchError((e) {
      appStore.setLoading(false);
      toast(e.toString());
      throw e;
    });

    if (isUpdate) {
      serviceNameCont.text = widget.serviceData!.name.validate();
      if (isReceptionist()) serviceDataForReceptionistIfIsUpdate();
      if (isDoctor()) setInitialData();
    }
    setState(() {});
  }

  void serviceDataForReceptionistIfIsUpdate() {
    serviceCategoryCont.text = widget.serviceData!.type.validate();
    serviceNameCont.text = widget.serviceData!.name.validate();
    if (widget.serviceData!.doctorList != null && widget.serviceData!.doctorList.validate().isNotEmpty) {
      if (widget.serviceData!.doctorList.validate().length == 1) {
        setInitialData();
      } else {
        widget.serviceData!.doctorList.validate().forEach((element) {
          doctorIdsList.add(element.doctorId.validate().toInt());
          selectedDoctorList.add(element);
          tempDoctorList.add(element);
        });
      }

      if (selectedDoctorList.length > 1)
        doctorCont.text = selectedDoctorList.length.toString() + ' ${locale.lblDoctorsAvailable}';
      else {
        doctorCont.text = 'Dr. ' + selectedDoctorData!.displayName.validate();
      }
    }
  }

  void setInitialData() {
    if (isReceptionist()) {
      selectedDoctorData = widget.serviceData!.doctorList!.first;
      doctorCont.text = 'Dr. ' + selectedDoctorData!.displayName.validate();
      chargesCont.text = selectedDoctorData!.charges.validate();
      doctorIdsList.add(selectedDoctorData!.doctorId.toInt());
      if (selectedDoctorData!.duration != null && selectedDoctorData!.duration.toInt() != 0) {
        selectedDuration = durationList.firstWhere((element) => element.value == selectedDoctorData!.duration.toInt());
      }
      if (selectedDoctorData!.status != null) isActive = selectedDoctorData!.status!.getBoolInt();
      if (selectedDoctorData!.multiple != null) isMultiSelection = selectedDoctorData!.multiple;
      isTelemed = selectedDoctorData!.isTelemed;
      selectedDoctorList.add(selectedDoctorData!);
      tempDoctorList.add(selectedDoctorData!);
    } else {
      selectedDoctorData = UserModel();

      if (widget.serviceData != null && selectedDoctorData != null) {
        selectedDoctorData = setDoctor(widget.serviceData!, userData: selectedDoctorData!);
      }

      selectedClinic = Clinic(name: widget.serviceData!.clinicName, id: widget.serviceData!.clinicId);
      clinicCont.text = selectedClinic!.name.validate();
      chargesCont.text = widget.serviceData!.charges.validate();
      if (widget.serviceData!.duration != null && (widget.serviceData!.duration.toInt() != 0 || widget.serviceData!.duration.validate().isNotEmpty)) {
        selectedDuration = durationList.firstWhere((element) => element.value == widget.serviceData!.duration.toInt());
      }
      if (selectedDoctorData!.status != null) isActive = widget.serviceData!.status!.getBoolInt();
      if (selectedDoctorData!.multiple != null) isMultiSelection = widget.serviceData!.multiple;
      isTelemed = widget.serviceData!.isTelemed;
      tempDoctorList.add(selectedDoctorData!);
    }
  }

  void ifLengthIsGreater() {
    doctorIdsList.clear();

    selectedDoctorList.forEach((element) {
      doctorIdsList.add(element.doctorId.toInt());
      //tempDoctorList.retainWhere((serviceData) => serviceData.doctorId == element.doctorId);
    });

    tempDoctorList.retainWhere((element) => doctorIdsList.contains(element.doctorId.toInt()));

    if (selectedDoctorList.length == 1) {
      selectedDoctorData = selectedDoctorList.first;

      chargesCont.text = selectedDoctorData!.charges.validate();
      if (selectedDoctorData!.duration != null && selectedDoctorData!.duration.toInt() != 0) {
        selectedDuration = durationList.firstWhere((element) => element.value == selectedDoctorData!.duration.toInt());
      } else
        selectedDuration = null;

      if (selectedDoctorData!.status != null)
        isActive = selectedDoctorData!.status.getBoolInt();
      else
        isActive = null;
      if (selectedDoctorData!.multiple != null)
        isMultiSelection = selectedDoctorData!.multiple;
      else
        isMultiSelection = null;
      isTelemed = selectedDoctorData!.isTelemed;
      doctorCont.text = 'Dr. ' + selectedDoctorData!.displayName.validate();
      if (selectedDoctorData!.imageFile != null) {
        selectedProfileImage = selectedDoctorData!.imageFile;
      }
    } else {
      doctorCont.text = selectedDoctorList.length.toString() + " " + locale.lblDoctorsSelected;
    }
  }

  void _handleClick({ServiceData? serviceData}) {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      showConfirmDialogCustom(
        context,
        dialogType: isUpdate ? DialogType.UPDATE : DialogType.CONFIRMATION,
        primaryColor: context.primaryColor,
        title: isUpdate ? locale.lblDoYouWantToUpdateService : locale.lblDoYouWantToAddNewService,
        onAccept: (c) async {
          Map<String, dynamic> req = {
            "type": serviceCategoryCont.text.isEmpty ? category?.value : serviceCategoryCont.text,
            "name": serviceNameCont.text,
          };

          if (isUpdate) req.putIfAbsent('id', () => widget.serviceData!.id.validate());
          if (isDoctor()) {
            if (isUpdate && selectedDoctorData != null) req.putIfAbsent('doctors[0][mapping_table_id]', () => selectedDoctorData?.mappingTableId);
            req.putIfAbsent('doctors[0][charges]', () => chargesCont.text);
            req.putIfAbsent('doctors[0][duration]', () => selectedDuration!.value.toString());
            req.putIfAbsent('doctors[0][status]', () => isActive.getIntBool());
            req.putIfAbsent('doctors[0][is_telemed]', () => isTelemed.getIntBool());
            req.putIfAbsent('doctors[0][is_multiple_selection]', () => isMultiSelection.getIntBool());
            req.putIfAbsent('doctors[0][doctor_id]', () => userStore.userId);
            if (selectedClinic != null) {
              req.putIfAbsent('doctors[0][clinic_id]', () => selectedClinic!.id);
            } else {
              req.putIfAbsent('doctors[0][clinic_id]', () => selectedDoctorData?.clinicId);
            }
          }
          if (isReceptionist()) {
            if (selectedDoctorList.length == 1) {
              tempDoctorList.clear();
              selectedDoctorData!.charges = chargesCont.text;
              if (selectedDuration != null) {
                selectedDoctorData!.duration = selectedDuration!.value.toString();
              }

              selectedDoctorData!.status = isActive.getIntBool().toString();
              selectedDoctorData!.isTelemed = isTelemed;
              selectedDoctorData!.multiple = isMultiSelection;
              if (selectedProfileImage != null) {
                selectedDoctorData!.imageFile = selectedProfileImage;
              }
              if (selectedDoctorData != null) tempDoctorList.add(selectedDoctorData!);
            }
            if (listOfMappingTableId.isNotEmpty) {
              listOfMappingTableId.forEachIndexed((element, index) {
                req.putIfAbsent('mapping_table_id[$index]', () => element);
              });
            }
          }

          log("Service Request :${jsonEncode(req)}");
          appStore.setLoading(true);

          await saveServiceAPI(data: req, serviceImage: selectedProfileImage, tempList: tempDoctorList).then((value) {
            appStore.setLoading(false);
            toast(value.message);
            finish(context, true);
          }).catchError((e) {
            appStore.setLoading(false);
            toast(e.toString());
          });
        },
      );
    } else {
      isFirstTime = !isFirstTime;
      setState(() {});
    }
  }

  Future<void> _chooseImage() async {
    await showInDialog(
      context,
      contentPadding: EdgeInsets.symmetric(vertical: 16),
      title: Text(locale.lblChooseAction, style: boldTextStyle()),
      builder: (p0) {
        return FilePickerDialog(isSelected: (false));
      },
    ).then((file) async {
      if (file != null) {
        if (file == GalleryFileTypes.CAMERA) {
          await getCameraImage().then((value) {
            selectedProfileImage = value;
            setState(() {});
          });
        } else if (file == GalleryFileTypes.GALLERY) {
          await getCameraImage(isCamera: false).then((value) {
            selectedProfileImage = value;
            setState(() {});
          });
        }
      }
    });
  }

  void changeStatus(bool? value) {
    isActive = value.validate();

    setState(() {});
  }

  void allowTelemed(bool? value) {
    isTelemed = value.validate();

    setState(() {});
  }

  void changeMultiSelection(bool? value) {
    isMultiSelection = value.validate();

    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget buildBodyWidget() {
    return Stack(
      children: [
        Form(
          autovalidateMode: isFirstTime ? AutovalidateMode.disabled : AutovalidateMode.onUserInteraction,
          key: formKey,
          child: AnimatedScrollView(
            padding: EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 96),
            children: [
              if (isDoctor() || selectedDoctorList.length == 1)
                Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    Container(
                      decoration: boxDecorationDefault(borderRadius: radius(65), color: appStore.isDarkModeOn ? cardDarkColor : context.scaffoldBackgroundColor, shape: BoxShape.circle),
                      child: selectedProfileImage != null
                          ? Image.file(selectedProfileImage!, fit: BoxFit.cover, width: 126, height: 126).cornerRadiusWithClipRRect(65)
                          : CachedImageWidget(url: widget.serviceData != null ? selectedDoctorData!.serviceImage.validate() : "", height: 126, width: 126, fit: BoxFit.cover, circle: true),
                    ).onTap(
                      () {
                        _chooseImage();
                      },
                      borderRadius: radius(65),
                      splashColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: EdgeInsets.all(8),
                        decoration: boxDecorationDefault(color: appPrimaryColor, shape: BoxShape.circle, border: Border.all(color: white, width: 3)),
                        child: ic_camera.iconImage(size: 14, color: Colors.white),
                      ).onTap(
                        () {
                          _chooseImage();
                        },
                        borderRadius: radius(65),
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                      ),
                    )
                  ],
                ).center().paddingBottom(16),
              20.height,
              FutureBuilder<StaticDataModel>(
                  future: future,
                  builder: (context, snap) {
                    if (snap.hasData) {
                      if (isUpdate) {
                        List<String> stype = [];
                        if (stype.contains(widget.serviceData!.type.validate())) {
                          category = snap.data?.staticData?.firstWhere((element) => element!.value == widget.serviceData!.type.validate());
                        }

                        if (snap.data != null) {
                          if (snap.data!.staticData != null) {
                            snap.data?.staticData!.forEach((element) {
                              stype.add(element!.value.validate());
                            });
                            if (stype.contains(widget.serviceData!.type.validate())) {
                              category = snap.data?.staticData?.firstWhere((element) => element!.value == widget.serviceData!.type.validate());
                            } else {
                              category?.value = widget.serviceData!.type.validate();

                              if (category != null) {
                                serviceCategoryCont.text = category!.value.validate();
                              }
                            }
                          }
                        }
                      }

                      return IgnorePointer(
                        ignoring: isUpdate,
                        child: DropdownButtonFormField<StaticData>(
                          focusNode: serviceCategoryFocus,
                          icon: SizedBox.shrink(),
                          isExpanded: true,
                          borderRadius: radius(),
                          dropdownColor: context.cardColor,
                          autovalidateMode: isFirstTime ? AutovalidateMode.disabled : AutovalidateMode.onUserInteraction,
                          value: category,
                          items: snap.data!.staticData.validate().map<DropdownMenuItem<StaticData>>((serviceData) {
                            return DropdownMenuItem<StaticData>(
                              value: serviceData,
                              onTap: () {
                                category = serviceData;
                                serviceCategoryCont.text = serviceData.value.validate();

                                setState(() {});
                              },
                              child: Text(serviceData!.label.validate(), style: primaryTextStyle()),
                            );
                          }).toList(),
                          onChanged: (category) {
                            if (isUpdate) return;
                            if (!isUpdate) {
                              category = category;
                              serviceCategoryCont.text = category!.value.validate();
                              setState(() {});
                            }
                          },
                          decoration: inputDecoration(
                            context: context,
                            labelText: isUpdate ? '${locale.lblCategory}' : '${locale.lblSelect} ${locale.lblCategory}',
                            suffixIcon: ic_arrow_down.iconImage(size: 10, color: context.iconColor).paddingAll(14),
                          ),
                          validator: (s) {
                            if (s == null) return errorThisFieldRequired;
                            return null;
                          },
                        ),
                      );
                    } else {
                      return Offstage();
                    }
                  }),
              16.height,
              AppTextField(
                nextFocus: isReceptionist() ? doctorSelectionFocus : clinicFocus,
                controller: serviceNameCont,
                textFieldType: TextFieldType.NAME,
                textAlign: TextAlign.justify,
                decoration: inputDecoration(
                  context: context,
                  labelText: locale.lblService + ' ${locale.lblName}',
                  suffixIcon: ic_services.iconImage(size: 10, color: context.iconColor).paddingAll(14),
                ),
              ),
              16.height,
              RoleWidget(
                  isShowDoctor: true,
                  child: AppTextField(
                    controller: clinicCont,
                    focus: clinicFocus,
                    textFieldType: TextFieldType.OTHER,
                    isValidationRequired: true,
                    nextFocus: serviceChargesFocus,
                    decoration: inputDecoration(
                      context: context,
                      labelText: isUpdate ? locale.lblClinicName : locale.lblSelectClinic,
                      suffixIcon: ic_clinic.iconImage(size: 10, color: context.iconColor).paddingAll(14),
                    ),
                    readOnly: true,
                    onTap: () {
                      if (!isUpdate) {
                        Step1ClinicSelectionScreen(sessionOrEncounter: true, clinicId: selectedClinic != null ? selectedClinic!.id.toInt() : null).launch(context).then((value) {
                          if (value != null) {
                            selectedClinic = value;
                            clinicCont.text = selectedClinic!.name.validate();
                            setState(() {});
                          } else {}
                        });
                      } else {
                        toast(locale.lblEditHolidayRestriction);
                      }
                    },
                    validator: (value) {
                      if (value!.isEmpty) return locale.lblSelectOneClinic;
                      return null;
                    },
                  )),
              RoleWidget(
                isShowReceptionist: true,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppTextField(
                      controller: doctorCont,
                      focus: doctorSelectionFocus,
                      textFieldType: TextFieldType.OTHER,
                      isValidationRequired: true,
                      errorThisFieldRequired: locale.lblSelectOneDoctor,
                      readOnly: true,
                      validator: (value) {
                        if (selectedDoctorList.isEmpty)
                          return locale.lblPleaseSelectDoctor;
                        else
                          return null;
                      },
                      onTap: () {
                        MultiSelectDoctorDropDown(
                          clinicId: userStore.userClinicId.toInt(),
                          selectedDoctorsId: doctorIdsList,
                          refreshMappingTableIdsList: (dId) {
                            if (selectedDoctorList.isNotEmpty) {
                              selectedDoctorList.forEach((element) {
                                if (element.doctorId.toInt() == dId) {
                                  if (!listOfMappingTableId.any((e) => e == element.mappingTableId.toInt())) {
                                    listOfMappingTableId.add(element.mappingTableId.toInt());
                                  }
                                }
                              });
                            }
                            selectedDoctorList.removeWhere((element) => element.doctorId.toInt() == dId);
                          },
                          onSubmit: (selectedDoctorsList) {
                            selectedDoctorsList.forEach((element) {
                              int index = selectedDoctorList.indexWhere((userData) => userData.doctorId.toInt() == element.doctorId.toInt());

                              if (index > 0) {
                                selectedDoctorList[index] = selectedDoctorList[index];
                              }
                              if (index < 0) {
                                if (!doctorIdsList.contains(element.doctorId.toInt())) {
                                  selectedDoctorList.add(element);
                                  tempDoctorList.add(element);
                                }
                              }
                            });

                            if (selectedDoctorList.isNotEmpty) {
                              selectedDoctorList.forEach((element) {
                                if (listOfMappingTableId.contains(element.mappingTableId)) {
                                  listOfMappingTableId.remove(element.mappingTableId);
                                }
                              });

                              ifLengthIsGreater();
                            }

                            setState(() {});
                          },
                        ).launch(context);
                      },
                      decoration: inputDecoration(
                        context: context,
                        labelText: locale.lblSelectDoctor,
                        suffixIcon: ic_user.iconImage(size: 10, color: context.iconColor).paddingAll(14),
                      ).copyWith(alignLabelWithHint: true),
                    ),
                    if (selectedDoctorList.length > 1)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${locale.lblNote} : ${locale.lblDoctorTapMsg}",
                            style: secondaryTextStyle(size: 10, color: appSecondaryColor),
                          ).paddingSymmetric(horizontal: 4, vertical: 6),
                          8.height,
                          Wrap(
                              direction: Axis.horizontal,
                              runSpacing: 16,
                              spacing: 16,
                              children: selectedDoctorList.map<Widget>((userData) {
                                UserModel data = userData;
                                return GestureDetector(
                                  onTap: () {
                                    selectedIndex = selectedDoctorList.indexOf(data);
                                    setState(() {});
                                    EditServiceDataScreen(
                                      doctorId: data.doctorId.toString(),
                                      serviceData: data,
                                      onSubmit: (serviceData) {
                                        serviceData.displayName = data.displayName;

                                        if (selectedProfileImage != null) {
                                          serviceData.image = selectedProfileImage!.path;
                                        }

                                        data = setDoctor(serviceData, userData: data);
                                        selectedDoctorData = data;

                                        int index = tempDoctorList.indexWhere((serviceData) => serviceData.doctorId.toString() == data.doctorId.toString());

                                        if (index < 0) {
                                          tempDoctorList.add(data);
                                        } else {
                                          tempDoctorList[index] = data;
                                        }
                                      },
                                    ).launch(context);
                                  },
                                  child: Container(
                                    padding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                                    width: context.width() / 2 - 24,
                                    decoration: boxDecorationDefault(
                                      border: Border.all(color: selectedIndex == selectedDoctorList.indexOf(data) ? appSecondaryColor : borderColor),
                                      color: context.cardColor,
                                      borderRadius: radius(32),
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(CupertinoIcons.person, size: 16, color: context.iconColor),
                                        8.width,
                                        Text('Dr. ${data.displayName.validate().split(' ').first}', style: primaryTextStyle(color: context.iconColor), maxLines: 1, overflow: TextOverflow.ellipsis)
                                            .expand(),
                                        ic_clear.iconImage().paddingAll(6).onTap(
                                          () {
                                            listOfMappingTableId.add(data.mappingTableId.toInt());
                                            selectedDoctorList.removeWhere((element) => element.doctorId == data.doctorId);
                                            tempDoctorList.removeWhere((element) => element.doctorId.toString() == data.doctorId.toString());

                                            if (selectedDoctorList.isNotEmpty) {
                                              ifLengthIsGreater();
                                            }

                                            setState(() {});
                                          },
                                          borderRadius: radius(),
                                          splashColor: Colors.transparent,
                                          highlightColor: Colors.transparent,
                                        )
                                      ],
                                    ),
                                  ),
                                );
                              }).toList()),
                        ],
                      )
                  ],
                ),
              ),
              16.height,
              if (isDoctor() || selectedDoctorList.length == 1)
                Column(
                  children: [
                    AppTextField(
                      focus: serviceChargesFocus,
                      nextFocus: doctorSelectionFocus,
                      controller: chargesCont,
                      textFieldType: TextFieldType.NAME,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.justify,
                      decoration: inputDecoration(
                        context: context,
                        labelText: locale.lblCharges,
                        suffixIcon: ic_dollar_icon.iconImage(size: 10, color: context.iconColor).paddingAll(14),
                      ),
                    ),
                    16.height,
                    DropdownButtonHideUnderline(
                      child: DropdownButtonFormField<DurationModel>(
                        focusNode: serviceDurationFocus,
                        value: selectedDuration,
                        icon: SizedBox.shrink(),
                        borderRadius: radius(),
                        dropdownColor: context.cardColor,
                        autovalidateMode: isFirstTime ? AutovalidateMode.disabled : AutovalidateMode.onUserInteraction,
                        decoration: inputDecoration(
                          context: context,
                          labelText: '${locale.lblSelect} ${locale.lblDuration}',
                          suffixIcon: ic_arrow_down.iconImage(size: 10, color: context.iconColor).paddingAll(14),
                        ),
                        onChanged: (value) {
                          if (!isUpdate) {
                            selectedDuration = value;
                            setState(() {});
                          }
                          selectedDuration = value;
                          setState(() {});
                        },
                        items: durationList.map<DropdownMenuItem<DurationModel>>((duration) {
                          return DropdownMenuItem<DurationModel>(
                            value: duration,
                            child: Text(duration.label.validate(), style: primaryTextStyle()),
                          );
                        }).toList(),
                      ),
                    ),
                    16.height,
                    Container(
                      decoration: boxDecorationDefault(borderRadius: radius(), color: context.cardColor),
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            locale.lblAllowMultiSelectionWhileBooking,
                            style: primaryTextStyle(color: textSecondaryColorGlobal),
                          ),
                          4.height,
                          Row(
                            children: [
                              RadioListTile<bool>(
                                visualDensity: VisualDensity.compact,
                                value: true,
                                controlAffinity: ListTileControlAffinity.trailing,
                                groupValue: isMultiSelection,
                                title: Text(locale.lblYes, style: primaryTextStyle()),
                                onChanged: changeMultiSelection,
                              ).expand(),
                              RadioListTile<bool>(
                                visualDensity: VisualDensity.compact,
                                value: false,
                                controlAffinity: ListTileControlAffinity.trailing,
                                groupValue: isMultiSelection,
                                title: Text(locale.lblNo, style: primaryTextStyle()),
                                onChanged: changeMultiSelection,
                              ).expand(),
                            ],
                          )
                        ],
                      ),
                    ),
                    16.height,
                    Container(
                      decoration: boxDecorationDefault(borderRadius: radius(), color: context.cardColor),
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            locale.lblSetStatus,
                            style: primaryTextStyle(color: textSecondaryColorGlobal),
                          ),
                          4.height,
                          Row(
                            children: [
                              RadioListTile<bool>(
                                visualDensity: VisualDensity.compact,
                                value: true,
                                controlAffinity: ListTileControlAffinity.trailing,
                                groupValue: isActive,
                                title: Text(locale.lblActive, style: primaryTextStyle()),
                                onChanged: changeStatus,
                              ).expand(),
                              RadioListTile<bool>(
                                visualDensity: VisualDensity.compact,
                                value: false,
                                controlAffinity: ListTileControlAffinity.trailing,
                                groupValue: isActive,
                                title: Text(locale.lblInActive, style: primaryTextStyle()),
                                onChanged: changeStatus,
                              ).expand(),
                            ],
                          )
                        ],
                      ),
                    ),
                    16.height,
                    Container(
                      decoration: boxDecorationDefault(borderRadius: radius(), color: context.cardColor),
                      padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            locale.lblIsThisATelemedService,
                            style: primaryTextStyle(color: textSecondaryColorGlobal),
                          ),
                          4.height,
                          Row(
                            children: [
                              RadioListTile<bool>(
                                visualDensity: VisualDensity.compact,
                                value: true,
                                controlAffinity: ListTileControlAffinity.trailing,
                                groupValue: isTelemed,
                                title: Text(locale.lblYes, style: primaryTextStyle()),
                                onChanged: allowTelemed,
                              ).expand(),
                              RadioListTile<bool>(
                                visualDensity: VisualDensity.compact,
                                value: false,
                                controlAffinity: ListTileControlAffinity.trailing,
                                groupValue: isTelemed,
                                title: Text(locale.lblNo, style: primaryTextStyle()),
                                onChanged: allowTelemed,
                              ).expand(),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                )
            ],
          ),
        ),
        Observer(builder: (context) => LoaderWidget().visible(appStore.isLoading).center())
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        isUpdate ? locale.lblEditService : locale.lblAddService,
        textColor: Colors.white,
        systemUiOverlayStyle: defaultSystemUiOverlayStyle(context),
        actions: [
          if (isUpdate)
            IconButton(
              icon: Icon(
                Icons.delete,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () async {
                showConfirmDialogCustom(
                  context,
                  dialogType: DialogType.DELETE,
                  title: locale.lblDoYouWantToDeleteService,
                  onAccept: (p0) async {
                    Map<String, dynamic> req = {
                      "id": widget.serviceData!.id.validate(),
                    };
                    if (isDoctor()) {
                      req.putIfAbsent("doctor_id", () => userStore.userId);
                      req.putIfAbsent('service_mapping_id', () => widget.serviceData!.mappingTableId);
                    } else {
                      listOfMappingTableId.clear();
                      selectedDoctorList.forEachIndexed((element, index) {
                        listOfMappingTableId.add(element.mappingTableId.toInt());
                      });
                      req.putIfAbsent('mapping_table_id', () => listOfMappingTableId);
                    }
                    appStore.setLoading(true);

                    await deleteServiceDataAPI(req).then((value) {
                      appStore.setLoading(false);
                      toast(value.message.validate());
                      finish(context, true);
                    }).catchError((e) {
                      appStore.setLoading(false);
                      toast(e.toString());
                    });
                  },
                );
              },
            ),
        ],
      ),
      body: InternetConnectivityWidget(
        retryCallback: () {
          init();
        },
        child: buildBodyWidget(),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.done, color: Colors.white),
        onPressed: _handleClick,
      ),
    );
  }

  UserModel setDoctor(ServiceData doctorData, {required UserModel userData}) {
    userData.doctorId = doctorData.doctorId;
    userData.profileImage = doctorData.doctorProfileImage;
    userData.mappingTableId = doctorData.mappingTableId;
    userData.charges = doctorData.charges;
    userData.isTelemed = doctorData.isTelemed;
    userData.status = doctorData.status;
    userData.duration = doctorData.duration;
    userData.multiple = doctorData.multiple;
    userData.imageFile = doctorData.imageFile;
    userData.serviceImage = doctorData.image.validate();

    return userData;
  }
}
