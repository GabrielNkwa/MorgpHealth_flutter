import 'dart:io';

import 'package:flutter/material.dart';
import 'package:kivicare_flutter/components/cached_image_widget.dart';
import 'package:kivicare_flutter/components/custom_image_picker.dart';
import 'package:kivicare_flutter/components/image_border_component.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/service_duration_model.dart';
import 'package:kivicare_flutter/model/service_model.dart';
import 'package:kivicare_flutter/model/user_model.dart';
import 'package:kivicare_flutter/utils/app_common.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:kivicare_flutter/utils/extensions/enums.dart';
import 'package:kivicare_flutter/utils/extensions/string_extensions.dart';
import 'package:kivicare_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

// ignore: must_be_immutable
class EditServiceDataScreen extends StatefulWidget {
  UserModel? serviceData;
  final int? serviceId;
  final String doctorId;
  final Function(ServiceData)? onSubmit;

  EditServiceDataScreen({this.serviceData, this.serviceId, required this.doctorId, this.onSubmit});

  @override
  State<EditServiceDataScreen> createState() => _EditServiceDataScreenState();
}

class _EditServiceDataScreenState extends State<EditServiceDataScreen> {
  GlobalKey<FormState> formKey = GlobalKey();

  TextEditingController serviceNameCont = TextEditingController();
  TextEditingController chargesCont = TextEditingController();

  bool? isActive;
  bool? isMultiSelection;
  bool? isTelemed;

  bool isFirstTime = true;
  bool isUpdate = false;

  DurationModel? selectedDuration;
  UserModel? selectedDoctor;

  List<DurationModel> durationList = getServiceDuration();

  FocusNode serviceCategoryFocus = FocusNode();
  FocusNode serviceNameFocus = FocusNode();
  FocusNode serviceChargesFocus = FocusNode();
  FocusNode doctorSelectionFocus = FocusNode();
  FocusNode serviceDurationFocus = FocusNode();
  File? selectedImage;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    isUpdate = widget.serviceData != null;
    if (isUpdate) {
      selectedDoctor = widget.serviceData;
      chargesCont.text = selectedDoctor!.charges.validate();
      if (widget.serviceData?.imageFile != null) {
        selectedImage = widget.serviceData!.imageFile;
      }

      if (selectedDoctor!.duration != null && widget.serviceData!.duration.toInt() != 0) {
        selectedDuration = durationList.firstWhere((element) => element.value == selectedDoctor!.duration.toInt());
      }
      if (selectedDoctor!.status != null) isActive = selectedDoctor!.status.getBoolInt();
      if (selectedDoctor!.multiple != null) isMultiSelection = selectedDoctor!.multiple;
      isTelemed = selectedDoctor!.isTelemed;
    }
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
            selectedImage = value;
            setState(() {});
          });
        } else if (file == GalleryFileTypes.GALLERY) {
          await getCameraImage(isCamera: false).then((value) {
            selectedImage = value;
            setState(() {});
          });
        }
      }
    });
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        isUpdate ? locale.lblEditService : locale.lblAddService,
        textColor: Colors.white,
        systemUiOverlayStyle: defaultSystemUiOverlayStyle(context),
      ),
      body: Form(
        autovalidateMode: isFirstTime ? AutovalidateMode.disabled : AutovalidateMode.onUserInteraction,
        key: formKey,
        child: AnimatedScrollView(
          padding: EdgeInsets.only(bottom: 120),
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Container(
                  decoration: boxDecorationDefault(borderRadius: radius(65), color: appStore.isDarkModeOn ? cardDarkColor : context.scaffoldBackgroundColor, shape: BoxShape.circle),
                  child: selectedImage != null
                      ? Image.file(selectedImage!, fit: BoxFit.cover, width: 126, height: 126).cornerRadiusWithClipRRect(65)
                      : widget.serviceData != null
                          ? ImageBorder(
                              src: widget.serviceData!.serviceImage.validate(),
                              height: 120,
                              width: 120,
                            )
                          : CachedImageWidget(url: '', height: 126, width: 126, fit: BoxFit.cover, circle: true),
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
            ).center().paddingSymmetric(vertical: 16),
            AppTextField(
              focus: serviceChargesFocus,
              nextFocus: serviceDurationFocus,
              controller: chargesCont,
              textFieldType: TextFieldType.NAME,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.justify,
              textInputAction: TextInputAction.next,
              decoration: inputDecoration(
                context: context,
                labelText: locale.lblCharges,
                suffixIcon: ic_dollar_icon.iconImage(size: 10, color: context.iconColor).paddingAll(14),
              ),
              onFieldSubmitted: (value) {},
            ),
            16.height,
            DropdownButtonHideUnderline(
              child: DropdownButtonFormField<DurationModel>(
                focusNode: serviceDurationFocus,
                borderRadius: radius(),
                value: selectedDuration,
                icon: SizedBox.shrink(),
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
        ).paddingOnly(
          left: 16,
          right: 16,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.done, color: Colors.white),
        onPressed: () {
          if (formKey.currentState!.validate()) {
            formKey.currentState!.save();
            ServiceData data = ServiceData(
              displayName: widget.serviceData!.displayName,
              id: widget.serviceId.toString(),
              mappingTableId: widget.serviceData!.mappingTableId.validate(),
              doctorId: widget.doctorId,
              multiple: isMultiSelection,
              status: isActive.getIntBool().toString(),
              isTelemed: isTelemed,
              charges: chargesCont.text,
              duration: selectedDuration != null ? selectedDuration?.value.toString() : null,
              imageFile: selectedImage,
              image: widget.serviceData!.serviceImage,
            );

            widget.onSubmit?.call(data);
            finish(context);
          } else {
            isFirstTime = !isFirstTime;
            if (isActive == null || isMultiSelection == null || isTelemed == null) {
              toast(locale.lblPleaseChoose);
            }
            setState(() {});
          }
        },
      ),
    );
  }
}
