// gradient_checkbox.dart
import 'package:flutter/material.dart';

class GradientCheckbox extends StatelessWidget {
  final bool? value;
  final ValueChanged<bool?>? onChanged;

  const GradientCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [Colors.orange, Colors.red, Colors.amber],
      ).createShader(bounds),
      child: Checkbox(
        value: value,
        onChanged: onChanged,
        activeColor: Colors.white,
        checkColor: Colors.black,
      ),
    );
  }
}
