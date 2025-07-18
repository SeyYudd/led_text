import 'package:flutter/material.dart';

class SwitchWidget extends StatelessWidget {
  final String label;
  final bool value;
  final Function(bool) onChanged;
  const SwitchWidget({
    super.key,
    required this.label,
    required this.onChanged,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.white70)),
        Switch(value: value, onChanged: onChanged),
      ],
    );
  }
}
