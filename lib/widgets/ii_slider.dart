import 'package:flutter/material.dart';
import 'package:indigo_insights/theme/app_color_scheme.dart';
import 'package:indigo_insights/theme/app_text_styles.dart';

/// Design-system slider control.
///
/// Wraps Flutter's native [Slider] — inherits all native accessibility,
/// keyboard interaction, and platform semantics.
class IISlider extends StatefulWidget {
  const IISlider({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.unit = '',
    this.decimalPlaces = 0,
    this.divisions,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;
  final String unit;
  final int decimalPlaces;
  final int? divisions;

  @override
  State<IISlider> createState() => _IISliderState();
}

class _IISliderState extends State<IISlider> {
  late double _current;

  @override
  void initState() {
    super.initState();
    _current = widget.value;
  }

  @override
  void didUpdateWidget(IISlider old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) _current = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColorScheme.of(context);
    final styles = AppTextStyles.of(context);

    final formatted = _current.toStringAsFixed(widget.decimalPlaces);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              '${widget.label}: ',
              style: styles.bodySm.copyWith(color: colors.textSecondary),
            ),
            Text(
              '$formatted${widget.unit}',
              style: styles.bodySm.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Text(
              '${widget.min.toStringAsFixed(widget.decimalPlaces)}${widget.unit} – '
              '${widget.max.toStringAsFixed(widget.decimalPlaces)}${widget.unit}',
              style: styles.bodySm.copyWith(color: colors.textMuted),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: colors.primary,
            inactiveTrackColor: colors.surfaceRaised,
            thumbColor: colors.textPrimary,
            overlayColor: colors.primarySurface,
            valueIndicatorColor: colors.surface,
            valueIndicatorTextStyle: styles.bodyMd,
            trackHeight: 3,
          ),
          child: Slider(
            value: _current,
            min: widget.min,
            max: widget.max,
            divisions: widget.divisions ??
                ((widget.max - widget.min) * 10).round(),
            label: '$formatted${widget.unit}',
            onChanged: (v) {
              setState(() => _current = v);
              widget.onChanged(v);
            },
          ),
        ),
      ],
    );
  }
}
