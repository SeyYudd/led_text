import 'package:flutter/material.dart';

class DirectionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onTap;
  final bool isSelected;

  const DirectionButton({
    super.key,
    required this.label,
    this.icon,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey[700],
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon != null ? Icon(icon, size: 16) : SizedBox(),
          SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}
