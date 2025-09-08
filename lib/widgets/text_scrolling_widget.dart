import 'package:flutter/material.dart';
import 'package:led_text/models/state_cubit.dart';
import 'package:marquee/marquee.dart';
import 'package:google_fonts/google_fonts.dart';

class TextScrollingWidget extends StatelessWidget {
  final LEDTextState state;
  final Color currentFontColor;
  final String selectedFont;
  const TextScrollingWidget({
    super.key,
    required this.currentFontColor,
    required this.state,
    required this.selectedFont,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle style;
    switch (selectedFont) {
      case 'Roboto':
        style = GoogleFonts.roboto(
          fontSize: state.fontSize,
          color: currentFontColor,
          fontWeight: FontWeight.bold,
        );
        break;
      case 'Lato':
        style = GoogleFonts.lato(
          fontSize: state.fontSize,
          color: currentFontColor,
          fontWeight: FontWeight.bold,
        );
        break;
      case 'Oswald':
        style = GoogleFonts.oswald(
          fontSize: state.fontSize,
          color: currentFontColor,
          fontWeight: FontWeight.bold,
        );
        break;
      case 'Montserrat':
        style = GoogleFonts.montserrat(
          fontSize: state.fontSize,
          color: currentFontColor,
          fontWeight: FontWeight.bold,
        );
        break;
      case 'Poppins':
        style = GoogleFonts.poppins(
          fontSize: state.fontSize,
          color: currentFontColor,
          fontWeight: FontWeight.bold,
        );
        break;
      case 'Raleway':
        style = GoogleFonts.raleway(
          fontSize: state.fontSize,
          color: currentFontColor,
          fontWeight: FontWeight.bold,
        );
        break;
      case 'Merriweather':
        style = GoogleFonts.merriweather(
          fontSize: state.fontSize,
          color: currentFontColor,
          fontWeight: FontWeight.bold,
        );
        break;
      case 'Open Sans':
        style = GoogleFonts.openSans(
          fontSize: state.fontSize,
          color: currentFontColor,
          fontWeight: FontWeight.bold,
        );
        break;
      case 'Nunito':
        style = GoogleFonts.nunito(
          fontSize: state.fontSize,
          color: currentFontColor,
          fontWeight: FontWeight.bold,
        );
        break;
      case 'Quicksand':
        style = GoogleFonts.quicksand(
          fontSize: state.fontSize,
          color: currentFontColor,
          fontWeight: FontWeight.bold,
        );
        break;
      case 'Bebas Neue':
        style = GoogleFonts.bebasNeue(
          fontSize: state.fontSize,
          color: currentFontColor,
          fontWeight: FontWeight.bold,
        );
        break;
      case 'Dancing Script':
        style = GoogleFonts.dancingScript(
          fontSize: state.fontSize,
          color: currentFontColor,
          fontWeight: FontWeight.bold,
        );
        break;
      case 'Pacifico':
        style = GoogleFonts.pacifico(
          fontSize: state.fontSize,
          color: currentFontColor,
          fontWeight: FontWeight.bold,
        );
        break;
      case 'Indie Flower':
        style = GoogleFonts.indieFlower(
          fontSize: state.fontSize,
          color: currentFontColor,
          fontWeight: FontWeight.bold,
        );
        break;
      case 'Orbitron':
        style = GoogleFonts.orbitron(
          fontSize: state.fontSize,
          color: currentFontColor,
          fontWeight: FontWeight.bold,
        );
        break;
      case 'Anton':
        style = GoogleFonts.anton(
          fontSize: state.fontSize,
          color: currentFontColor,
          fontWeight: FontWeight.bold,
        );
        break;
      case 'Bangers':
        style = GoogleFonts.bangers(
          fontSize: state.fontSize,
          color: currentFontColor,
          fontWeight: FontWeight.bold,
        );
        break;
      case 'Monospace':
        style = TextStyle(
          fontSize: state.fontSize,
          color: currentFontColor,
          fontFamily: 'monospace',
          fontWeight: FontWeight.bold,
        );
        break;
      case 'Serif':
        style = TextStyle(
          fontSize: state.fontSize,
          color: currentFontColor,
          fontFamily: 'serif',
          fontWeight: FontWeight.bold,
        );
        break;
      case 'Sans-serif':
        style = TextStyle(
          fontSize: state.fontSize,
          color: currentFontColor,
          fontFamily: 'sans-serif',
          fontWeight: FontWeight.bold,
        );
        break;
      default:
        style = TextStyle(
          fontSize: state.fontSize,
          color: currentFontColor,
          fontWeight: FontWeight.bold,
        );
    }
    return RotatedBox(
      quarterTurns: state.scrollDirection,
      child: Marquee(
        key: ValueKey(
          '${state.scrollDirection}_${state.scrollSpeed}_${state.currentText}',
        ),
        text: state.currentText,
        style: style,
        scrollAxis: Axis.horizontal,
        crossAxisAlignment: CrossAxisAlignment.center,
        blankSpace: MediaQuery.of(context).size.width,
        velocity: state.scrollSpeed,
        pauseAfterRound: Duration(seconds: 0),
        startPadding: 10,
        accelerationCurve: Curves.linear,
        decelerationCurve: Curves.easeOut,
      ),
    );
  }
}
