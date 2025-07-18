import 'package:flutter/material.dart';

class DropdownFont extends StatelessWidget {
  final String label;
  final String value;
  final List<String> options;
  final Function(String?) onChanged;
  const DropdownFont({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$label: ', style: TextStyle(color: Colors.white70)),
        Expanded(
          child: DropdownButton<String>(
            value: value,
            dropdownColor: Colors.grey[800],
            style: TextStyle(color: Colors.white),
            items: options.map((option) {
              return DropdownMenuItem(value: option, child: Text(option));
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
