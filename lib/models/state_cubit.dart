import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:led_text/utils/animation_utils.dart';

class LEDTextState {
  final String currentText;
  final List<String> textHistory;
  final int scrollDirection;
  final double scrollSpeed;
  final bool isTextBlinking;
  final double textBlinkSpeed;
  final bool isBackgroundBlinking;
  final double backgroundBlinkSpeed;
  final String selectedFont;
  final double fontSize;
  final Color fontColor;
  final Color backgroundColor;
  final Color blinkBackgroundColor;
  final bool isScrolling;
  final AnimationType currentAnimation;
  // Gradient properties
  final bool isGradientEnabled;
  final Color gradientStartColor;
  final Color gradientEndColor;
  final int gradientDirection; // 0: horizontal, 1: vertical, 2: diagonal

  LEDTextState({
    this.currentText = 'LED Text Bergulir',
    this.textHistory = const [],
    this.scrollDirection = 1,
    this.scrollSpeed = 50.0,
    this.currentAnimation = AnimationType.none,
    this.isTextBlinking = false,
    this.textBlinkSpeed = 1.0,
    this.isBackgroundBlinking = false,
    this.backgroundBlinkSpeed = 1.0,
    this.selectedFont = 'Default',
    this.fontSize = 24.0,
    this.fontColor = Colors.black,
    this.backgroundColor = Colors.white,
    this.blinkBackgroundColor = Colors.red,
    this.isScrolling = false,
    // Gradient defaults
    this.isGradientEnabled = false,
    this.gradientStartColor = Colors.black,
    this.gradientEndColor = Colors.blue,
    this.gradientDirection = 1, // vertical by default
  });

  LEDTextState copyWith({
    String? currentText,
    List<String>? textHistory,
    int? scrollDirection,
    double? scrollSpeed,
    bool? isTextBlinking,
    AnimationType? currentAnimation,
    double? textBlinkSpeed,
    bool? isBackgroundBlinking,
    double? backgroundBlinkSpeed,
    String? selectedFont,
    double? fontSize,
    Color? fontColor,
    Color? backgroundColor,
    Color? blinkBackgroundColor,
    bool? isScrolling,
    // Gradient parameters
    bool? isGradientEnabled,
    Color? gradientStartColor,
    Color? gradientEndColor,
    int? gradientDirection,
  }) {
    return LEDTextState(
      currentText: currentText ?? this.currentText,
      textHistory: textHistory ?? this.textHistory,
      currentAnimation: currentAnimation ?? this.currentAnimation,
      scrollDirection: scrollDirection ?? this.scrollDirection,
      scrollSpeed: scrollSpeed ?? this.scrollSpeed,
      isTextBlinking: isTextBlinking ?? this.isTextBlinking,
      textBlinkSpeed: textBlinkSpeed ?? this.textBlinkSpeed,
      isBackgroundBlinking: isBackgroundBlinking ?? this.isBackgroundBlinking,
      backgroundBlinkSpeed: backgroundBlinkSpeed ?? this.backgroundBlinkSpeed,
      selectedFont: selectedFont ?? this.selectedFont,
      fontSize: fontSize ?? this.fontSize,
      fontColor: fontColor ?? this.fontColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      blinkBackgroundColor: blinkBackgroundColor ?? this.blinkBackgroundColor,
      isScrolling: isScrolling ?? this.isScrolling,
      // Gradient properties
      isGradientEnabled: isGradientEnabled ?? this.isGradientEnabled,
      gradientStartColor: gradientStartColor ?? this.gradientStartColor,
      gradientEndColor: gradientEndColor ?? this.gradientEndColor,
      gradientDirection: gradientDirection ?? this.gradientDirection,
    );
  }
}

class LEDTextCubit extends Cubit<LEDTextState> {
  LEDTextCubit() : super(LEDTextState()) {
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getStringList('text_history') ?? [];
    final currentText = prefs.getString('current_text') ?? 'Disini Isi Teks Kamu...';
    final animationString = prefs.getString('current_animation');

    AnimationType currentAnimation = AnimationType.none;
    if (animationString != null) {
      currentAnimation = AnimationType.values.firstWhere(
        (e) => e.toString() == 'AnimationType.$animationString',
        orElse: () => AnimationType.none,
      );
    }

    emit(
      state.copyWith(
        currentText: currentText,
        textHistory: historyJson,
        currentAnimation: currentAnimation,
        scrollDirection: prefs.getInt('scroll_direction') ?? 1,
        scrollSpeed: prefs.getDouble('scroll_speed') ?? 125.0,
        isTextBlinking: prefs.getBool('is_text_blinking') ?? false,
        textBlinkSpeed: prefs.getDouble('text_blink_speed') ?? 1.0,
        isBackgroundBlinking: prefs.getBool('is_background_blinking') ?? false,
        backgroundBlinkSpeed: prefs.getDouble('background_blink_speed') ?? 1.0,
        selectedFont: prefs.getString('selected_font') ?? 'Default',
        fontSize: prefs.getDouble('font_size') ?? 96.0,
        fontColor: Color(prefs.getInt('font_color') ?? Colors.black.value),
        backgroundColor: Color(
          prefs.getInt('background_color') ?? Colors.white.value,
        ),
        blinkBackgroundColor: Color(
          prefs.getInt('blink_background_color') ?? Colors.red.value,
        ),
        // Gradient properties
        isGradientEnabled: prefs.getBool('is_gradient_enabled') ?? false,
        gradientStartColor: Color(
          prefs.getInt('gradient_start_color') ?? Colors.black.value,
        ),
        gradientEndColor: Color(
          prefs.getInt('gradient_end_color') ?? Colors.blue.value,
        ),
        gradientDirection: prefs.getInt('gradient_direction') ?? 1,
      ),
    );
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('current_animation', state.currentAnimation.name);
    await prefs.setStringList('text_history', state.textHistory);
    await prefs.setString('current_text', state.currentText);
    await prefs.setInt('scroll_direction', state.scrollDirection);
    await prefs.setDouble('scroll_speed', state.scrollSpeed);
    await prefs.setBool('is_text_blinking', state.isTextBlinking);
    await prefs.setDouble('text_blink_speed', state.textBlinkSpeed);
    await prefs.setBool('is_background_blinking', state.isBackgroundBlinking);
    await prefs.setDouble('background_blink_speed', state.backgroundBlinkSpeed);
    await prefs.setString('selected_font', state.selectedFont);
    await prefs.setDouble('font_size', state.fontSize);
    await prefs.setInt('font_color', state.fontColor.value);
    await prefs.setInt('background_color', state.backgroundColor.value);
    await prefs.setInt(
      'blink_background_color',
      state.blinkBackgroundColor.value,
    );
    // Gradient properties
    await prefs.setBool('is_gradient_enabled', state.isGradientEnabled);
    await prefs.setInt('gradient_start_color', state.gradientStartColor.value);
    await prefs.setInt('gradient_end_color', state.gradientEndColor.value);
    await prefs.setInt('gradient_direction', state.gradientDirection);
  }

  void updateCurrentAnimation(AnimationType animation) {
    emit(state.copyWith(currentAnimation: animation));
    _saveData();
  }

  void updateText(String text) {
    if (text.isNotEmpty && text != state.currentText) {
      List<String> newHistory = List.from(state.textHistory);
      if (!newHistory.contains(text)) {
        newHistory.insert(0, text);
        if (newHistory.length > 20) {
          newHistory = newHistory.take(20).toList();
        }
      }
      emit(state.copyWith(currentText: text, textHistory: newHistory));
      _saveData();
    }
  }

  void selectFromHistory(String text) {
    emit(state.copyWith(currentText: text));
    _saveData();
  }

  void deleteFromHistory(String text) {
    List<String> newHistory = List.from(state.textHistory);
    newHistory.remove(text);
    emit(state.copyWith(textHistory: newHistory));
    _saveData();
  }

  void clearHistory() {
    emit(state.copyWith(textHistory: []));
    _saveData();
  }

  void updateScrollDirection(int direction) {
    emit(state.copyWith(scrollDirection: direction));
    _saveData();
  }

  void updateScrollSpeed(double speed) {
    emit(state.copyWith(scrollSpeed: speed));
    _saveData();
  }

  void updateTextBlinking(bool isBlinking) {
    emit(state.copyWith(isTextBlinking: isBlinking));
    _saveData();
  }

  void updateTextBlinkSpeed(double speed) {
    emit(state.copyWith(textBlinkSpeed: speed));
    _saveData();
  }

  void updateBackgroundBlinking(bool isBlinking) {
    emit(state.copyWith(isBackgroundBlinking: isBlinking));
    _saveData();
  }

  void updateBackgroundBlinkSpeed(double speed) {
    emit(state.copyWith(backgroundBlinkSpeed: speed));
    _saveData();
  }

  void updateFont(String font) {
    emit(state.copyWith(selectedFont: font));
    _saveData();
  }

  void updateFontSize(double size) {
    emit(state.copyWith(fontSize: size));
    _saveData();
  }

  void updateFontColor(Color color) {
    emit(state.copyWith(fontColor: color));
    _saveData();
  }

  void updateBackgroundColor(Color color) {
    emit(state.copyWith(backgroundColor: color));
    _saveData();
  }

  void updateBlinkBackgroundColor(Color color) {
    emit(state.copyWith(blinkBackgroundColor: color));
    _saveData();
  }

  void startScrolling() {
    emit(state.copyWith(isScrolling: true));
  }

  void stopScrolling() {
    emit(state.copyWith(isScrolling: false));
  }

  void updateGradientEnabled(bool enabled) {
    emit(state.copyWith(isGradientEnabled: enabled));
    _saveData();
  }

  void updateGradientStartColor(Color color) {
    emit(state.copyWith(gradientStartColor: color));
    _saveData();
  }

  void updateGradientEndColor(Color color) {
    emit(state.copyWith(gradientEndColor: color));
    _saveData();
  }

  void updateGradientDirection(int direction) {
    emit(state.copyWith(gradientDirection: direction));
    _saveData();
  }
}
