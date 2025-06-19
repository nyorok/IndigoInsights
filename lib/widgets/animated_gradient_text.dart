import 'dart:math';

import 'package:flutter/material.dart';

class AnimatedGradientText extends StatefulWidget {
  final String text;
  final List<Color> gradientColors;
  final TextStyle? style;
  final double? startPlace;

  const AnimatedGradientText(
    this.text, {
    super.key,
    required this.gradientColors,
    this.style,
    this.startPlace,
  });

  @override
  State<AnimatedGradientText> createState() => _AnimatedGradientTextState();
}

class _AnimatedGradientTextState extends State<AnimatedGradientText>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    final randomStart = widget.startPlace ?? Random().nextDouble();
    _animation = Tween<double>(
      begin: 0 + randomStart,
      end: 1 + randomStart,
    ).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        List<Color> effectiveColors;
        if (widget.gradientColors.isEmpty) {
          effectiveColors = [Colors.white, Colors.black];
        } else {
          effectiveColors =
              widget.gradientColors + [widget.gradientColors.first];
        }

        return ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: effectiveColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            tileMode: TileMode.repeated,
            transform: _GradientTranslate(_animation.value),
          ).createShader(bounds),
          child: Text(widget.text, style: widget.style),
        );
      },
    );
  }
}

class _GradientTranslate extends GradientTransform {
  final double animationValue;

  const _GradientTranslate(this.animationValue);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
      animationValue * bounds.width,
      animationValue * bounds.height,
      0.0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is _GradientTranslate &&
        other.animationValue == animationValue;
  }

  @override
  int get hashCode => animationValue.hashCode;
}
