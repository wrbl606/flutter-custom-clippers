import 'package:custom_clipper/examples/clippers/stripes.dart';
import 'package:custom_clipper/examples/clippers/waves.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:throttling/throttling.dart';

import 'examples/battery/battery.dart';
import 'examples/video.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _controller = PageController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleKeyEvent(KeyEvent value) {
    if (value is! KeyUpEvent) {
      return;
    }

    if (value.physicalKey == PhysicalKeyboardKey.arrowRight) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCirc);
    } else if (value.physicalKey == PhysicalKeyboardKey.arrowLeft) {
      _controller.previousPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCirc);
    }
  }

  @override
  Widget build(BuildContext context) => KeyboardListener(
        focusNode: _focusNode,
        onKeyEvent: _handleKeyEvent,
        child: MaterialApp(
          title: 'Custom clipper',
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: Scaffold(
            body: PageView(
              controller: _controller,
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 200,
                    color: Colors.blue,
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: ClipPath(
                    clipper: const WavesClipper(progress: .5),
                    child: Container(
                      height: 200,
                      color: Colors.blue,
                    ),
                  ),
                ),
                const WavesPage(layers: 1),
                const WavesPage(),
                Stack(
                  children: [
                    Container(color: Colors.blue.shade100.withOpacity(.4)),
                    Positioned(
                      right: -120,
                      top: -80,
                      child: Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          color: Colors.yellowAccent,
                          borderRadius: BorderRadius.circular(150),
                        ),
                      ),
                    ),
                    const WavesPage(
                      layers: 10,
                      effectHeight: 100,
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Your boat is booked",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 40),
                          Text(
                            "4201",
                            style: Theme.of(context).textTheme.bodyText1,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Access code',
                            style: Theme.of(context).textTheme.labelSmall,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                const WavesPage(
                  layers: 3,
                  mainColor: Colors.green,
                  peaks: 50,
                  effectHeight: 20,
                  maxPeakExtent: 2,
                  layerDelay: Duration(milliseconds: 600),
                  curve: Curves.easeInOutSine,
                ),
                Stack(
                  children: [
                    const WavesPage(
                      layers: 3,
                      mainColor: Colors.green,
                      peaks: 50,
                      effectHeight: 20,
                      maxPeakExtent: 2,
                      layerDelay: Duration(milliseconds: 600),
                      curve: Curves.easeInOutSine,
                    ),
                    Positioned(
                      bottom: 150,
                      left: 0,
                      right: 24,
                      child: Text(
                        "We'll mown\nyour lawn",
                        style: Theme.of(context).textTheme.displaySmall,
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: const [
                      Battery(),
                      Battery(level: .4, color: Colors.orange),
                      Battery(level: .2, color: Colors.red),
                    ],
                  ),
                ),
                Stripes(
                  child: Container(color: Colors.pink),
                  duration: Duration.zero,
                ),
                Scaffold(
                  backgroundColor: Colors.black,
                  body: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stripes(
                          child: Image.asset('assets/images/car.jpeg'),
                          curve: Curves.easeInOutQuart,
                          delay: const Duration(seconds: 1),
                          duration: const Duration(seconds: 3),
                        ),
                        Theme(
                          data: ThemeData(
                            outlinedButtonTheme: OutlinedButtonThemeData(
                              style: ButtonStyle(
                                foregroundColor:
                                    MaterialStateProperty.all(Colors.red),
                              ),
                            ),
                          ),
                          child: Builder(
                            builder: (context) => OutlinedButton.icon(
                              onPressed: () =>
                                  ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Nice!')),
                              ),
                              icon: const Icon(Icons.shopping_bag_outlined),
                              label: const Text('Buy now'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Center(
                    child: Stripes(
                  child: Video(),
                  stripes: 2,
                )),
                Scaffold(
                  body: Stripes(
                    child: ListView.builder(
                        itemBuilder: (context, index) => index % 2 == 0
                            ? Container(height: 100, color: Colors.red)
                            : Container(height: 100, color: Colors.blue)),
                  ),
                ),
                Builder(
                  builder: (context) => Stack(
                    fit: StackFit.expand,
                    children: [
                      Stripes(
                        duration: Duration.zero,
                        child: ListView.builder(
                            itemBuilder: (context, index) => index % 2 == 0
                                ? Container(
                                    height:
                                        MediaQuery.of(context).size.height / 6,
                                    color: Colors.red)
                                : Container(
                                    height:
                                        MediaQuery.of(context).size.height / 6,
                                    color: Colors.blue)),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).size.height / 6,
                        bottom: -MediaQuery.of(context).size.height / 6,
                        left: 0,
                        right: 0,
                        child: Stripes(
                          duration: Duration.zero,
                          child: ListView.builder(
                              itemBuilder: (context, index) => index % 2 == 0
                                  ? Container(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              6,
                                      color: Colors.orangeAccent)
                                  : Container(
                                      height:
                                          MediaQuery.of(context).size.height /
                                              6,
                                      color: Colors.greenAccent)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
