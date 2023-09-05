import 'package:flutter/material.dart';
import 'package:kivicare_flutter/components/disabled_rating_bar_widget.dart';
import 'package:kivicare_flutter/components/image_border_component.dart';
import 'package:kivicare_flutter/model/rating_model.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

class ReviewWidget extends StatelessWidget {
  final RatingData data;

  ReviewWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(16),
      width: context.width(),
      decoration: boxDecorationDefault(color: context.cardColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (data.patientProfileImage.validate().isNotEmpty)
                ImageBorder(src: data.patientProfileImage.validate(), height: 40)
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
                    child: Text('${data.patientName.validate(value: 'P')[0].capitalizeFirstLetter()}', style: boldTextStyle(color: Colors.black)),
                  ),
                ),
              16.width,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(data.patientName.validate(), style: boldTextStyle(size: 14), maxLines: 1, overflow: TextOverflow.ellipsis).flexible(),
                      DisabledRatingBarWidget(rating: data.rating.validate().toDouble(), size: 14, showRatingText: true),
                    ],
                  ),
                  if (data.createdAt.validate().isNotEmpty) Text(data.createdAt.validate(), style: secondaryTextStyle(size: 12)),
                  if (data.reviewDescription.validate().isNotEmpty)
                    ReadMoreText(
                      data.reviewDescription.validate(),
                      style: secondaryTextStyle(),
                      trimLength: 120,
                      colorClickableText: appSecondaryColor,
                    ).paddingTop(8),
                ],
              ).flexible(),
            ],
          ),
        ],
      ),
    );
  }
}
