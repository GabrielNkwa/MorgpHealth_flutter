import 'dart:math';

import 'package:flutter/material.dart';
import 'package:kivicare_flutter/components/image_border_component.dart';
import 'package:kivicare_flutter/components/price_widget.dart';
import 'package:kivicare_flutter/components/status_widget.dart';
import 'package:kivicare_flutter/main.dart';
import 'package:kivicare_flutter/model/user_model.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:kivicare_flutter/utils/common.dart';
import 'package:kivicare_flutter/utils/extensions/string_extensions.dart';
import 'package:kivicare_flutter/utils/images.dart';
import 'package:nb_utils/nb_utils.dart';

import 'package:kivicare_flutter/model/service_model.dart';

class ServiceWidget extends StatelessWidget {
  final ServiceData data;

  ServiceWidget({required this.data});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: context.width() / 2 - 24,
          child: Container(
            decoration: data.image.validate().isNotEmpty
                ? boxDecorationDefault(
                    color: context.cardColor,
                    image: DecorationImage(
                      fit: BoxFit.cover,
                      colorFilter: ColorFilter.mode(Colors.black54, BlendMode.multiply),
                      image: NetworkImage(
                        data.doctorList != null
                            ? data.doctorList.validate().isNotEmpty
                                ? data.doctorList.validate()[data.doctorList.validate().indexWhere((element) => element.serviceImage.isEmptyOrNull)].serviceImage.validate()
                                : data.image.validate()
                            : data.image.validate(),
                      ),
                    ),
                  )
                : BoxDecoration(
                    color: lightColors[Random.secure().nextInt(lightColors.length)],
                    shape: BoxShape.rectangle,
                    borderRadius: radius(),
                  ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isDoctor()) 12.height,
                if (isReceptionist() || isPatient()) 8.height,
                Text(data.name.validate().capitalizeEachWord(),
                    style: boldTextStyle(size: 16, color: data.image.validate().isNotEmpty ? Colors.white : Colors.black), maxLines: 1, overflow: TextOverflow.ellipsis),
                8.height,
                if ((isReceptionist() || isPatient()) && data.doctorList.validate().isNotEmpty)
                  Text(
                    '${data.doctorList.validate().length} ${(data.doctorList.validate().length > 1) ? locale.lblDoctorsAvailable : locale.lblDoctorAvailable}',
                    style: secondaryTextStyle(color: data.image.validate().isNotEmpty ? Colors.white70 : Colors.black54),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                8.height,
                if ((isReceptionist() || isPatient()) && data.doctorList.validate().isNotEmpty)
                  Row(
                    children: [
                      Stack(
                        alignment: Alignment.centerLeft,
                        children: List.generate(data.doctorList.validate().length, (index) {
                          UserModel userData = data.doctorList.validate()[index];
                          String image = data.doctorList.validate()[index].profileImage.validate();
                          if (data.doctorList.validate().length > 1) {
                            if (image.isNotEmpty)
                              return ImageBorder(
                                height: 30,
                                width: 30,
                                src: image,
                              ).paddingLeft(index == 0 ? 0 : (index) * 20);
                            else
                              return GradientBorder(
                                gradient: LinearGradient(colors: [primaryColor, appSecondaryColor], tileMode: TileMode.mirror),
                                strokeWidth: 2,
                                borderRadius: 30,
                                child: PlaceHolderWidget(
                                  shape: BoxShape.circle,
                                  height: 30,
                                  width: 30,
                                  alignment: Alignment.center,
                                  child: Text(userData.displayName.validate(value: 'D')[0].capitalizeFirstLetter(), style: boldTextStyle(color: Colors.black)),
                                ),
                              ).paddingLeft(index == 0 ? 0 : (index) * 20);
                          } else
                            return Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                if (image.isNotEmpty)
                                  ImageBorder(
                                    src: image,
                                    height: 30,
                                    width: 30,
                                  ).paddingLeft(index == 0 ? 0 : (index) * 20)
                                else
                                  GradientBorder(
                                    gradient: LinearGradient(colors: [primaryColor, appSecondaryColor], tileMode: TileMode.mirror),
                                    strokeWidth: 2,
                                    borderRadius: 30,
                                    child: PlaceHolderWidget(
                                      shape: BoxShape.circle,
                                      height: 30,
                                      width: 30,
                                      alignment: Alignment.center,
                                      child: Text(userData.displayName.validate(value: 'D')[0].capitalizeFirstLetter(), style: boldTextStyle(color: Colors.black)),
                                    ),
                                  ),
                                2.width,
                                Text("Dr. " + userData.displayName.validate().split(' ').first.capitalizeFirstLetter(), style: primaryTextStyle(color: Colors.black)),
                              ],
                            );
                        }),
                      ),
                    ],
                  )
                else
                  Row(
                    children: [
                      PriceWidget(price: "${data.charges.validate()}", textSize: 16, textColor: primaryColor).expand(),
                      if (!data.duration.isEmptyOrNull)
                        TextIcon(
                          prefix: ic_timer.iconImage(color: appSecondaryColor, size: 16),
                          text: "${data.duration.validate()} min",
                          textStyle: secondaryTextStyle(color: data.image.validate().isNotEmpty ? Colors.white70 : Colors.black54),
                        )
                    ],
                  ),
              ],
            ).paddingOnly(left: 12, right: 12, top: isDoctor() ? 28 : 0, bottom: 12),
          ),
        ),
        if (isDoctor())
          Positioned(
            right: 8,
            top: 10,
            child: StatusWidget(
              status: data.status.validate(),
              isServiceActivityStatus: true,
            ),
          ),
      ],
    );
  }
}
