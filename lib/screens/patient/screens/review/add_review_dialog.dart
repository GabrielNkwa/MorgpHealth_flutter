import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kivicare_flutter/components/loader_widget.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/rating_model.dart';
import 'package:kivicare_flutter/network/review_repository.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:kivicare_flutter/utils/extensions/int_extensions.dart';
import 'package:nb_utils/nb_utils.dart';

class AddReviewDialog extends StatefulWidget {
  final RatingData? customerReview;
  final int doctorId;

  AddReviewDialog({this.customerReview, required this.doctorId});

  @override
  State<AddReviewDialog> createState() => _AddReviewDialogState();
}

class _AddReviewDialogState extends State<AddReviewDialog> {
  double selectedRating = 0;

  TextEditingController reviewCont = TextEditingController();

  bool isUpdate = false;

  @override
  void initState() {
    isUpdate = widget.customerReview != null;

    if (isUpdate) {
      selectedRating = widget.customerReview!.rating.validate().toDouble();
      reviewCont.text = widget.customerReview!.reviewDescription.validate();
    }

    super.initState();
  }

  void submit() async {
    hideKeyboard(context);

    Map<String, dynamic> req = {};
    if (isUpdate) {
      req = {
        "review_id": widget.customerReview!.id.validate(),
        "doctor_id": widget.doctorId.validate(),
        "review": reviewCont.text.validate(),
        "rating": selectedRating.validate(),
      };
      log(jsonEncode(req));

      appStore.setLoading(true);

      await updateReviewAPI(req).then((value) {
        appStore.setLoading(false);
        toast(value.message);
        LiveStream().emit("REVIEW_UPDATE");
        finish(context, true);
      }).catchError((e) {
        appStore.setLoading(false);
        toast(e.toString());
      });
    } else {
      req = {
        "review_description": reviewCont.text.validate(),
        "doctor_id": widget.doctorId.validate(),
        "review": selectedRating.validate(),
        "rating": selectedRating.validate(),
      };

      appStore.setLoading(true);

      await addReviewAPI(req).then((value) {
        appStore.setLoading(false);
        finish(context, true);
        LiveStream().emit("REVIEW_UPDATE");
        toast(value.message);
      }).catchError((e) {
        appStore.setLoading(false);
        throw e;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: context.width(),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: boxDecorationDefault(
                  color: primaryColor,
                  borderRadius: radiusOnly(topRight: 8, topLeft: 8),
                ),
                child: Row(
                  children: [
                    Text(locale.lblYourReviews, style: boldTextStyle(color: Colors.white)).expand(),
                    IconButton(
                      icon: Icon(Icons.clear, color: Colors.white, size: 16),
                      onPressed: () {
                        finish(context);
                      },
                    )
                  ],
                ),
              ),
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: boxDecorationDefault(color: context.cardColor),
                    child: Row(
                      children: [
                        Text(locale.lblYourRating, style: secondaryTextStyle()),
                        16.width,
                        RatingBarWidget(
                          onRatingChanged: (rating) {
                            selectedRating = rating;
                            setState(() {});
                          },
                          activeColor: selectedRating.toInt().getRatingBarColor(),
                          inActiveColor: ratingBarColor,
                          rating: selectedRating,
                          size: 18,
                        ).expand(),
                      ],
                    ),
                  ),
                  16.height,
                  AppTextField(
                    controller: reviewCont,
                    textFieldType: TextFieldType.OTHER,
                    minLines: 5,
                    maxLines: 10,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: inputDecoration(
                      context: context,
                      labelText: locale.lblEnterYourReviews,
                    ).copyWith(fillColor: context.cardColor, filled: true),
                  ),
                  32.height,
                  Row(
                    children: [
                      AppButton(
                        text: isUpdate ? locale.lblDelete : locale.lblCancel,
                        textColor: isUpdate ? Colors.red : textPrimaryColorGlobal,
                        color: context.cardColor,
                        onTap: () {
                          if (isUpdate) {
                            showConfirmDialogCustom(
                              context,
                              primaryColor: context.primaryColor,
                              title: locale.lblDoYouWantToDeleteReview,
                              positiveText: locale.lblYes,
                              negativeText: locale.lblCancel,
                              dialogType: DialogType.DELETE,
                              onAccept: (c) async {
                                appStore.setLoading(true);

                                await deleteReviewAPI(id: widget.customerReview!.id.validate().toInt()).then((value) {
                                  appStore.setLoading(false);
                                  toast(value.message);
                                  LiveStream().emit("REVIEW_UPDATE");
                                  finish(context, true);
                                }).catchError((e) {
                                  appStore.setLoading(false);
                                  toast(e.toString());
                                });

                                setState(() {});
                              },
                            );
                          } else {
                            finish(context);
                          }
                        },
                      ).expand(),
                      16.width,
                      AppButton(
                        textColor: Colors.white,
                        text: locale.lblSubmit,
                        color: context.primaryColor,
                        onTap: () {
                          if (selectedRating == 0) {
                            toast(locale.lblPleaseGiveYourRating);
                          } else {
                            submit();
                          }
                        },
                      ).expand(),
                    ],
                  )
                ],
              ).paddingAll(16)
            ],
          ),
        ),
        Observer(builder: (context) => LoaderWidget().visible(appStore.isLoading).withSize(height: 80, width: 80))
      ],
    );
  }
}
