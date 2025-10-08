import 'package:flutter/material.dart';

class GradientButton extends StatelessWidget {
  final VoidCallback onPressed;
  final VoidCallback? onLongPressed;
  final Widget? child;
  final ValueChanged<bool>? onHover;
  final List<Color>? colors;
  final double? radius;
  final EdgeInsets? padding;
  final double? width, height;
  final AlignmentGeometry? alignment;

  const GradientButton({
    super.key,
    required this.onPressed,
    this.onLongPressed,
    this.onHover,
    this.child,
    this.colors = const [Colors.orange, Colors.red, Colors.amber],
    this.radius = 15,
    this.padding = const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
    this.width,
    this.height,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      alignment: alignment,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colors!,
        ),
        borderRadius: BorderRadius.all(Radius.circular(radius!)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.all(Radius.circular(radius!)),
          onTap: onPressed,
          onLongPress: onLongPressed,
          onHover: onHover,
          child: Padding(padding: padding!, child: child),
        ),
      ),
    );
  }
}
