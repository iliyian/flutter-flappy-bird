import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'startpage.dart';
import 'gamepage.dart';

late SharedPreferences prefs;
late int? score, best;
bool newBest = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  prefs = await SharedPreferences.getInstance();

  // print("alive");

  //
  // prefs.clear();

  score = prefs.getInt("score");
  score ??= 0;
  best = prefs.getInt("best");
  best ??= 0;

  runApp(FlappyBird());
}

void incScore() {
  score = score! + 1;
  if (best! < score!) {
    best = score;
    newBest = true;
  }
  prefs.setInt("best", best!);
  prefs.setInt("score", score!);
}

// ignore: must_be_immutable
class FlappyBird extends StatelessWidget {
  FlappyBird({super.key});

  static const double width = 360, height = 720, groudnHeight = 120;
  static late AnimationController groundController;
  static late Animation<double> groundAnimation;
  late SharedPreferences prefs;

  static const List<String> birdsPath = [
    "assets/img/yellow-up-bird.png",
    "assets/img/yellow-even-bird.png",
    "assets/img/yellow-down-bird.png",
  ];

  // static GlobalKey backgroundKey = GlobalKey();
  // static GlobalKey groundKey() => GlobalKey();
  static List<BuildContext> groundContexts = [];

  static bool gameovering = false;

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

  static Widget backgroundCity() {
    return Hero(
      tag: "background-city",
      child: Image.asset(
        "assets/img/background-city-day.png",
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

  static void initGround(TickerProvider tickerProvider) {
    groundController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: tickerProvider,
    );
    groundAnimation = Tween<double>(begin: 0, end: -FlappyBird.width)
        .animate(groundController);
    groundController.repeat();
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
          "/": (context) => Center(
              child: SizedBox(height: 720, width: 360, child: StartPage())),
          "/game": (context) => Center(
              child: SizedBox(height: 720, width: 360, child: GamePage())),
        },
        theme: ThemeData(useMaterial3: true));
  }
}
