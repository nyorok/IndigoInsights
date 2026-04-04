import 'package:flutter/material.dart';
import 'package:indigo_insights/theme/app_color_scheme.dart';
import 'package:indigo_insights/theme/app_text_styles.dart';

/// Financial disclaimer footer for pages that contain investment-related
/// information (strategies, yields, positions, liquidation scenarios).
class IIDisclaimer extends StatelessWidget {
  const IIDisclaimer({super.key});

  static const _text =
      'Disclaimer: This information is for educational purposes only and does '
      'not constitute financial advice. Please consult with a qualified '
      'financial professional before making any investment decisions.';

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);

    return Padding(
      padding: const EdgeInsets.all(8),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 860),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colors.border, width: 1),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 14, color: colors.textMuted),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _text,
                    style: styles.bodySm.copyWith(color: colors.textMuted),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
