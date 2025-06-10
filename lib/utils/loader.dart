import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:indigo_insights/theme/color_scheme.dart';

class Loader extends StatelessWidget {
  const Loader({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.white.withValues(alpha: 0.5))
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(
          duration: 1200.ms,
          colors: [secondaryBackground, secondaryBackground.withAlpha(200)],
        );
  }

  Widget build2(BuildContext context) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(
        minHeight: 30,
        maxHeight: 60,
        minWidth: 30,
        maxWidth: 60,
      ),
      child: const CircularProgressIndicator(color: Colors.white),
    ),
  );
}
