import 'dart:math';

import 'package:flutter/material.dart';

class StringsClipper extends CustomClipper<Path> {
  final double progress;
  final int stripes;
  final double thicknessFactor;
  final double xMaxExtent;
  final double variance;
  final double seed;

  const StringsClipper({
    this.progress = .5,
    this.stripes = 3,
    this.thicknessFactor = 2,
    this.xMaxExtent = .5,
    this.variance = .3,
    this.seed = 0,
  });

  @override
  Path getClip(Size size) {
    final path = Path();
    List.generate(stripes, (index) => index).forEach(
      (index) {
        string(
          path,
          Size(size.width, size.height / stripes),
          Offset(0, (size.height / stripes) * index),
          variance: (stripes - index / 2) * variance,
        );
      },
    );
    return path;
  }

  void string(
    Path path,
    Size size,
    Offset offset, {
    double variance = 1,
  }) {
    final thickness = size.height / thicknessFactor;
    final topSpacing = size.height / 2;
    final currentHeight = topSpacing * (progress * variance) * 2;
    final currentXExtent =
        size.width / (1 / xMaxExtent) * (progress - .5 * variance);

    final startTopPoint = Point(
      offset.dx,
      offset.dy + topSpacing - thickness / 2,
    );
    final controlTopPoint = Point(
      size.width / 2 + currentXExtent,
      startTopPoint.y + currentHeight - thickness / 2,
    );
    final endTopPoint = Point(
      size.width,
      offset.dy + topSpacing - thickness / 2,
    );

    path.moveTo(startTopPoint.x, startTopPoint.y);
    path.quadraticBezierTo(
      controlTopPoint.x,
      controlTopPoint.y,
      endTopPoint.x,
      endTopPoint.y,
    );

    final startBottomPoint = Point(
      offset.dx,
      offset.dy + topSpacing + thickness / 2,
    );
    final controlBottomPoint = Point(
      size.width / 2 + currentXExtent,
      startTopPoint.y + currentHeight + thickness / 2,
    );
    final endBottomPoint = Point(
      size.width,
      offset.dy + topSpacing + thickness / 2,
    );

    path.lineTo(endBottomPoint.x, endBottomPoint.y);
    path.quadraticBezierTo(
      controlBottomPoint.x,
      controlBottomPoint.y,
      startBottomPoint.x,
      startBottomPoint.y,
    );
    path.lineTo(startTopPoint.x, startTopPoint.y);
  }

  @override
  bool shouldReclip(StringsClipper oldClipper) =>
      oldClipper.progress != progress ||
      oldClipper.stripes != stripes ||
      oldClipper.thicknessFactor != thicknessFactor;
}

class Strings extends StatefulWidget {
  final Color color;
  final Curve curve;
  final Duration duration;
  final Duration delay;
  final int stripes;
  final Widget? child;

  const Strings({
    Key? key,
    this.color = Colors.deepPurple,
    this.curve = Curves.easeInOutSine,
    this.duration = const Duration(seconds: 5),
    this.delay = Duration.zero,
    this.stripes = 7,
    this.child,
  }) : super(key: key);

  @override
  _StringsState createState() => _StringsState();
}

class _StringsState extends State<Strings> with SingleTickerProviderStateMixin {
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
    )
      ..addListener(_updateState)
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
        clipper: StringsClipper(
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
