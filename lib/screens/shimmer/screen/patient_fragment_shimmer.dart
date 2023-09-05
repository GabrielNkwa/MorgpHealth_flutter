import 'package:flutter/material.dart';
import 'package:kivicare_flutter/screens/shimmer/components/patient_shimmer_component.dart';
import 'package:nb_utils/nb_utils.dart';

class PatientFragmentShimmer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AnimatedWrap(
      runSpacing: 16,
      spacing: 16,
      children: List.generate(7, (index) => PatientShimmerComponent()),
    ).paddingSymmetric(horizontal: 16);
  }
}
