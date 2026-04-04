import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:indigo_insights/services/pwa_service.dart';
import 'package:indigo_insights/theme/app_color_scheme.dart';
import 'package:indigo_insights/theme/app_text_styles.dart';

/// Wraps [child] and overlays a PWA install banner at the bottom of the screen
/// when the browser's `beforeinstallprompt` event fires.
///
/// On non-web builds the banner is never shown (stub returns false).
class PwaInstallBanner extends StatefulWidget {
  const PwaInstallBanner({super.key, required this.child});

  final Widget child;

  @override
  State<PwaInstallBanner> createState() => _PwaInstallBannerState();
}

class _PwaInstallBannerState extends State<PwaInstallBanner> {
  bool _visible = false;
  bool _dismissed = false;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    // Only show banner on desktop — mobile uses the top bar Install button.
    _pollTimer = Timer.periodic(const Duration(seconds: 1), _poll);
  }

  void _poll(Timer t) {
    if (_dismissed || t.tick > 30) {
      t.cancel();
      return;
    }
    // Skip on mobile — handled by IITopBar.
    final width = WidgetsBinding.instance.platformDispatcher.views.first.physicalSize.width /
        WidgetsBinding.instance.platformDispatcher.views.first.devicePixelRatio;
    if (width < 700) {
      t.cancel();
      return;
    }
    try {
      if (pwaInstallAvailable() && !pwaIsInstalled()) {
        t.cancel();
        if (mounted) setState(() => _visible = true);
      }
    } catch (_) {
      t.cancel();
    }
  }

  void _install() {
    pwaTriggerInstall();
    setState(() => _visible = false);
    _dismissed = true;
  }

  void _dismiss() {
    setState(() => _visible = false);
    _dismissed = true;
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_visible) _Banner(onInstall: _install, onDismiss: _dismiss),
      ],
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.onInstall, required this.onDismiss});

  final VoidCallback onInstall;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);
    final isNarrow = MediaQuery.of(context).size.width < 600;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: colors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.4),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: isNarrow
                ? _NarrowLayout(
                    styles: styles,
                    colors: colors,
                    onInstall: onInstall,
                    onDismiss: onDismiss,
                  )
                : _WideLayout(
                    styles: styles,
                    colors: colors,
                    onInstall: onInstall,
                    onDismiss: onDismiss,
                  ),
          ),
        ),
      ),
    )
        .animate()
        .slideY(begin: 1, end: 0, duration: 400.ms, curve: Curves.easeOutCubic)
        .fade(duration: 300.ms);
  }
}

class _WideLayout extends StatelessWidget {
  const _WideLayout({
    required this.styles,
    required this.colors,
    required this.onInstall,
    required this.onDismiss,
  });

  final AppTextStyles styles;
  final AppColorScheme colors;
  final VoidCallback onInstall;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _AppIcon(),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Install Indigo Insights', style: styles.cardTitle),
              const SizedBox(height: 2),
              Text(
                'Add to your home screen for instant access — no app store needed.',
                style: styles.bodySm.copyWith(color: colors.textSecondary),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        _DismissButton(onDismiss: onDismiss, colors: colors, styles: styles),
        const SizedBox(width: 8),
        _InstallButton(onInstall: onInstall, colors: colors, styles: styles),
      ],
    );
  }
}

class _NarrowLayout extends StatelessWidget {
  const _NarrowLayout({
    required this.styles,
    required this.colors,
    required this.onInstall,
    required this.onDismiss,
  });

  final AppTextStyles styles;
  final AppColorScheme colors;
  final VoidCallback onInstall;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const _AppIcon(),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Install Indigo Insights', style: styles.cardTitle),
                  const SizedBox(height: 2),
                  Text(
                    'Add to home screen — no app store needed.',
                    style: styles.bodySm.copyWith(color: colors.textSecondary),
                  ),
                ],
              ),
            ),
            _DismissButton(
                onDismiss: onDismiss, colors: colors, styles: styles),
          ],
        ),
        const SizedBox(height: 12),
        _InstallButton(
          onInstall: onInstall,
          colors: colors,
          styles: styles,
          fullWidth: true,
        ),
      ],
    );
  }
}

class _AppIcon extends StatelessWidget {
  const _AppIcon();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        'assets/icons/ic_square_512.png',
        width: 44,
        height: 44,
        cacheWidth: 88,
        cacheHeight: 88,
      ),
    );
  }
}

class _InstallButton extends StatelessWidget {
  const _InstallButton({
    required this.onInstall,
    required this.colors,
    required this.styles,
    this.fullWidth = false,
  });

  final VoidCallback onInstall;
  final AppColorScheme colors;
  final AppTextStyles styles;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) {
    final btn = FilledButton(
      onPressed: onInstall,
      style: FilledButton.styleFrom(
        backgroundColor: colors.primary,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text('Install', style: styles.bodySm.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
    );
    return fullWidth ? SizedBox(width: double.infinity, child: btn) : btn;
  }
}

class _DismissButton extends StatelessWidget {
  const _DismissButton({
    required this.onDismiss,
    required this.colors,
    required this.styles,
  });

  final VoidCallback onDismiss;
  final AppColorScheme colors;
  final AppTextStyles styles;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onDismiss,
      icon: Icon(Icons.close, size: 18, color: colors.textMuted),
      tooltip: 'Dismiss',
      style: IconButton.styleFrom(
        padding: const EdgeInsets.all(6),
        minimumSize: const Size(32, 32),
      ),
    );
  }
}
