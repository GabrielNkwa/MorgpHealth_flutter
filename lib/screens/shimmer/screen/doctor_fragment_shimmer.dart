import 'package:flutter/material.dart';
import 'package:kivicare_flutter/screens/shimmer/components/doctor_shimmer_component.dart';
import 'package:nb_utils/nb_utils.dart';

class DoctorShimmerFragment extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedWrap(
      runSpacing: 16,
      spacing: 16,
      listAnimationType: ListAnimationType.None,
      children: List.generate(
        7,
        (index) => DoctorShimmerComponent(),
      ),
    ).paddingSymmetric(horizontal: 16);
  }
}
