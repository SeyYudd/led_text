import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:led_text/models/state_cubit.dart';
import 'package:led_text/widgets/button_widget.dart';
import 'package:led_text/widgets/color_picker_widget.dart';

class GradientWidget extends StatelessWidget {
  const GradientWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LEDTextCubit, LEDTextState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gradient Enable Switch
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Enable Gradient:',
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                ),
                Switch(
                  value: state.isGradientEnabled,
                  onChanged: (value) {
                    context.read<LEDTextCubit>().updateGradientEnabled(value);
                  },
                  activeThumbColor: Colors.blue,
                ),
              ],
            ),
            SizedBox(height: 16),

            if (state.isGradientEnabled) ...[
              // Gradient Direction
              Text(
                'Gradient Direction',
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  DirectionButton(
                    label: 'Horizontal',
                    icon: Icons.arrow_forward,
                    onTap: () {
                      context.read<LEDTextCubit>().updateGradientDirection(0);
                    },
                    isSelected: state.gradientDirection == 0,
                  ),
                  DirectionButton(
                    label: 'Vertical',
                    icon: Icons.arrow_downward,
                    onTap: () {
                      context.read<LEDTextCubit>().updateGradientDirection(1);
                    },
                    isSelected: state.gradientDirection == 1,
                  ),
                  DirectionButton(
                    label: 'Diagonal',
                    icon: Icons.call_missed_outgoing,
                    onTap: () {
                      context.read<LEDTextCubit>().updateGradientDirection(2);
                    },
                    isSelected: state.gradientDirection == 2,
                  ),
                ],
              ),
              SizedBox(height: 16),

              // Gradient Colors
              ColorPickerWidget(
                label: 'Start Color',
                color: state.gradientStartColor,
                onChanged: (color) {
                  context.read<LEDTextCubit>().updateGradientStartColor(color);
                },
              ),
              SizedBox(height: 16),
              ColorPickerWidget(
                label: 'End Color',
                color: state.gradientEndColor,
                onChanged: (color) {
                  context.read<LEDTextCubit>().updateGradientEndColor(color);
                },
              ),

              // Preview
              SizedBox(height: 16),
              Container(
                height: 50,
                decoration: BoxDecoration(
                  gradient: _buildGradient(state),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                ),
                child: Center(
                  child: Text(
                    'Gradient Preview',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  LinearGradient _buildGradient(LEDTextState state) {
    Alignment begin, end;

    switch (state.gradientDirection) {
      case 0: // Horizontal
        begin = Alignment.centerLeft;
        end = Alignment.centerRight;
        break;
      case 1: // Vertical
        begin = Alignment.topCenter;
        end = Alignment.bottomCenter;
        break;
      case 2: // Diagonal
        begin = Alignment.topLeft;
        end = Alignment.bottomRight;
        break;
      default:
        begin = Alignment.topCenter;
        end = Alignment.bottomCenter;
    }

    return LinearGradient(
      begin: begin,
      end: end,
      colors: [state.gradientStartColor, state.gradientEndColor],
    );
  }
}
