import 'package:flutter/material.dart';
import 'package:stepper_touch/stepper_touch.dart';

class CustomStepCounter extends StatelessWidget {
  const CustomStepCounter({super.key, required this.onChanged});

  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return StepperTouch(
      initialValue: 0,
      direction: Axis.horizontal,
      withSpring: false,
      onChanged: onChanged,
    );
  }
}
