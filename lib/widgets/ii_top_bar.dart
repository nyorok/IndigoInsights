import 'dart:async';

import 'package:flutter/material.dart';
import 'package:indigo_insights/services/pwa_service.dart';
import 'package:indigo_insights/theme/app_color_scheme.dart';
import 'package:indigo_insights/theme/app_text_styles.dart';

/// 60-px top bar shown at the top of every page.
///
/// Desktop: page title + date + Live badge.
/// Mobile:  hamburger + page title + Install App (if PWA installable) or Live badge.
class IITopBar extends StatefulWidget {
  const IITopBar({super.key, required this.title});

  final String title;

  @override
  State<IITopBar> createState() => _IITopBarState();
}

class _IITopBarState extends State<IITopBar> {
  bool _pwaAvailable = false;
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _pollTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (t.tick > 30) {
        t.cancel();
        return;
      }
      try {
        if (pwaInstallAvailable() && !pwaIsInstalled()) {
          t.cancel();
          if (mounted) setState(() => _pwaAvailable = true);
        }
      } catch (_) {
        t.cancel();
      }
    });
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }

  void _install() {
    pwaTriggerInstall();
    setState(() => _pwaAvailable = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);
    final isDesktop = MediaQuery.of(context).size.width >= 700;

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: colors.canvas,
        border: Border(bottom: BorderSide(color: colors.border, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          if (!isDesktop)
            Builder(
              builder: (ctx) => IconButton(
                icon: Icon(Icons.menu, color: colors.textPrimary),
                onPressed: () => Scaffold.of(ctx).openDrawer(),
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                tooltip: 'Menu',
              ),
            ),
          if (!isDesktop) const SizedBox(width: 8),
          Text(widget.title, style: styles.pageTitle),
          const Spacer(),
          if (isDesktop) ...[
            _DateLabel(styles: styles, colors: colors),
            const SizedBox(width: 12),
            const _LiveBadge(),
          ] else if (_pwaAvailable)
            _InstallButton(onInstall: _install, colors: colors, styles: styles)
          else
            const _LiveBadge(),
        ],
      ),
    );
  }
}

class _InstallButton extends StatelessWidget {
  const _InstallButton({
    required this.onInstall,
    required this.colors,
    required this.styles,
  });

  final VoidCallback onInstall;
  final AppColorScheme colors;
  final AppTextStyles styles;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onInstall,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: colors.primary.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.primary.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.download_rounded, size: 13, color: colors.primary),
            const SizedBox(width: 5),
            Text(
              'Install App',
              style: styles.bodySm.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateLabel extends StatelessWidget {
  const _DateLabel({required this.styles, required this.colors});

  final AppTextStyles styles;
  final AppColorScheme colors;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final label = '${months[now.month - 1]} ${now.day}, ${now.year}';
    return Text(label, style: styles.bodySm.copyWith(color: colors.textMuted));
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge();

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.success.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.success.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: colors.success,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            'Live',
            style: styles.bodySm.copyWith(
              color: colors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
