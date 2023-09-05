import 'package:flutter/material.dart';
import 'package:kivicare_flutter/screens/shimmer/components/shimmer_component.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

class DoctorShimmerComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width(),
      padding: EdgeInsets.all(16),
      decoration: boxDecorationDefault(
        color: primaryColor.withOpacity(0.050),
        boxShadow: [],
        borderRadius: radius(),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ShimmerComponent(
            child: Container(
              padding: EdgeInsets.all(24),
              decoration: boxDecorationDefault(shape: BoxShape.circle, color: primaryColor.withOpacity(0.2), boxShadow: []),
            ),
          ),
          8.width,
          Wrap(
            spacing: 8,
            direction: Axis.vertical,
            children: List.generate(
              3,
              (index) => ShimmerComponent(
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 4),
                  width: context.width() - 120,
                  decoration: boxDecorationDefault(color: primaryColor.withOpacity(0.3), boxShadow: [], borderRadius: radius(8)),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
