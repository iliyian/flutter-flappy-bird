import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'startpage.dart';
import 'gamepage.dart';
import 'music.dart';

late SharedPreferences prefs;
late Random random;
late int? scoreq, bestq;
late int score, best;
late String backgroundScene, birdColor;
bool newBest = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  prefs = await SharedPreferences.getInstance();

  // print("alive");

  //
  // prefs.clear();

  random = Random();

  backgroundScene = FlappyBird
      .backgroundScenes[random.nextInt(FlappyBird.backgroundScenes.length)];
  birdColor =
      FlappyBird.birdColors[random.nextInt(FlappyBird.birdColors.length)];

  runApp(FlappyBird());
}

// ignore: must_be_immutable
class FlappyBird extends StatelessWidget {
  FlappyBird({super.key}) {
    scoreq = prefs.getInt("score");
    scoreq ??= 0;
    score = scoreq!;

    bestq = prefs.getInt("best");
    bestq ??= 0;
    best = bestq!;

    music = Music();
  }

  static const double width = 360, height = 720, groudnHeight = 120;
  static late AnimationController groundController;
  static late Animation<double> groundAnimation;

  static final List<String> birdColors = ["yellow", "red", "blue"];
  static final List<String> birdWings = ["up", "even", "down"];
  static final List<String> backgroundScenes = ["day", "night"];

  static late Music music;

  // static GlobalKey backgroundKey = GlobalKey();
  // static GlobalKey groundKey() => GlobalKey();
  static List<BuildContext> groundContexts = [];

  static bool gameovering = false, newBest = false;

  static Rect contextToRect(BuildContext context) {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    Offset offset = renderBox.localToGlobal(Offset.zero);

    double left = offset.dx;
    double top = offset.dy;
    double width = renderBox.size.width;
    double height = renderBox.size.height;

    Rect rect =
        Rect.fromPoints(Offset(left, top), Offset(left + width, top + height));

    return rect;
  }

  static String getBirdPath(int wing) {
    return "assets/img/$birdColor-${birdWings[wing]}-bird.png";
  }

  static String getBackgroundPath() {
    return "assets/img/background-city-$backgroundScene.png";
  }

  static Widget backgroundCity() {
    return Hero(
      tag: "background-city",
      child: Image.asset(
        getBackgroundPath(),
        fit: BoxFit.fill,
        key: Key("background-key"),
      ),
    );
  }

  static List<Positioned> ground() {
    List<Positioned> grounds = List.generate(
        2,
        (i) => Positioned(
              left: groundAnimation.value + i * FlappyBird.width,
              bottom: 0,
              child: Hero(
                // key: groundKey(),
                tag: "ground$i",
                child: Builder(builder: (context) {
                  if (groundContexts.length >= 2) {
                    groundContexts[i] = context;
                  } else {
                    groundContexts.add(context);
                  }
                  return SizedBox(
                    width: FlappyBird.width,
                    child: Image.asset(
                      "assets/img/ground.png",
                      fit: BoxFit.fitWidth,
                    ),
                  );
                }),
              ),
            ));
    return grounds;
  }

  static void incScore() {
    score = score + 1;
    if (best < score) {
      best = score;
      newBest = true;
    }
    prefs.setInt("best", best);
    prefs.setInt("score", score);
  }

  static void initGround(TickerProvider tickerProvider) {
    groundController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: tickerProvider,
    );
    groundAnimation = Tween<double>(begin: 0, end: -FlappyBird.width)
        .animate(groundController);
    groundController.repeat();
  }

  AspectRatio mainWrap(Widget? main) {
    return AspectRatio(
      aspectRatio: 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
            color: backgroundScene == "day" ? Colors.white : Colors.black),
        child: Center(
            child: Container(
          height: 720,
          width: 360,
          decoration: BoxDecoration(
            border: Border.all(
              width: 3,
              color: Colors.teal,
              strokeAlign: BorderSide.strokeAlignOutside,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          clipBehavior: Clip.hardEdge,
          child: ClipRRect(child: main),
        )),
      ),
    );
  }

  void dispose() {
    groundController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: "Flappy Bird",
        initialRoute: "/",
        routes: {
          "/": (context) => mainWrap(StartPage()),
          "/game": (context) => mainWrap(GamePage())
        },
        theme: ThemeData(
          useMaterial3: true,
        ));
  }
}
