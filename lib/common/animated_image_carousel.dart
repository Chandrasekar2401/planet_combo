import 'dart:async';
import 'package:flutter/material.dart';

/// A background carousel that cycles through a list of asset images using a
/// Ken-Burns zoom on each image and a smooth crossfade between them.
///
/// Each image holds for [imageHoldDuration] before the next image starts
/// fading in over [crossfadeDuration]. The Ken-Burns transform runs for the
/// full visible span (hold + crossfade) so the motion never freezes during
/// the transition.
class AnimatedImageCarousel extends StatefulWidget {
  final List<String> imagePaths;
  final Duration imageHoldDuration;
  final Duration crossfadeDuration;
  final double zoomFactor;
  final BoxFit fit;

  const AnimatedImageCarousel({
    super.key,
    required this.imagePaths,
    this.imageHoldDuration = const Duration(seconds: 7),
    this.crossfadeDuration = const Duration(milliseconds: 1400),
    this.zoomFactor = 1.18,
    this.fit = BoxFit.cover,
  });

  @override
  State<AnimatedImageCarousel> createState() => _AnimatedImageCarouselState();
}

class _AnimatedImageCarouselState extends State<AnimatedImageCarousel> {
  Timer? _advanceTimer;
  int _index = 0;
  bool _didPrecacheInitial = false;

  @override
  void initState() {
    super.initState();
    _scheduleNext();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didPrecacheInitial) {
      _didPrecacheInitial = true;
      _precacheNeighbor();
    }
  }

  void _scheduleNext() {
    _advanceTimer?.cancel();
    if (widget.imagePaths.length < 2) return;
    _advanceTimer = Timer(widget.imageHoldDuration, _advance);
  }

  void _advance() {
    if (!mounted) return;
    setState(() {
      _index = (_index + 1) % widget.imagePaths.length;
    });
    _precacheNeighbor();
    _scheduleNext();
  }

  void _precacheNeighbor() {
    if (!mounted || widget.imagePaths.length < 2) return;
    final next = (_index + 1) % widget.imagePaths.length;
    precacheImage(AssetImage(widget.imagePaths[next]), context);
  }

  @override
  void dispose() {
    _advanceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: widget.crossfadeDuration,
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: _KenBurnsImage(
        key: ValueKey<int>(_index),
        path: widget.imagePaths[_index],
        duration: widget.imageHoldDuration + widget.crossfadeDuration,
        zoomFactor: widget.zoomFactor,
        fit: widget.fit,
      ),
    );
  }
}

class _KenBurnsImage extends StatefulWidget {
  final String path;
  final Duration duration;
  final double zoomFactor;
  final BoxFit fit;

  const _KenBurnsImage({
    super.key,
    required this.path,
    required this.duration,
    required this.zoomFactor,
    required this.fit,
  });

  @override
  State<_KenBurnsImage> createState() => _KenBurnsImageState();
}

class _KenBurnsImageState extends State<_KenBurnsImage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _scale = Tween<double>(begin: 1.0, end: widget.zoomFactor).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scale,
      builder: (_, child) => Transform.scale(scale: _scale.value, child: child),
      child: Image.asset(
        widget.path,
        fit: widget.fit,
        width: double.infinity,
        height: double.infinity,
        gaplessPlayback: true,
      ),
    );
  }
}
