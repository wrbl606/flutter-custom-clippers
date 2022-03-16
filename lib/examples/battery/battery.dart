import 'package:custom_clipper/examples/clippers/waves.dart';
import 'package:flutter/material.dart';

class Battery extends StatelessWidget {
  final Color color;
  final double level;
  final double height = 200;
  final double width = 120;
  final double thickness = 10;

  const Battery({
    Key? key,
    this.color = Colors.greenAccent,
    this.level = .8,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: [
            Positioned(
              bottom: thickness,
              left: 0,
              right: 0,
              child: SizedBox(
                height: height * level,
                child: Stack(
                  children: [
                    Waves(
                      peaks: 1,
                      color: color.withOpacity(.4),
                      curve: Curves.easeInOut,
                    ),
                    Waves(
                      peaks: 1,
                      color: color.withOpacity(.6),
                      delay: const Duration(seconds: 2),
                      curve: Curves.fastOutSlowIn,
                    ),
                    Waves(
                      peaks: 1,
                      color: color,
                      delay: const Duration(seconds: 1),
                      curve: Curves.easeInOutSine,
                    ),
                  ],
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 30,
                  height: thickness,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade800,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Container(
                  width: width,
                  height: height - thickness,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.grey.shade800,
                      width: thickness,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                )
              ],
            ),
            Center(
              child: Text(
                '${(level * 100).floor()}%',
                style: Theme.of(context).textTheme.headline3,
              ),
            )
          ],
        ),
      );
}
