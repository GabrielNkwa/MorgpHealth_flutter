import 'package:flutter/material.dart';
import 'package:kivicare_flutter/components/cached_image_widget.dart';
import 'package:kivicare_flutter/components/zoom_image_screen.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

class ImageBorder extends StatelessWidget {
  final String src;
  final double height;
  final double? width;

  ImageBorder({required this.src, required this.height, this.width});

  @override
  Widget build(BuildContext context) {
    return GradientBorder(
      gradient: LinearGradient(colors: [primaryColor, appSecondaryColor], tileMode: TileMode.mirror),
      strokeWidth: 2,
      borderRadius: 80,
      child: CachedImageWidget(
        url: src,
        circle: true,
        height: height,
        width: width,
        fit: BoxFit.cover,
      ).onTap(
        () {
          if (src.isNotEmpty) ZoomImageScreen(galleryImages: [src], index: 0).launch(context);
        },
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
      ),
    );
  }
}
