import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:indigo_insights/theme/color_scheme.dart';

class SliderSelector extends HookWidget {
  final double initialValue;
  final double minValue;
  final double maxValue;
  final String label;
  final String unit;
  final ValueChanged<double> onChanged;
  final int? decimalPlaces;
  final Color? activeColor;
  final Color? thumbColor;
  final Color? inactiveColor;
  final Color? textColor;

  const SliderSelector({
    super.key,
    required this.initialValue,
    required this.minValue,
    required this.maxValue,
    required this.label,
    required this.onChanged,
    this.unit = '',
    this.decimalPlaces = 0,
    this.activeColor,
    this.thumbColor,
    this.inactiveColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final currentValue = useState(initialValue);

    // Update current value when onChanged is called
    useEffect(() {
      currentValue.value = initialValue;
      return null;
    }, [initialValue]);

    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: currentValue.value,
                  min: minValue,
                  max: maxValue,
                  divisions: (maxValue - minValue).toInt(),
                  label:
                      '${currentValue.value.toStringAsFixed(decimalPlaces ?? 0)}$unit',
                  onChanged: (value) {
                    currentValue.value = value;
                    onChanged(value);
                  },
                  activeColor: activeColor ?? primaryPurple,
                  thumbColor: thumbColor ?? Colors.white,
                  inactiveColor: inactiveColor ?? Colors.white.withAlpha(100),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 50,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                '$label: ${minValue.toStringAsFixed(decimalPlaces ?? 0)}$unit - ${maxValue.toStringAsFixed(decimalPlaces ?? 0)}$unit',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: textColor ?? Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
