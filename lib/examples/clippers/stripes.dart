import 'dart:math';

import 'package:flutter/material.dart';

/// Calculates the path for given size and tells
/// the instance user whether or not a reclip should be done.
class StripesClipper extends CustomClipper<Path> {
  final double progress;
  final int stripes;
  final double skewFactor;

  const StripesClipper({
    this.progress = .5,
    this.stripes = 3,
    this.skewFactor = 2,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    List.generate(stripes, (index) => index).forEach(
      (index) {
        stripe(
          path,
          Size(size.width, size.height / stripes),
          Offset(0, (size.height / stripes) * index * progress),
        );
      },
    );
    return path;
  }

  void stripe(Path path, Size size, Offset offset) {
    final thickness = size.height / skewFactor;
    final startPoint = Point(offset.dx, offset.dy);
    final secondPoint = Point(size.width, startPoint.y + thickness);
    final thirdPoint = Point(size.width, secondPoint.y + thickness);
    final endPoint = Point(startPoint.x, startPoint.y + thickness);

    path.moveTo(startPoint.x, startPoint.y);
    [secondPoint, thirdPoint, endPoint, startPoint]
        .forEach((point) => path.lineTo(point.x, point.y));
  }

  @override
  bool shouldReclip(StripesClipper oldClipper) =>
      oldClipper.progress != progress ||
      oldClipper.stripes != stripes ||
      oldClipper.skewFactor != skewFactor;
}

/// Helper widget that drives the animation
/// for the stripes.
class Stripes extends StatefulWidget {
  final Color color;
  final Curve curve;
  final Duration duration;
  final Duration delay;
  final int stripes;
  final Widget? child;

  const Stripes({
    Key? key,
    this.color = Colors.amberAccent,
    this.curve = Curves.easeInOutQuart,
    this.duration = const Duration(seconds: 2),
    this.delay = Duration.zero,
    this.stripes = 3,
    this.child,
  }) : super(key: key);

  @override
  _StripesState createState() => _StripesState();
}

class _StripesState extends State<Stripes> with SingleTickerProviderStateMixin {
  late final controller = AnimationController(
    vsync: this,
    duration: widget.duration,
  );
  late final tween = Tween<double>(begin: 0, end: 1);
  late Animation<double> animation;

  @override
  void initState() {
    super.initState();

    animation = CurvedAnimation(
      parent: tween.animate(controller),
      curve: widget.curve,
    )..addListener(_updateState);

    Future.delayed(widget.delay).then((_) {
      controller.forward();
    });
  }

  void _updateState() => setState(() {});

  @override
  void dispose() {
    animation.removeListener(_updateState);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ClipPath(
        clipper: StripesClipper(
          progress: animation.value,
          stripes: widget.stripes,
        ),
        child: widget.child ??
            Container(
              height: 200,
              color: widget.color,
            ),
      );
}
