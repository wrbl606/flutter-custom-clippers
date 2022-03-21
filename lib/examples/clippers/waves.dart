import 'dart:math';

import 'package:flutter/material.dart';

/// Another convenience widget that allows
/// for layer stacking.
class WavesPage extends StatelessWidget {
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
  Widget build(BuildContext context) => Stack(
        /// Draw layers from the back to the front,
        /// applying a bit of height and opacity accordingly
        /// to layer number.
        children: List.generate(layers, (index) => index)
            .map<Widget>(
              (index) => Positioned(
                bottom: index * (effectHeight / layers),
                left: 0,
                right: 0,
                child: Waves(
                  peaks: peaks,
                  curve: curve,
                  maxExtent: maxPeakExtent,
                  color: mainColor.withOpacity(1 - index / layers),
                  delay: layerDelay * index,
                  duration: duration,
                ),
              ),
            )
            .toList(),
      );
}

/// Animated waves snipping widget.
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

    /// Make the animation start in the middle.
    value: .5,
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
    ///
    /// It's like following a plot of a function:
    ///
    ///  y (current value)
    ///  ^
    /// 1|                 o
    ///  |       o
    ///  |   o
    ///  | o
    /// 0|---------------------> x (time)
    ///    ^ ^   ^        ^
    ///  .25 .5  .75      1
    animation = CurvedAnimation(
      parent: tween.animate(controller),
      curve: widget.curve,
    )

      /// On each animation state change
      /// update the widget to reflect
      /// current state.
      ..addListener(_triggerRerender)

      /// Loop the animation.
      ..addStatusListener((status) {
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

  /// Cleanup listeners and controllers
  /// to avoid updating widget's state
  /// when it's not visible (mounted) anymore.
  @override
  void dispose() {
    animation.removeListener(_triggerRerender);
    controller.dispose();
    super.dispose();
  }

  void _triggerRerender() => setState(() {});

  @override
  Widget build(BuildContext context) {
    /// Clipper just defines the path to clip.
    ///
    /// This is why our shouldReclip method
    /// doesn't make much sense: we're
    /// creating a new instance of a clipper
    /// each time the widget is built.
    /// It's ok though, if the clipper instance
    /// would be used another way and will be
    /// longer lived, it could get rid of some
    /// unnecessary renders.
    final clipper = WavesClipper(
      progress: animation.value,
      peaks: widget.peaks,
      maxExtent: widget.maxExtent,
    );

    /// The ClipPath measures the child
    /// and forwards the size to
    /// the clipper to get a clip.
    /// Only then, it does the clipping according
    /// to the received path.
    return ClipPath(
      /// Clipper instance will be fed with size
      /// of the clipped child to provide
      /// a path for this specific size.
      clipper: clipper,

      /// Use the given widget for snipping
      /// or fallback to a coloured container.
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

  /// Determine what should be drawn
  /// given a rectangle of a given [size].
  ///
  /// The path must be closed!
  /// If we don't close it, it'll be closed automatically
  /// and it probably wouldn't result with
  /// the desired effect.
  @override
  Path getClip(Size size) {
    /// Creating a path is like passing a pencil
    /// between painters. Wherever the last movement
    /// ended, it's the beginning for the next painter.
    final path = Path();

    /// Move the path to the start position.
    path.moveTo(0, size.height * .3);

    /// For each peak, call a wave method.
    /// The width will be split evenly
    /// for each wave.
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

    /// Make sure the path is closed with
    /// the bottom part included.
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

    /// Quadratic bezier curve makes use of three points:
    /// start, control, and end.
    /// start and end are obvious,
    /// control one indicates a point through which the
    /// line should go.
    /// Given the three points quadratic bezier curve
    /// will produce a smooth path that meets all of
    /// given points.
    ///
    /// We're providing only control and end points here
    /// since the start one in the point in which the path
    /// is currently at.
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

  /// Notify the instance user whether is should clip
  /// the child again or not. Every size change
  /// will trigger the getClip method anyway
  /// so here we're dealing just with our custom fields.
  @override
  bool shouldReclip(WavesClipper oldClipper) =>
      oldClipper.progress != progress ||
      oldClipper.peaks != peaks ||
      oldClipper.maxExtent != maxExtent;
}
