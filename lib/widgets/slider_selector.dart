import 'package:flutter/material.dart';
import 'package:indigo_insights/theme/color_scheme.dart';

class SliderSelector extends StatefulWidget {
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
  State<SliderSelector> createState() => _SliderSelectorState();
}

class _SliderSelectorState extends State<SliderSelector> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  @override
  void didUpdateWidget(SliderSelector oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialValue != widget.initialValue) {
      _currentValue = widget.initialValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        children: [
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: _currentValue,
                  min: widget.minValue,
                  max: widget.maxValue,
                  divisions: (widget.maxValue - widget.minValue).toInt(),
                  label:
                      '${_currentValue.toStringAsFixed(widget.decimalPlaces ?? 0)}${widget.unit}',
                  onChanged: (value) {
                    setState(() => _currentValue = value);
                    widget.onChanged(value);
                  },
                  activeColor: widget.activeColor ?? primaryPurple,
                  thumbColor: widget.thumbColor ?? Colors.white,
                  inactiveColor:
                      widget.inactiveColor ?? Colors.white.withAlpha(100),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 50,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Text(
                '${widget.label}: ${widget.minValue.toStringAsFixed(widget.decimalPlaces ?? 0)}${widget.unit} - ${widget.maxValue.toStringAsFixed(widget.decimalPlaces ?? 0)}${widget.unit}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: widget.textColor ?? Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
