// Simplified LEDTextScreen with Animation Support
import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:led_text/models/state_cubit.dart';
import 'package:led_text/views/led_screen.dart';

class LEDTextScreen extends StatefulWidget {
  const LEDTextScreen({super.key});

  @override
  State<LEDTextScreen> createState() => _LEDTextScreenState();
}

class _LEDTextScreenState extends State<LEDTextScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();

  final List<String> _fontOptions = [
    'Default',
    'Monospace',
    'Serif',
    'Sans-serif',
  ];

  @override
  void initState() {
    super.initState();
    _setPortraitMode();

    _textFocusNode.addListener(() {
      if (!_textFocusNode.hasFocus) {
        _updateText();
      }
    });
  }

  void _setPortraitMode() {
    AutoOrientation.portraitAutoMode();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFocusNode.dispose();
    super.dispose();
  }

  void _updateText() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      context.read<LEDTextCubit>().updateText(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],

      body: SafeArea(
        child: BlocBuilder<LEDTextCubit, LEDTextState>(
          builder: (context, state) {
            _textController.text = state.currentText;

            return Column(
              children: [
                // LED Display Preview
                Container(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 0.3,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: Colors.grey, width: 2),
                  ),
                  child: BlocProvider<LEDTextCubit>.value(
                    value: context.read<LEDTextCubit>(),
                    child: LEDDisplayScreen(isFirst: true),
                  ),
                ),

                // Controls
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Text Input
                          _buildSection(
                            'Masukkan Text',
                            TextField(
                              controller: _textController,
                              focusNode: _textFocusNode,
                              decoration: InputDecoration(
                                hintText: 'Input text kamu disini...',
                                hintStyle: TextStyle(color: Colors.white54),
                                filled: true,
                                fillColor: Colors.grey[800],
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: EdgeInsets.all(16),
                              ),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              textInputAction: TextInputAction.done,
                              onSubmitted: (value) => _updateText(),
                            ),
                          ),

                          SizedBox(height: 20),

                          // Movement Direction
                          _buildSection(
                            'Arah ~kalau static bisa buat efek yang lain',
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                _buildDirectionButton(
                                  'Left',
                                  Icons.arrow_back,
                                  0,
                                  state.scrollDirection == 0,
                                ),
                                _buildDirectionButton(
                                  'Static',
                                  Icons.pause,
                                  2,
                                  state.scrollDirection == 2,
                                ),
                                _buildDirectionButton(
                                  'Right',
                                  Icons.arrow_forward,
                                  1,
                                  state.scrollDirection == 1,
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 20),

                          // Font Settings
                          _buildSection(
                            'Font Settings',
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Font: ',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: DropdownButton<String>(
                                        value: state.selectedFont,
                                        dropdownColor: Colors.grey[800],
                                        style: TextStyle(color: Colors.white),
                                        items: _fontOptions.map((font) {
                                          return DropdownMenuItem(
                                            value: font,
                                            child: Text(font),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          if (value != null) {
                                            context
                                                .read<LEDTextCubit>()
                                                .updateFont(value);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 16),
                                _buildSlider(
                                  'Ukuran',
                                  state.fontSize,
                                  20.0,
                                  120.0,
                                  (value) => context
                                      .read<LEDTextCubit>()
                                      .updateFontSize(value),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 20),

                          // Colors
                          _buildSection(
                            'Colors',
                            Column(
                              children: [
                                _buildColorPicker(
                                  'Text Color',
                                  state.fontColor,
                                  (color) => context
                                      .read<LEDTextCubit>()
                                      .updateFontColor(color),
                                ),
                                SizedBox(height: 16),
                                _buildColorPicker(
                                  'Background Color',
                                  state.backgroundColor,
                                  (color) => context
                                      .read<LEDTextCubit>()
                                      .updateBackgroundColor(color),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 20),

                          // Scroll Speed (only show if not static)
                          if (state.scrollDirection != 2)
                            _buildSection(
                              'Scroll Speed',
                              _buildSlider(
                                'Speed',
                                state.scrollSpeed,
                                50.0,
                                800.0,
                                (value) => context
                                    .read<LEDTextCubit>()
                                    .updateScrollSpeed(value),
                              ),
                            ),

                          SizedBox(height: 20),

                          // Blink Effects
                          _buildSection(
                            'Blink Effects',
                            Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Text Blink',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Switch(
                                      value: state.isTextBlinking,
                                      onChanged: (value) => context
                                          .read<LEDTextCubit>()
                                          .updateTextBlinking(value),
                                      activeColor: Colors.blue,
                                    ),
                                  ],
                                ),
                                if (state.isTextBlinking) ...[
                                  SizedBox(height: 8),
                                  _buildSlider(
                                    'Text Blink Speed',
                                    state.textBlinkSpeed,
                                    0.5,
                                    5.0,
                                    (value) => context
                                        .read<LEDTextCubit>()
                                        .updateTextBlinkSpeed(value),
                                  ),
                                ],
                                SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Background Blink',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    Switch(
                                      value: state.isBackgroundBlinking,
                                      onChanged: (value) => context
                                          .read<LEDTextCubit>()
                                          .updateBackgroundBlinking(value),
                                      activeColor: Colors.blue,
                                    ),
                                  ],
                                ),
                                if (state.isBackgroundBlinking) ...[
                                  SizedBox(height: 8),
                                  _buildSlider(
                                    'Background Blink Speed',
                                    state.backgroundBlinkSpeed,
                                    0.5,
                                    5.0,
                                    (value) => context
                                        .read<LEDTextCubit>()
                                        .updateBackgroundBlinkSpeed(value),
                                  ),
                                  SizedBox(height: 16),
                                  _buildColorPicker(
                                    'Background Blink Color',
                                    state.blinkBackgroundColor,
                                    (color) => context
                                        .read<LEDTextCubit>()
                                        .updateBlinkBackgroundColor(color),
                                  ),
                                ],
                              ],
                            ),
                          ),

                          SizedBox(height: 20),

                          // Keep Screen On
                          _buildSection(
                            'Display Options',
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Keep Screen On',
                                  style: TextStyle(color: Colors.white),
                                ),
                                Switch(
                                  value: state.keepScreenOn,
                                  onChanged: (value) => context
                                      .read<LEDTextCubit>()
                                      .updateKeepScreenOn(value),
                                  activeColor: Colors.blue,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        color: Colors.black,
        child: ElevatedButton(
          onPressed: () {
            final cubit = context.read<LEDTextCubit>();
            AutoOrientation.landscapeAutoMode();
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BlocProvider<LEDTextCubit>.value(
                  value: cubit,
                  child: LEDDisplayScreen(isFirst: false),
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            'Mulai LED',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget child) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildDirectionButton(
    String label,
    IconData icon,
    int direction,
    bool isSelected,
  ) {
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
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSlider(
    String label,
    double value,
    double min,
    double max,
    Function(double) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: ${value.toInt()}', style: TextStyle(color: Colors.white)),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: 20,
          activeColor: Colors.blue,
          inactiveColor: Colors.grey,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildColorPicker(
    String label,
    Color color,
    Function(Color) onChanged,
  ) {
    final colors = [
      Colors.white,
      Colors.red,
      Colors.green,
      Colors.blue,
      Colors.yellow,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.cyan,
      Colors.black,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white)),
        SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: colors.map((c) {
            bool isSelected = c.value == color.value;
            return GestureDetector(
              onTap: () => onChanged(c),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: c,
                  border: Border.all(
                    color: isSelected ? Colors.white : Colors.grey,
                    width: isSelected ? 3 : 1,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
