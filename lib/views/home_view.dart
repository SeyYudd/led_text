import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:led_text/models/state_cubit.dart';
import 'package:led_text/views/led_screen.dart';
import 'package:led_text/widgets/switch_text.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/build_section.dart';
import '../widgets/button_widget.dart';
import '../widgets/color_picker_widget.dart';
import '../utils/animation_utils.dart';
import '../widgets/slider_widget.dart';
import '../constants/app_constants.dart';
import '../widgets/gradient_widget.dart';

class LEDTextScreen extends StatefulWidget {
  const LEDTextScreen({super.key});

  @override
  State<LEDTextScreen> createState() => _LEDTextScreenState();
}

class _LEDTextScreenState extends State<LEDTextScreen> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFocusNode = FocusNode();
  bool _isVisible = false;
  bool _showAdvancedSettings = false;
  bool _isLocked = false;
  Timer? _lockTimer;

  final DraggableScrollableController _scrollController =
      DraggableScrollableController();

  @override
  void initState() {
    super.initState();
    _setPortraitMode();

    _isLocked = false;
    _isVisible = false;
    _showAdvancedSettings = false;

    _textFocusNode.addListener(() {
      if (!_textFocusNode.hasFocus) {
        _updateText();
      }
    });
  }

  void _setPortraitMode() {
    //buat jadi ga bisa rotate
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // Set immersive sticky mode for better fullscreen experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFocusNode.dispose();
    _lockTimer?.cancel();
    super.dispose();
  }

  void _updateText() {
    final text = _textController.text.trim();
    if (text.isNotEmpty) {
      context.read<LEDTextCubit>().updateText(text);
    }
  }

  void _startLockTimer() {
    _lockTimer?.cancel(); // Cancel timer sebelumnya jika ada
    _lockTimer = Timer(const Duration(seconds: 2), () {
      if (mounted && _isLocked) {
        setState(() {
          _isVisible = true; // Sembunyikan lock button setelah 2 detik
        });
      }
    });
  }

  void _resetLockTimer() {
    if (_isLocked) {
      _lockTimer?.cancel();
      setState(() {
        _isVisible = false; // Tampilkan lock button
      });
      _startLockTimer(); // Mulai timer baru
    }
  }

  void _cancelLockTimer() {
    _lockTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Stack(
        children: [
          BlocBuilder<LEDTextCubit, LEDTextState>(
            builder: (context, state) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_textController.text != state.currentText) {
                  _textController.text = state.currentText;
                }
              });
              return GestureDetector(
                onTap: () {
                  if (_isLocked) {
                    _resetLockTimer();
                  } else {
                    setState(() {
                      _isVisible = !_isVisible;
                    });
                  }
                },
                child: SizedBox(
                  width: double.infinity,
                  height: double.infinity,
                  child: BlocProvider<LEDTextCubit>.value(
                    value: context.read<LEDTextCubit>(),
                    child: LEDDisplayScreen(isFirst: true),
                  ),
                ),
              );
            },
          ),
          Visibility(
            visible: !_isVisible,
            child: Positioned(
              top: 40,
              right: 20,
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _isLocked = !_isLocked;
                    if (_isLocked) {
                      _startLockTimer();
                      _showAdvancedSettings = false;
                    } else {
                      _cancelLockTimer();
                      _showAdvancedSettings = false;
                    }
                  });
                },
                icon: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    // Hanya gunakan borderRadius jika shape rectangle
                    borderRadius: !_isLocked ? BorderRadius.circular(6) : null,
                    shape: _isLocked ? BoxShape.circle : BoxShape.rectangle,
                  ),
                  child: Icon(
                    _isLocked
                        ? Icons.zoom_in_map_rounded
                        : Icons.zoom_out_map_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),
            ),
          ),

          if (!_isVisible)
            Visibility(
              visible: !_isLocked,
              child: BlocBuilder<LEDTextCubit, LEDTextState>(
                builder: (context, state) {
                  return SafeArea(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        if (_showAdvancedSettings) {
                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Spacer(),
                              sectionAtas(),
                              Flexible(child: sectionBawah(state, context)),
                            ],
                          );
                        } else {
                          return Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(child: SizedBox()),
                              sectionAtas(),
                            ],
                          );
                        }
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget sectionAtas() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              focusNode: _textFocusNode,
              maxLength: 80,
              decoration: InputDecoration(
                hintText: AppConstants.inputTextHint,
                hintStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.black.withValues(alpha: 0.8),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: EdgeInsets.all(16),
              ),
              style: TextStyle(color: Colors.white, fontSize: 16),
              textInputAction: TextInputAction.done,
              onChanged: (value) {
                final upper = value.toString();
                if (value != upper) {
                  final selection = _textController.selection;
                  _textController.value = TextEditingValue(
                    text: upper,
                    selection: selection,
                  );
                }
              },
              onSubmitted: (value) => _updateText(),
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 8),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(8),
            ),
            child: IconButton(
              onPressed: () {
                _resetLockTimer();
                setState(() {
                  _showAdvancedSettings = !_showAdvancedSettings;
                  if (!_showAdvancedSettings) {
                    _scrollController.animateTo(
                      0.3,
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                });
              },
              icon: Icon(
                !_showAdvancedSettings ? Icons.expand_less : Icons.expand_more,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget sectionBawah(LEDTextState state, BuildContext context) {
    return AnimatedContainer(
      height: MediaQuery.of(context).size.height * 0.4,
      duration: Duration(milliseconds: 300),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.3),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: GestureDetector(
        onTap: () => _resetLockTimer(),
        child: ListView(
          shrinkWrap: true,
          children: [
            buildSection(
              AppConstants.arahDanAnimasi,
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      DirectionButton(
                        icon: Icons.arrow_back,
                        label: 'Kiri',
                        isSelected: state.scrollDirection == 0,
                        onTap: () => context
                            .read<LEDTextCubit>()
                            .updateScrollDirection(0),
                      ),
                      DirectionButton(
                        icon: Icons.arrow_upward,
                        label: 'Atas',
                        isSelected: state.scrollDirection == 1,
                        onTap: () => context
                            .read<LEDTextCubit>()
                            .updateScrollDirection(1),
                      ),
                      DirectionButton(
                        icon: Icons.pause,
                        label: 'Diam',
                        isSelected: state.scrollDirection == 2,
                        onTap: () => context
                            .read<LEDTextCubit>()
                            .updateScrollDirection(2),
                      ),
                    ],
                  ),
                  Divider(),
                  if (state.scrollDirection != 2)
                    SliderWidget(
                      label: 'Speed',
                      value: state.scrollSpeed,
                      min: 50.0,
                      max: 800.0,
                      onChanged: (value) =>
                          context.read<LEDTextCubit>().updateScrollSpeed(value),
                    ),
                  if (state.scrollDirection == 2)
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AnimationType.values
                          .map((type) => _buildAnimationButton(type, state))
                          .toList(),
                    ),
                ],
              ),
            ),
            buildSection(
              AppConstants.fontSection,
              Column(
                children: [
                  Row(
                    children: [
                      Text(
                        AppConstants.fontLabel,
                        style: TextStyle(color: Colors.white),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: DropdownButton<String>(
                          value: state.selectedFont,
                          dropdownColor: Colors.black,
                          style: TextStyle(color: Colors.white),
                          isExpanded: true,
                          items: AppConstants.fontOptions
                              .map(
                                (font) => DropdownMenuItem(
                                  value: font,
                                  child: Text(font),
                                ),
                              )
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              context.read<LEDTextCubit>().updateFont(value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  SliderWidget(
                    label: AppConstants.ukuranLabel,
                    value: state.fontSize,
                    min: 20.0,
                    max: 326.0,
                    onChanged: (value) =>
                        context.read<LEDTextCubit>().updateFontSize(value),
                  ),
                ],
              ),
            ),
            buildSection(
              AppConstants.colorsSection,
              Column(
                children: [
                  ColorPickerWidget(
                    label: AppConstants.textColorLabel,
                    color: state.fontColor,
                    onChanged: (color) =>
                        context.read<LEDTextCubit>().updateFontColor(color),
                  ),
                  SizedBox(height: 16),
                  ColorPickerWidget(
                    label: AppConstants.backgroundColorLabel,
                    color: state.backgroundColor,
                    onChanged: (color) => context
                        .read<LEDTextCubit>()
                        .updateBackgroundColor(color),
                  ),
                  SizedBox(height: 16),
                  GradientWidget(),
                ],
              ),
            ),
            if (state.isGradientEnabled == false) _buildBlinkSection(state),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.pinkAccent.shade100.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.favorite, color: Colors.white, size: 18),
                      SizedBox(width: 6),
                      Text(
                        'Versi 1.0.4',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                GestureDetector(
                  onTap: () async {
                    final url = Uri.parse(
                      'https://play.google.com/store/apps/developer?id=Kaka+Sey',
                    );
                    if (await canLaunchUrl(url)) {
                      await launchUrl(
                        url,
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.lightBlueAccent.shade100.withValues(
                        alpha: 0.7,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.code, color: Colors.white, size: 18),
                        SizedBox(width: 6),
                        Text(
                          'find all my apps',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimationButton(AnimationType type, LEDTextState state) {
    bool isSelected = state.currentAnimation == type;
    String label = getAnimationLabel(type);

    return DirectionButton(
      label: label,
      onTap: () {
        context.read<LEDTextCubit>().updateCurrentAnimation(type);
      },
      isSelected: isSelected,
    );
  }

  Widget _buildBlinkSection(LEDTextState state) {
    return buildSection(
      AppConstants.blinkEffects,
      Column(
        spacing: 10,
        children: [
          if (state.scrollDirection != 2)
            SwitchText(
              label: AppConstants.textBlink,
              value: state.isTextBlinking,
              onChanged: (value) =>
                  context.read<LEDTextCubit>().updateTextBlinking(value),
            ),
          if (state.isTextBlinking)
            SliderWidget(
              label: AppConstants.textBlinkSpeed,
              value: state.textBlinkSpeed,
              min: 0.5,
              max: 5.0,
              onChanged: (value) =>
                  context.read<LEDTextCubit>().updateTextBlinkSpeed(value),
            ),
          if (!state.isGradientEnabled) ...[
            SwitchText(
              label: AppConstants.backgroundBlink,
              value: state.isBackgroundBlinking,
              onChanged: (value) =>
                  context.read<LEDTextCubit>().updateBackgroundBlinking(value),
            ),
            if (state.isBackgroundBlinking) ...[
              SliderWidget(
                label: AppConstants.backgroundBlinkSpeed,
                value: state.backgroundBlinkSpeed,
                min: 0.5,
                max: 5.0,
                onChanged: (value) => context
                    .read<LEDTextCubit>()
                    .updateBackgroundBlinkSpeed(value),
              ),
              SizedBox(height: 16),
              ColorPickerWidget(
                label: AppConstants.backgroundBlinkColor,
                color: state.blinkBackgroundColor,
                onChanged: (color) => context
                    .read<LEDTextCubit>()
                    .updateBlinkBackgroundColor(color),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
