// widgets\gradient_progress_indicator.dart
import 'package:bbqlagao_and_beefpares/styles/color.dart';
import 'package:flutter/material.dart';

class GradientCircularProgressIndicator extends StatelessWidget {
  const GradientCircularProgressIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (Rect bounds) {
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: GradientColorSets.set1,
        ).createShader(bounds);
      },
      child: const SizedBox(
        width: 30,
        height: 30,
        child: CircularProgressIndicator(
          padding: EdgeInsets.all(3),
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          strokeWidth: 3,
        ),
      ),
    );
  }
}
