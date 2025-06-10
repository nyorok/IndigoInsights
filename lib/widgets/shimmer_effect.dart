import 'package:flutter/material.dart';

class ShimmerEffect extends StatefulWidget {
  final Widget child; // The widget you want to shimmer over
  final Duration duration;

  const ShimmerEffect({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
  });

  @override
  State<ShimmerEffect> createState() => _ShimmerEffectState();
}

class _ShimmerEffectState extends State<ShimmerEffect>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat(reverse: false); // Make it repeat continuously
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  // The gradient that creates the shimmering effect
  LinearGradient get _shimmerGradient => LinearGradient(
    colors: const [
      Color(0xFFE0E0E0), // Light grey base
      Color(0xFFF5F5F5), // Brighter white for the "shine"
      Color(0xFFE0E0E0), // Light grey base
    ],
    stops: const [0.1, 0.3, 0.5],
    begin: Alignment(-1.0 - _shimmerController.value * 2, 0.0),
    end: Alignment(1.0 - _shimmerController.value * 2, 0.0),
    tileMode: TileMode.clamp,
  );

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return _shimmerGradient.createShader(
              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
            );
          },
          child: widget.child, // Apply the shimmer over the provided child
        );
      },
    );
  }
}
