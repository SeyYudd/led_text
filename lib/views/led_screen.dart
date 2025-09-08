// Enhanced LEDDisplayScreen with Animation Effects - Optimized
import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:led_text/models/state_cubit.dart';
import 'package:led_text/widgets/text_scrolling_widget.dart';
import 'dart:math' as math;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:led_text/utils/animation_utils.dart';

class LEDDisplayScreen extends StatefulWidget {
  final bool isFirst;
  const LEDDisplayScreen({super.key, required this.isFirst});

  @override
  State<LEDDisplayScreen> createState() => _LEDDisplayScreenState();
}

class _LEDDisplayScreenState extends State<LEDDisplayScreen>
    with TickerProviderStateMixin {
  // Animation Controllers Map for cleaner management
  Map<AnimationType, AnimationController> _controllers = {};
  Map<AnimationType, Animation<double>> _animations = {};

  // Blink controllers (separate from effect animations)
  AnimationController? _textBlinkController;
  AnimationController? _backgroundBlinkController;
  Animation<double>? _textBlinkAnimation;
  Animation<double>? _backgroundBlinkAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Initialize blink animations
    _textBlinkController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    _backgroundBlinkController = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );

    _textBlinkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textBlinkController!, curve: Curves.linear),
    );
    _backgroundBlinkAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _backgroundBlinkController!,
        curve: Curves.linear,
      ),
    );

    // Initialize effect animation controllers
    _initializeEffectControllers();

    // Start animations with current state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<LEDTextCubit>().state;
      _updateBlinkAnimations(state);
      _updateEffectAnimation(state.currentAnimation);
    });
  }

  void _initializeEffectControllers() {
    // Zoom animation
    _controllers[AnimationType.zoom] = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _animations[AnimationType.zoom] = Tween<double>(begin: 0.8, end: 1.2)
        .animate(
          CurvedAnimation(
            parent: _controllers[AnimationType.zoom]!,
            curve: Curves.easeInOut,
          ),
        );

    // Rotate animation
    _controllers[AnimationType.rotate] = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );
    _animations[AnimationType.rotate] =
        Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
          CurvedAnimation(
            parent: _controllers[AnimationType.rotate]!,
            curve: Curves.linear,
          ),
        );

    // Wave animation
    _controllers[AnimationType.wave] = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _animations[AnimationType.wave] =
        Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
          CurvedAnimation(
            parent: _controllers[AnimationType.wave]!,
            curve: Curves.linear,
          ),
        );

    // Flicker animation
    _controllers[AnimationType.flicker] = AnimationController(
      duration: Duration(milliseconds: 100),
      vsync: this,
    );
    _animations[AnimationType.flicker] = Tween<double>(begin: 0.3, end: 1.0)
        .animate(
          CurvedAnimation(
            parent: _controllers[AnimationType.flicker]!,
            curve: Curves.easeInOut,
          ),
        );
  }

  @override
  void dispose() {
    _exitFullScreen();
    _textBlinkController?.dispose();
    _backgroundBlinkController?.dispose();

    // Dispose all effect controllers
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _exitFullScreen() {
    AutoOrientation.portraitAutoMode();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void _updateBlinkAnimations(LEDTextState state) {
    // Text blink logic
    if (state.isTextBlinking) {
      _textBlinkController?.duration = Duration(
        milliseconds: (1000 / state.textBlinkSpeed).round(),
      );
      if (!(_textBlinkController?.isAnimating ?? false)) {
        _textBlinkController?.repeat(reverse: true);
      }
    } else {
      _textBlinkController?.stop();
      _textBlinkController?.reset();
    }

    // Background blink logic
    if (state.isBackgroundBlinking) {
      _backgroundBlinkController?.duration = Duration(
        milliseconds: (1000 / state.backgroundBlinkSpeed).round(),
      );
      if (!(_backgroundBlinkController?.isAnimating ?? false)) {
        _backgroundBlinkController?.repeat(reverse: true);
      }
    } else {
      _backgroundBlinkController?.stop();
      _backgroundBlinkController?.reset();
    }
  }

  void _updateEffectAnimation(AnimationType type) {
    // Stop all effect animations first
    _controllers.values.forEach((controller) {
      controller.stop();
      controller.reset();
    });

    // Start the selected animation
    switch (type) {
      case AnimationType.zoom:
        _controllers[type]?.repeat(reverse: true);
        break;
      case AnimationType.rotate:
        _controllers[type]?.repeat();
        break;
      case AnimationType.wave:
        _controllers[type]?.repeat();
        break;

      case AnimationType.flicker:
        _startFlickerAnimation();
        break;
      case AnimationType.none:
        break;
    }
  }

  void _startFlickerAnimation() {
    final controller = _controllers[AnimationType.flicker];
    controller?.forward().then((_) {
      controller.reverse().then((_) {
        if (mounted) {
          Future.delayed(
            Duration(milliseconds: math.Random().nextInt(200) + 50),
            () {
              final currentState = context.read<LEDTextCubit>().state;
              if (currentState.currentAnimation == AnimationType.flicker) {
                _startFlickerAnimation();
              }
            },
          );
        }
      });
    });
  }

  String _getFontFamily(String font) {
    switch (font) {
      case 'Monospace':
        return 'monospace';
      case 'Serif':
        return 'serif';
      case 'Sans-serif':
        return 'sans-serif';
      default:
        return 'default';
    }
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

  Widget _buildAnimatedText(LEDTextState state, Color currentFontColor) {
    Widget textWidget = RotatedBox(
      quarterTurns: 1,
      child: AutoSizeText(
        state.currentText,
        // minFontSize: 300,
        style: TextStyle(
          fontSize: state.fontSize,
          color: currentFontColor,
          fontFamily: _getFontFamily(state.selectedFont),
          fontWeight: FontWeight.bold,
        ),
      ),
    );

    final animation = _animations[state.currentAnimation];
    if (animation == null) return textWidget;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        switch (state.currentAnimation) {
          case AnimationType.zoom:
            return Transform.scale(scale: animation.value, child: textWidget);

          case AnimationType.rotate:
            return Transform.rotate(angle: animation.value, child: textWidget);

          case AnimationType.wave:
            return Transform.translate(
              offset: Offset(0, math.sin(animation.value) * 20),
              child: textWidget,
            );

          case AnimationType.flicker:
            return Opacity(opacity: animation.value, child: textWidget);

          default:
            return textWidget;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocListener<LEDTextCubit, LEDTextState>(
        listener: (context, state) {
          _updateBlinkAnimations(state);
          _updateEffectAnimation(state.currentAnimation);

          if (state.keepScreenOn) {
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
          }
        },
        child: BlocBuilder<LEDTextCubit, LEDTextState>(
          builder: (context, state) {
            return AnimatedBuilder(
              animation: Listenable.merge([
                _textBlinkAnimation ?? const AlwaysStoppedAnimation(0.0),
                _backgroundBlinkAnimation ?? const AlwaysStoppedAnimation(0.0),
              ]),
              builder: (context, child) {
                // Calculate current colors with blink effects
                Color currentBackgroundColor = state.backgroundColor;
                Color currentFontColor = state.fontColor;

                if (state.isBackgroundBlinking &&
                    _backgroundBlinkAnimation != null) {
                  currentBackgroundColor = Color.lerp(
                    state.backgroundColor,
                    state.blinkBackgroundColor,
                    _backgroundBlinkAnimation!.value,
                  )!;
                }

                if (state.isTextBlinking && _textBlinkAnimation != null) {
                  currentFontColor = state.fontColor.withValues(
                    alpha: 1.0 - _textBlinkAnimation!.value,
                  );
                }

                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: state.isGradientEnabled
                        ? null
                        : currentBackgroundColor,
                    gradient: state.isGradientEnabled
                        ? _buildGradient(state)
                        : null,
                  ),
                  child: Center(
                    child: state.scrollDirection == 2
                        ? _buildAnimatedText(state, currentFontColor)
                        : TextScrollingWidget(
                            currentFontColor: currentFontColor,
                            state: state,
                            fontFamily: _getFontFamily(state.selectedFont),
                          ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
