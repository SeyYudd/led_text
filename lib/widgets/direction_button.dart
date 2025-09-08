import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:led_text/models/state_cubit.dart';

class DirectionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final int direction;
  final bool isSelected;
  const DirectionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.direction,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () =>
          context.read<LEDTextCubit>().updateScrollDirection(direction),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey[700],
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Column(
        spacing: 4,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
