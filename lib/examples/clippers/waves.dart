import 'dart:math';

import 'package:custom_clipper/utils/path_shadow_clipper.dart';
import 'package:flutter/material.dart';

/// Another convenience widget that allows
/// for layer stacking.
class WavesPage extends StatefulWidget {
  final int layers;
  final int peaks;
  final Color mainColor;
  final Duration layerDelay;
  final Duration duration;
  final double effectHeight;
  final Curve curve;
  final double maxPeakExtent;

  const WavesPage({
    Key? key,
    this.layers = 4,
    this.peaks = 3,
    this.mainColor = Colors.blue,
    this.layerDelay = const Duration(milliseconds: 200),
    this.duration = const Duration(seconds: 2),
    this.effectHeight = 40,
    this.curve = Curves.easeInOutQuart,
    this.maxPeakExtent = .5,
  }) : super(key: key);

  @override
  State<WavesPage> createState() => _WavesPageState();
}

class _WavesPageState extends State<WavesPage>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) => Stack(
        children: List.generate(widget.layers, (index) => index)
            .map<Widget>(
              (index) => Positioned(
                bottom: index * (widget.effectHeight / widget.layers),
                left: 0,
                right: 0,
                child: Waves(
                  peaks: widget.peaks,
                  curve: widget.curve,
                  maxExtent: widget.maxPeakExtent,
                  color:
                      widget.mainColor.withOpacity(1 - index / widget.layers),
                  delay: widget.layerDelay * index,
                  duration: widget.duration,
                ),
              ),
            )
            .toList(),
      );
}

/// Animated waves snipping widget
/// just for convenience.
class Waves extends StatefulWidget {
  final Color color;
  final Curve curve;
  final Duration duration;
  final Duration delay;
  final int peaks;
  final double maxExtent;
  final Widget? child;

  const Waves({
    Key? key,
    this.color = Colors.blue,
    this.curve = Curves.easeInOutQuart,
    this.duration = const Duration(seconds: 2),
    this.delay = Duration.zero,
    this.peaks = 3,
    this.maxExtent = .5,
    this.child,
  }) : super(key: key);

  @override
  _WavesState createState() => _WavesState();
}

class _WavesState extends State<Waves> with SingleTickerProviderStateMixin {
  late final controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final tween = Tween<double>(begin: 0, end: 1);
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();

    /// Animation is just a utility
    /// that'll produce a number from
    /// 0.0 to 1.0.
    /// Current animation state is determined
    /// by given duration and a curve.
    animation = CurvedAnimation(
      parent: tween.animate(controller),
      curve: widget.curve,
    )
      ..addListener(_updateState)
      ..addStatusListener((status) {
        /// Loop the animation.
        switch (status) {
          case AnimationStatus.completed:
            controller.reverse();
            break;
          case AnimationStatus.dismissed:
            controller.forward();
            break;
          default:
            break;
        }
      });

    Future.delayed(widget.delay).then((_) {
      if (mounted) {
        controller.forward();
      }
    });
  }

  @override
  void dispose() {
    animation.removeListener(_updateState);
    controller.dispose();
    super.dispose();
  }

  /// Trigger a rerender.
  void _updateState() => setState(() {});

  @override
  Widget build(BuildContext context) {
    /// Clipper just defines the path to clip.
    final clipper = WavesClipper(
      progress: animation.value,
      peaks: widget.peaks,
      maxExtent: widget.maxExtent,
    );

    /// The ClipPath measures the child
    /// and forwards the size to
    /// the clipper to get a clip.
    /// Only then, it does the clipping.
    return ClipPath(
      clipper: clipper,
      child: widget.child ??
          Container(
            height: 200,
            color: widget.color,
          ),
    );
  }
}

/// Clipper's job is to generate a clip
/// contained within the Path instance
/// for given size.
class WavesClipper extends CustomClipper<Path> {
  final double progress;
  final int peaks;
  final double maxExtent;

  const WavesClipper({
    this.progress = .5,
    this.peaks = 3,
    this.maxExtent = .5,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(0, size.height * .3);
    List.generate(peaks, (index) => index).forEach(
      (index) {
        wave(
          path,
          progress,
          Size(size.width / peaks, size.height),
          Offset((size.width / peaks) * index, size.height * .3),
        );
      },
    );

    finish(path, size);
    return path;
  }

  void wave(Path path, double progress, Size size, Offset offset) {
    final xMovement = Offset(
        size.width * maxExtent * progress - size.width * maxExtent / 2, 0);
    final progressValue = size.width * progress;
    final startPoint = Point<double>(offset.dx, offset.dy);
    final controlPoint =
        Point<double>(startPoint.x + progressValue + xMovement.dx, 0);
    final endPoint = Point<double>(startPoint.x + size.width, size.height * .3);
    path.lineTo(startPoint.x, startPoint.y);
    path.quadraticBezierTo(
      controlPoint.x,
      controlPoint.y,
      endPoint.x,
      endPoint.y,
    );
  }

  void finish(Path path, Size size) {
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
  }

  @override
  bool shouldReclip(WavesClipper oldClipper) =>
      oldClipper.progress != progress ||
      oldClipper.peaks != peaks ||
      oldClipper.maxExtent != maxExtent;
}
