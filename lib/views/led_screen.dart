// Enhanced LEDDisplayScreen with Animation Effects
import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:led_text/models/state_cubit.dart';
import 'package:led_text/widgets/text_scrolling_widget.dart';
import 'dart:math' as math;

enum AnimationType { none, zoom, rotate, wave, bounce, flicker }

class LEDDisplayScreen extends StatefulWidget {
  final bool isFirst;
  const LEDDisplayScreen({super.key, required this.isFirst});

  @override
  State<LEDDisplayScreen> createState() => _LEDDisplayScreenState();
}

class _LEDDisplayScreenState extends State<LEDDisplayScreen>
    with TickerProviderStateMixin {
  AnimationController? _textBlinkController;
  AnimationController? _backgroundBlinkController;
  AnimationController? _zoomController;
  AnimationController? _rotateController;
  AnimationController? _typewriterController;
  AnimationController? _waveController;
  AnimationController? _bounceController;
  AnimationController? _flickerController;

  Animation<double>? _textBlinkAnimation;
  Animation<double>? _backgroundBlinkAnimation;
  Animation<double>? _zoomAnimation;
  Animation<double>? _rotateAnimation;
  Animation<double>? _waveAnimation;
  Animation<double>? _bounceAnimation;
  Animation<double>? _flickerAnimation;

  AnimationType _currentAnimation = AnimationType.none;
  bool _showControls = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Existing animations
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

    // New animation controllers
    _zoomController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _zoomAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _zoomController!, curve: Curves.easeInOut),
    );

    _rotateController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );
    _rotateAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotateController!, curve: Curves.linear),
    );

    _typewriterController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );

    _waveController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(parent: _waveController!, curve: Curves.linear));

    _bounceController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bounceController!, curve: Curves.bounceOut),
    );

    _flickerController = AnimationController(
      duration: Duration(milliseconds: 100),
      vsync: this,
    );
    _flickerAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _flickerController!, curve: Curves.easeInOut),
    );

    // Start animations with current state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = context.read<LEDTextCubit>().state;
      _updateBlinkAnimations(state);
    });
  }

  @override
  void dispose() {
    _exitFullScreen();
    _textBlinkController?.dispose();
    _backgroundBlinkController?.dispose();
    _zoomController?.dispose();
    _rotateController?.dispose();
    _typewriterController?.dispose();
    _waveController?.dispose();
    _bounceController?.dispose();
    _flickerController?.dispose();
    super.dispose();
  }

  void _exitFullScreen() {
    AutoOrientation.portraitAutoMode();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void _updateBlinkAnimations(LEDTextState state) {
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

  void _startAnimation(AnimationType type) {
    // Stop all animations first
    _stopAllAnimations();

    setState(() {
      _currentAnimation = type;
    });

    switch (type) {
      case AnimationType.zoom:
        _zoomController?.repeat(reverse: true);
        break;
      case AnimationType.rotate:
        _rotateController?.repeat();
        break;

      case AnimationType.wave:
        _waveController?.repeat();
        break;
      case AnimationType.bounce:
        _bounceController?.forward().then((_) {
          Future.delayed(Duration(milliseconds: 500), () {
            _bounceController?.reset();
            _bounceController?.forward();
          });
        });
        break;
      case AnimationType.flicker:
        _startFlickerAnimation();
        break;
      case AnimationType.none:
        break;
    }
  }

  void _startFlickerAnimation() {
    _flickerController?.forward().then((_) {
      _flickerController?.reverse().then((_) {
        Future.delayed(
          Duration(milliseconds: math.Random().nextInt(200) + 50),
          () {
            if (_currentAnimation == AnimationType.flicker) {
              _startFlickerAnimation();
            }
          },
        );
      });
    });
  }

  void _stopAllAnimations() {
    _zoomController?.stop();
    _rotateController?.stop();
    _typewriterController?.stop();
    _waveController?.stop();
    _bounceController?.stop();
    _flickerController?.stop();
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

  Widget _buildAnimatedText(LEDTextState state, Color currentFontColor) {
    String displayText = state.currentText;

    Widget textWidget = Text(
      displayText,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: state.fontSize,
        color: currentFontColor,
        fontFamily: _getFontFamily(state.selectedFont),
        fontWeight: FontWeight.bold,
      ),
    );

    switch (_currentAnimation) {
      case AnimationType.zoom:
        if (_zoomAnimation != null) {
          return AnimatedBuilder(
            animation: _zoomAnimation!,
            builder: (context, child) {
              return Transform.scale(
                scale: _zoomAnimation!.value,
                child: textWidget,
              );
            },
          );
        }
        break;
      case AnimationType.rotate:
        if (_rotateAnimation != null) {
          return AnimatedBuilder(
            animation: _rotateAnimation!,
            builder: (context, child) {
              return Transform.rotate(
                angle: _rotateAnimation!.value,
                child: textWidget,
              );
            },
          );
        }
        break;
      case AnimationType.wave:
        if (_waveAnimation != null) {
          return AnimatedBuilder(
            animation: _waveAnimation!,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, math.sin(_waveAnimation!.value) * 20),
                child: textWidget,
              );
            },
          );
        }
        break;
      case AnimationType.bounce:
        if (_bounceAnimation != null) {
          return AnimatedBuilder(
            animation: _bounceAnimation!,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, -50 * _bounceAnimation!.value),
                child: Transform.scale(
                  scale: 0.8 + (0.2 * _bounceAnimation!.value),
                  child: textWidget,
                ),
              );
            },
          );
        }
        break;
      case AnimationType.flicker:
        if (_flickerAnimation != null) {
          return AnimatedBuilder(
            animation: _flickerAnimation!,
            builder: (context, child) {
              return Opacity(
                opacity: _flickerAnimation!.value,
                child: textWidget,
              );
            },
          );
        }
        break;
      default:
        break;
    }

    return textWidget;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocListener<LEDTextCubit, LEDTextState>(
        listener: (context, state) {
          _updateBlinkAnimations(state);

          if (state.keepScreenOn) {
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
          }
        },
        child: BlocBuilder<LEDTextCubit, LEDTextState>(
          builder: (context, state) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  _showControls = !_showControls;
                });
              },

              child: Stack(
                children: [
                  // Main Display
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _textBlinkAnimation ?? const AlwaysStoppedAnimation(0.0),
                      _backgroundBlinkAnimation ??
                          const AlwaysStoppedAnimation(0.0),
                    ]),
                    builder: (context, child) {
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
                        color: currentBackgroundColor,
                        child: Center(
                          child: state.scrollDirection == 2
                              ? _buildAnimatedText(state, currentFontColor)
                              : TextScrollingWidget(
                                  currentFontColor: currentFontColor,
                                  state: state,
                                  fontFamily: _getFontFamily(
                                    state.selectedFont,
                                  ),
                                ),
                        ),
                      );
                    },
                  ),

                  // Animation Controls
                  if (_showControls)
                    Positioned(
                      top: 50,
                      left: 20,
                      right: 20,
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Animation Effects',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _showControls = !_showControls;
                                    });
                                  },
                                  icon: Icon(Icons.close),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _buildAnimationButton(
                                  'None',
                                  AnimationType.none,
                                ),
                                _buildAnimationButton(
                                  'Zoom',
                                  AnimationType.zoom,
                                ),
                                _buildAnimationButton(
                                  'Rotate',
                                  AnimationType.rotate,
                                ),

                                _buildAnimationButton(
                                  'Wave',
                                  AnimationType.wave,
                                ),
                                _buildAnimationButton(
                                  'Bounce',
                                  AnimationType.bounce,
                                ),
                                _buildAnimationButton(
                                  'Flicker',
                                  AnimationType.flicker,
                                ),
                                if (!widget.isFirst)
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red[700],
                                      foregroundColor: Colors.white,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: Text(
                                      "Keluar",
                                      style: TextStyle(fontSize: 12),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Tap: Toggle Controls ',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnimationButton(String label, AnimationType type) {
    bool isSelected = _currentAnimation == type;
    return ElevatedButton(
      onPressed: () => _startAnimation(type),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey[700],
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(label, style: TextStyle(fontSize: 12)),
    );
  }
}
