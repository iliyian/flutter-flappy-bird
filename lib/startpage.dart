import 'package:flappy_bird/main.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class StartPage extends StatefulWidget {
  StartPage({super.key});

  @override
  State<StatefulWidget> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> with TickerProviderStateMixin {
  late AnimationController logoBirdFloatController,
      logoBirdWingController,
      buttonTapController;
  late Animation<double> logoBirdFloatAnimation, buttonTapAnimation;
  late Animation<int> logoBirdWingAnimation;
  late Size screenSize;

  bool isRateButtonTapped = false,
      isPlayButtonTapped = false,
      isRankButtonTapped = false;

  final Uri rateUrl = Uri.parse("https://github.com/iliyian/flutter-flappy-bird");

  late List<GlobalKey> groundKeys;

  @override
  void initState() {
    super.initState();

    groundKeys = List.generate(2, (i) => GlobalKey());

    FlappyBird.initGround(this);
    initLogoBird();

    buttonTapController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    buttonTapAnimation =
        Tween<double>(begin: 0, end: 5).animate(buttonTapController);
  }

  void initLogoBird() {
    logoBirdFloatController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    logoBirdFloatAnimation =
        Tween<double>(begin: 0, end: 7).animate(logoBirdFloatController);
    logoBirdFloatController.repeat(reverse: true);

    logoBirdWingController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    logoBirdWingAnimation =
        IntTween(begin: 0, end: FlappyBird.birdWings.length - 1)
            .animate(logoBirdWingController);
    logoBirdWingController.repeat(reverse: true);
  }

  @override
  void dispose() {
    logoBirdFloatController.dispose();
    logoBirdWingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // screenSize = MediaQuery.of(context).size;
    // width = screenSize.width;
    // height = screenSize.height;

    // if (width >= height) {
    //   width = 360;
    //   height = 720;
    // }

    return AnimatedBuilder(
      animation: Listenable.merge([
        FlappyBird.groundAnimation,
        logoBirdFloatAnimation,
        logoBirdWingAnimation
      ]),
      builder: (context, child) => Stack(
        fit: StackFit.expand,
        alignment: Alignment.center,
        children: startPageComponents(),
      ),
    );
  }

  List<Widget> startPageComponents() {
    List<Widget> components = [
      FlappyBird.backgroundCity(),
      startPageLogo(),
      startPageBird(),
      playButton(
        context,
      ),
      rankButton(),
      rateButton(),
    ];
    components.addAll(FlappyBird.ground());
    return components;
  }

  void buttonTremble(void Function() lastly) {
    buttonTapController
        .forward()
        .then((value) => buttonTapController.reverse().then((value) {
              lastly();
            }));
  }

  Positioned playButton(BuildContext context, {double bottom = 200}) {
    return Positioned(
      bottom: 200 - (isPlayButtonTapped ? buttonTapAnimation.value : 0),
      left: 20,
      child: GestureDetector(
        onTap: () {
          print("Tap play button ");
          FlappyBird.gameovering = false;

          isPlayButtonTapped = true;
          buttonTremble(() {
            isPlayButtonTapped = false;
            score = 0;
            newBest = false;
            Navigator.pushNamed(context, "/game");
          });
        },
        child: Image.asset(
          "assets/img/play-button.png",
          scale: 0.8,
        ),
      ),
    );
  }

  Positioned rankButton({double bottom = 200}) {
    return Positioned(
      bottom: bottom - (isRankButtonTapped ? buttonTapAnimation.value : 0),
      right: 20,
      child: GestureDetector(
        onTap: () {
          print("Tap rank button ");

          isRankButtonTapped = true;
          buttonTremble(() {
            isRankButtonTapped = false;
          });
        },
        child: Image.asset(
          "assets/img/rank-button.png",
          scale: 0.8,
        ),
      ),
    );
  }

  Positioned rateButton() {
    return Positioned(
      bottom: 300 - (isRateButtonTapped ? 5 : 0),
      child: GestureDetector(
        onTap: () {
          print("Tap rate button ");

          isRateButtonTapped = true;
          buttonTremble(() {
            isRateButtonTapped = false;
            launchUrl(rateUrl);
          });
        },
        child: Image.asset(
          "assets/img/rate-button.png",
          scale: 0.8,
        ),
      ),
    );
  }

  Positioned startPageBird() {
    return Positioned(
      top: 260 + logoBirdFloatAnimation.value,
      child: Image.asset(
        FlappyBird.getBirdPath(logoBirdWingAnimation.value),
        scale: 0.8,
      ),
    );
  }

  Positioned startPageLogo() {
    return Positioned(
      top: 150,
      child: Image.asset(
        "assets/img/logo.png",
        scale: 0.8,
      ),
    );
  }
}
