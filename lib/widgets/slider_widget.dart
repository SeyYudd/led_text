import 'package:flutter/material.dart';

class SliderWidget extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final int divisions;
  final Function(double) onChanged;
  const SliderWidget({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.divisions,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$label: ', style: TextStyle(color: Colors.white70)),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            label: value.round().toString(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
