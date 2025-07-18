import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerWidget extends StatelessWidget {
  final String label;
  final Color color;
  final Function(Color) onChanged;
  const ColorPickerWidget({
    super.key,
    required this.label,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('$label: ', style: TextStyle(color: Colors.white70)),
        Expanded(
          child: GestureDetector(
            onTap: () => _showColorPicker(context, color, onChanged),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: color,
                border: Border.all(color: Colors.white),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  'Pilih Warna',
                  style: TextStyle(
                    color: color.computeLuminance() > 0.5
                        ? Colors.black
                        : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _showColorPicker(
    BuildContext context,
    Color currentColor,
    Function(Color) onColorChanged,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Pilih Warna'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: currentColor,
              onColorChanged: onColorChanged,
              enableAlpha: false,
              displayThumbColor: true,
              showLabel: true,
              paletteType: PaletteType.hsv,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Selesai'),
            ),
          ],
        );
      },
    );
  }
}
