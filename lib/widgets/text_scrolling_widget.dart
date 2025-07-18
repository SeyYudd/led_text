import 'package:flutter/material.dart';
import 'package:led_text/models/state_cubit.dart';
import 'package:marquee/marquee.dart';

class TextScrollingWidget extends StatelessWidget {
  final LEDTextState state;
  final Color currentFontColor;
  final String fontFamily;
  const TextScrollingWidget({
    super.key,
    required this.currentFontColor,
    required this.state,
    required this.fontFamily,
  });

  @override
  Widget build(BuildContext context) {
    return Marquee(
      key: ValueKey(
        '${state.scrollDirection}_${state.scrollSpeed}_${state.currentText}',
      ),
      text: state.currentText,
      style: TextStyle(
        fontSize: state.fontSize,
        color: currentFontColor,
        fontFamily: fontFamily,
        fontWeight: FontWeight.bold,
      ),
      scrollAxis: Axis.horizontal,
      crossAxisAlignment: CrossAxisAlignment.center,
      blankSpace: MediaQuery.of(context).size.width,
      velocity: state.scrollSpeed * (state.scrollDirection == 0 ? 1 : -1),
      pauseAfterRound: Duration(seconds: 0),
      startPadding: 10,
      accelerationCurve: Curves.linear,
      decelerationCurve: Curves.easeOut,
    );
  }
}
