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
    return Column(
      children: [
        IconButton(
          onPressed: () {
            context.read<LEDTextCubit>().updateScrollDirection(direction);
          },
          icon: Icon(
            icon,
            size: 40,
            color: isSelected ? Colors.blue : Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.blue : Colors.white70,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
