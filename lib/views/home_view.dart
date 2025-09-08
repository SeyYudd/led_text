import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:led_text/models/state_cubit.dart';
import 'package:led_text/views/led_screen.dart';
import 'package:led_text/widgets/switch_text.dart';

import '../widgets/build_section.dart';
import '../widgets/color_picker_widget.dart';
import '../utils/animation_utils.dart';
import '../widgets/direction_button.dart';
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

    // Pastikan semua state dimulai dengan benar saat aplikasi pertama kali masuk
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
                  // Reset timer ketika ada aktivitas di layar
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
                      // Mulai timer ketika lock aktif
                      _startLockTimer();
                      _showAdvancedSettings = false;
                    } else {
                      // Cancel timer ketika unlock
                      _cancelLockTimer();
                      _showAdvancedSettings = false;
                    }
                  });
                },
                icon: Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    !_isLocked ? Icons.lock_open : Icons.lock,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
          ),
          !_isVisible
              ? Visibility(
                  visible: !_isLocked,
                  child: BlocBuilder<LEDTextCubit, LEDTextState>(
                    builder: (context, state) {
                      return Positioned(
                        top: 40,
                        left: 20,
                        child: Container(
                          padding: EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              Switch(
                                activeColor: Colors.blue,
                                value: state.keepScreenOn,
                                onChanged: (value) => context
                                    .read<LEDTextCubit>()
                                    .updateKeepScreenOn(value),
                              ),
                              Text(
                                AppConstants.nyalaTerus,
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                )
              : SizedBox(),

          !_isVisible
              ? Visibility(
                  visible: !_isLocked,
                  child: BlocBuilder<LEDTextCubit, LEDTextState>(
                    builder: (context, state) {
                      return SafeArea(
                        child: DraggableScrollableSheet(
                          initialChildSize: 0.2,
                          minChildSize: 0.2,
                          maxChildSize: _showAdvancedSettings ? 0.8 : 0.2,
                          controller: _scrollController,
                          builder: (context, scrollController) {
                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              child: SingleChildScrollView(
                                controller: scrollController,
                                child: GestureDetector(
                                  onTap: () {
                                    // Reset timer ketika ada aktivitas di controls
                                    _resetLockTimer();
                                  },
                                  child: Column(
                                    spacing: 16,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      //section atas
                                      sectionAtas(),
                                      //section bawah
                                      sectionBawah(state, context),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }

  Row sectionAtas() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => _resetLockTimer(),
            child: TextField(
              controller: _textController,
              focusNode: _textFocusNode,
              decoration: InputDecoration(
                hintText: AppConstants.inputTextHint,
                hintStyle: TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.grey[800],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: EdgeInsets.all(16),
              ),
              style: TextStyle(color: Colors.white, fontSize: 16),
              textInputAction: TextInputAction.done,
              onSubmitted: (value) => _updateText(),
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 8),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(8),
          ),
          child: IconButton(
            onPressed: () {
              _resetLockTimer(); // Reset timer ketika expand button diklik
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
              _showAdvancedSettings ? Icons.more : Icons.expand_more,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Visibility sectionBawah(LEDTextState state, BuildContext context) {
    return Visibility(
      visible: _showAdvancedSettings,
      child: GestureDetector(
        onTap: () => _resetLockTimer(),
        child: Column(
          spacing: 16,
          children: [
            buildSection(
              AppConstants.arahDanAnimasi,
              Column(
                spacing: 10,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      DirectionButton(
                        label: AppConstants.samping,
                        icon: Icons.arrow_back,
                        direction: 0,
                        isSelected: state.scrollDirection == 0,
                      ),
                      DirectionButton(
                        label: AppConstants.atas,
                        icon: Icons.arrow_upward,
                        direction: 1,
                        isSelected: state.scrollDirection == 1,
                      ),
                      DirectionButton(
                        label: AppConstants.stop,
                        icon: Icons.pause,
                        direction: 2,
                        isSelected: state.scrollDirection == 2,
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
                spacing: 16,
                children: [
                  Row(
                    spacing: 10,
                    children: [
                      Text(
                        AppConstants.fontLabel,
                        style: TextStyle(color: Colors.white),
                      ),
                      Expanded(
                        child: DropdownButton<String>(
                          value: state.selectedFont,
                          dropdownColor: Colors.grey[700],
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
                    max: 400.0,
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
            _buildBlinkSection(state),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimationButton(AnimationType type, LEDTextState state) {
    bool isSelected = state.currentAnimation == type;
    String label = getAnimationLabel(type);

    return ElevatedButton(
      onPressed: () {
        context.read<LEDTextCubit>().updateCurrentAnimation(type);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey[700],
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label, style: TextStyle(fontSize: 11)),
    );
  }

  Widget _buildBlinkSection(LEDTextState state) {
    return buildSection(
      AppConstants.blinkEffects,
      Column(
        spacing: 10,
        children: [
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
