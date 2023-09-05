import 'package:flutter/material.dart';
import 'package:kivicare_flutter/screens/shimmer/components/shimmer_component.dart';
import 'package:kivicare_flutter/utils/colors.dart';
import 'package:nb_utils/nb_utils.dart';

class PatientShimmerComponent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width(),
      padding: EdgeInsets.all(16),
      decoration: boxDecorationDefault(
        color: primaryColor.withOpacity(0.025),
        boxShadow: [],
        borderRadius: radius(),
      ),
      child: Row(
        children: [
          ShimmerComponent(
            child: Container(
              padding: EdgeInsets.all(36),
              decoration: boxDecorationDefault(color: primaryColor.withOpacity(0.3), boxShadow: [], borderRadius: radius(), shape: BoxShape.circle),
            ),
          ),
          16.width,
          Wrap(
            direction: Axis.vertical,
            spacing: 4,
            children: List.generate(
              4,
              (index) => ShimmerComponent(
                child: Container(
                  width: context.width() - 150,
                  padding: EdgeInsets.all(4),
                  decoration: boxDecorationDefault(
                    color: primaryColor.withOpacity(0.3),
                    boxShadow: [],
                    borderRadius: radius(8),
                  ),
                ),
              ),
            ),
          ).expand()
        ],
      ),
    );
  }
}
