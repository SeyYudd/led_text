enum AnimationType { none, zoom, rotate, wave, flicker }

String getAnimationLabel(AnimationType type) {
  switch (type) {
    case AnimationType.none:
      return 'NONE';
    case AnimationType.zoom:
      return 'ZOOM';
    case AnimationType.rotate:
      return 'ROTATE';
    case AnimationType.wave:
      return 'WAVE';
    case AnimationType.flicker:
      return 'FLICKER';
  }
}
