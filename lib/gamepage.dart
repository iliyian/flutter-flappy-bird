import 'dart:async';
import 'dart:math';
import 'package:flappy_bird/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';

class GamePage extends StatefulWidget {
  GamePage({super.key}) {
    print("GamePage");
  }

  @override
  State<StatefulWidget> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> with TickerProviderStateMixin {
  static late Animation<double> tubesAnimation,
      gameOverOpacityAnimation,
      scoreBoardTopAnimation,
      buttonTapAnimation,
      buttonsBottomAnimation,
      scoreOnBoardValueAnimation,
      bestOnBoardValueAnimation;
  static late AnimationController tubesController,
      gameOverController,
      buttonTapController;

  static const double tubeVdistance = 125, // 管道纵向间隔
      tubeCdistance = 195, // 管道横向间隔
      tubeWidth = 65, // 管道宽度
      tubeHeight = 400; // 管道最大高度，可能超出视图
  final double birdJumpVelocity = 280, // 鸟跳的速度
      birdJumpAngle = 23, // 鸟跳的角度
      birdX = 50, // 鸟相对于左侧屏幕边界的像素距离
      birdJumpDuration = 300; // 鸟跳一次的时间

  bool isOkTapped = false, isMenuTapped = false;

  static late List<double> tubesUpsideDY; // 上侧管道底部距离屏幕上缘像素距离

  static late List<Positioned> upsideTubes, downsideTubes;
  // 上下管子在一个函数生成

  static List<BuildContext> tubeContexts = [];
  // 用于碰撞检测

  late Bird bird;

  bool playing = false,
      readying = false,
      showNewBest = false,
      showMadel = false;
  static bool canScore = false;

  @override
  void initState() {
    super.initState();

    bird = Bird(this, birdX, gameOver);
    print("Init gamePage");

    getReady();
    initTube();

    FlappyBird.initGround(this);
    FlappyBird.gameovering = false;

    buttonTapController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    buttonTapAnimation =
        Tween<double>(begin: 0, end: 5).animate(buttonTapController);
  }

  @override
  void dispose() {
    tubesController.dispose();

    super.dispose();
  }

  void getReady() {
    readying = true;
    bird.heightController.repeat(
        reverse: true,
        period: Duration(milliseconds: 1000),
        min: (FlappyBird.height - FlappyBird.groudnHeight) / 2 - 30,
        max: (FlappyBird.height - FlappyBird.groudnHeight) / 2 + 30);
    bird.angleController.repeat(
        min: 0, max: 0, reverse: true, period: Duration(milliseconds: 1000));
    bird.setWing(
        0, FlappyBird.birdWings.length - 1, Duration(milliseconds: 500));
  }

  Image getNumImage(int x, bool isBig) {
    return Image.asset("assets/img/$x.png", scale: isBig ? 0.8 : 1.4);
  }

  List<Padding> numRowChilren(int num, bool isBig) {
    List<Padding> scores = [];
    if (num == -1) return scores;
    do {
      int cur = num % 10;
      scores.insert(
          0,
          Padding(
            padding: const EdgeInsets.all(1.0),
            child: getNumImage(cur, isBig),
          ));
      num ~/= 10;
    } while (num > 0);
    return scores;
  }

  Positioned getReadyPositioned() {
    return Positioned(
      top: 140,
      left: 0,
      right: 0,
      child: Image.asset("assets/img/get-ready.png", scale: 0.9),
    );
  }

  Positioned tutorialTapPositioned() {
    return Positioned(
      top: 160,
      left: 0,
      right: 0,
      child: Image.asset(
        "assets/img/tutorial.png",
        scale: 0.8,
      ),
    );
  }

  double tubeGenerate(bool visible) {
    if (!visible || !playing) return -10000;
    return 100 + random.nextDouble() * 300;
  }

  List<Positioned> tubePositionedGenerate(bool isUpside) {
    tubeContexts.clear();
    List<Positioned> tubes = List.generate(tubesUpsideDY.length, (index) {
      return Positioned(
          left: (index + 1) * tubeCdistance + tubesAnimation.value - tubeWidth,
          // who fxxking knows why
          bottom: isUpside ? FlappyBird.height - tubesUpsideDY[index] : null,
          top: isUpside ? null : tubeVdistance + tubesUpsideDY[index],
          child: SizedBox(
            key: Key("Tube$index"),
            height: tubeHeight,
            width: tubeWidth,
            child: Builder(builder: (context) {
              tubeContexts.add(context);
              return Image.asset(
                "assets/img/tube-${isUpside ? "upside" : "downside"}-day.png",
                fit: BoxFit.fill,
              );
            }),
          ));
    });
    return tubes;
  }

  void initTube() {
    // [180, 540]
    tubesUpsideDY = List.generate(3, (index) => tubeGenerate(true));

    tubesController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
    tubesAnimation =
        Tween<double>(begin: 0, end: -tubeCdistance).animate(tubesController);

    tubesController.addListener(() {
      // print("${status}");
      if (tubesController.isCompleted) {
        print("TubeController is completed");
        canScore = true;

        tubesUpsideDY.removeAt(0);
        tubesUpsideDY.add(tubeGenerate(true));
        print("{$tubesUpsideDY}");

        tubesController.reset();
        tubesController.forward();
      }
    });
    tubesController.forward();
  }

  List<Widget> gamePageComponents() {
    List<Widget> components = [FlappyBird.backgroundCity()];

    if (playing) {
      upsideTubes = tubePositionedGenerate(true);
      downsideTubes = tubePositionedGenerate(false);

      components.addAll(upsideTubes);
      components.addAll(downsideTubes);
    }
    if (readying) {
      components.add(getReadyPositioned());
      components.add(tutorialTapPositioned());
    }
    if (FlappyBird.gameovering) {
      components.add(gameOverPositioned());
      components.add(scoreBoardPositioned());

      components.add(okPositioned());
      components.add(menuPositioned());

      components.add(scoreOnBoardPositioned());
      components.add(bestOnBoardPositioned());

      components.add(medalPositioned());
    }

    if (!FlappyBird.gameovering) {
      components.add(Positioned(
        top: 100,
        left: 0,
        right: 0,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: numRowChilren(score, true)),
      ));
    }

    if (showNewBest) {
      components.add(Positioned(
          right: 40,
          top: 370,
          child: Image.asset(
            "assets/img/new-best.png",
            scale: 1.5,
          )));
    }

    components.add(bird.positionedGenerate());

    components.addAll(FlappyBird.ground());
    return components;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (readying) {
          readying = false;
          playing = true;
        }
        bird.jump();
      },
      child: AnimatedBuilder(
          animation: Listenable.merge([
            tubesAnimation,
            FlappyBird.groundAnimation,
            bird.wingAnimation,
            bird.angleAnimation,
            bird.heightController,
          ]),
          builder: (context, child) => Stack(
                fit: StackFit.expand,
                alignment: Alignment.center,
                children: gamePageComponents(),
              )),
    );
  }

  Positioned gameOverPositioned() {
    return Positioned(
        left: 0,
        right: 0,
        top: 120,
        child: Opacity(
            opacity: gameOverOpacityAnimation.value,
            child: Image.asset(
              "assets/img/game-over.png",
              scale: 0.75,
            )));
  }

  Positioned scoreBoardPositioned() {
    return Positioned(
        top: scoreBoardTopAnimation.value,
        left: 0,
        right: 0,
        child: Image.asset("assets/img/score-board.png", scale: 0.75));
  }

  void buttonTremble(void Function() lastly) {
    buttonTapController
        .forward()
        .then((value) => buttonTapController.reverse().then((value) {
              lastly();
            }));
  }

  Positioned okPositioned() {
    return Positioned(
      left: 30,
      bottom: buttonsBottomAnimation.value -
          (isOkTapped ? buttonTapAnimation.value : 0),
      child: GestureDetector(
          onTap: () {
            isOkTapped = true;
            buttonTremble(() {
              isOkTapped = false;
              score = 0;
              newBest = false;
              Navigator.pushNamed(context, "/game");
            });
          },
          child: SizedBox(
            child: Image.asset(
              "assets/img/ok-button.png",
              fit: BoxFit.fitWidth,
              scale: 0.6,
            ),
          )),
    );
  }

  Positioned menuPositioned() {
    return Positioned(
      right: 30,
      bottom: buttonsBottomAnimation.value -
          (isMenuTapped ? buttonTapAnimation.value : 0),
      child: GestureDetector(
          onTap: () {
            isMenuTapped = true;
            buttonTremble(() {
              isMenuTapped = false;
              Navigator.pushNamed(context, "/");
            });
          },
          child: SizedBox(
            child: Image.asset(
              "assets/img/menu-button.png",
              fit: BoxFit.fitWidth,
              scale: 0.6,
            ),
          )),
    );
  }

  // work in progress 23点57分 2024年2月2日
  Positioned scoreOnBoardPositioned() {
    return Positioned(
      right: 50,
      top: 316,
      child: Row(
        children:
            numRowChilren(scoreOnBoardValueAnimation.value.round(), false),
      ),
    );
  }

  Positioned bestOnBoardPositioned() {
    return Positioned(
      right: 50,
      top: 380,
      child: Row(
          children:
              numRowChilren(bestOnBoardValueAnimation.value.round(), false)),
      // IntTween有奇奇怪怪的问题
    );
  }

  String? getMaterial() {
    if (score < 3) {
      return null;
    } else if (score < 10) {
      return "fe";
    } else if (score < 15) {
      return "cu";
    } else if (score < 25) {
      return "ag";
    } else {
      return "au";
    }
  }

  Positioned medalPositioned() {
    String? material = getMaterial();
    // print(material);
    return Positioned(
      top: 330,
      left: 58,
      child: Visibility(
          visible: material != null && showMadel,
          child: Image.asset(
            "assets/img/$material-medal.png",
            scale: 0.7,
          )),
    );
  }

  void gameOver() {
    FlappyBird.gameovering = true;

    gameOverController =
        AnimationController(vsync: this, duration: Duration(seconds: 3));

    // 尝试全局共用一个tickerProvider?
    gameOverOpacityAnimation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
            parent: gameOverController,
            curve: Interval(0, 0.2, curve: Curves.easeIn)));

    scoreBoardTopAnimation = Tween<double>(begin: FlappyBird.height, end: 260)
        .animate(CurvedAnimation(
            parent: gameOverController,
            curve: Interval(0.2, 0.5, curve: Curves.easeOut)));

    buttonsBottomAnimation = Tween<double>(begin: 0, end: 150).animate(
        CurvedAnimation(
            parent: gameOverController,
            curve: Interval(0.5, 0.7, curve: Curves.easeOut)));

    scoreOnBoardValueAnimation =
        Tween<double>(begin: -1, end: score.toDouble()).animate(
            CurvedAnimation(
                parent: gameOverController, curve: Interval(0.7, 0.85)));

    bestOnBoardValueAnimation = Tween<double>(begin: -1, end: best.toDouble())
        .animate(CurvedAnimation(
            parent: gameOverController, curve: Interval(0.85, 1)));

    // 这里应该有个swooshing的
    gameOverController.forward().then((value) {
      if (newBest) {
        showNewBest = true;
      }
      showMadel = true;
    });
  }
}

class Bird {
  late AnimationController angleController, wingController, heightController;
  late Animation<double> angleAnimation;
  late Animation<double> wingAnimation;

  late GravitySimulation heightSimulation;

  TickerProvider tickerProvider;

  late BuildContext birdContext;

  late double birdX;
  bool crashing = false;

  void Function() gameOver;

  Bird(this.tickerProvider, this.birdX, this.gameOver) {
    fall(100, 0);
    // print(heightSimulation);
  }

  Positioned positionedGenerate() {
    Positioned birds = Positioned(
      left: birdX,
      top: heightController.value,
      child: Transform.rotate(
        angle: angleAnimation.value,
        child: SizedBox(child: Builder(builder: (context) {
          birdContext = context;
          return Image.asset(
            FlappyBird.getBirdPath(wingAnimation.value.round()),
            scale: 0.95,
            // fit: BoxFit.fill,
          );
        })),
      ),
    );
    return birds;
  }

  void setAngle(double begin, double end, Duration duration, Curve curve,
      void Function() listener) {
    angleController =
        AnimationController(vsync: tickerProvider, duration: duration);
    angleAnimation =
        Tween<double>(begin: begin, end: end).animate(CurvedAnimation(
      parent: angleController,
      curve: curve,
    ));

    angleAnimation.addListener(listener);
    angleController.forward();
  }

  void setHeight(double height, double velocity, void Function() listener) {
    heightController = AnimationController(
        vsync: tickerProvider, lowerBound: 0, upperBound: double.infinity);
    heightSimulation = GravitySimulation(600, height, 1200, velocity);
    heightController.animateWith(heightSimulation);
    heightController.addListener(listener);
  }

  void setWing(int begin, int end, Duration duration) {
    print("$begin $end $duration");
    wingController = AnimationController(
      vsync: tickerProvider,
      duration: duration,
    );
    wingAnimation = Tween<double>(begin: begin.toDouble(), end: end.toDouble())
        .animate(CurvedAnimation(
      parent: wingController,
      curve: Curves.easeIn,
    ));
    wingController.repeat(reverse: true);
    // wingController.addStatusListener((status) {
    //   if (status == AnimationStatus.completed) {
    //     print("wingAniimation.value ${wingAnimation.value}");
    //   }
    // });
  }

  bool checkScore() {
    if (!_GamePageState.canScore || crashing) return false;
    Rect bird = FlappyBird.contextToRect(birdContext);
    for (var i in _GamePageState.tubeContexts) {
      Rect rect = FlappyBird.contextToRect(i);
      if (rect.top < 0 || rect.bottom < 0) continue;
      if (bird.left >= rect.left && bird.right <= rect.right) {
        _GamePageState.canScore = false;
        FlappyBird.music.play("score");
        return true;
      }
    }
    return false;
  }

  void checkMove() {
    if (checkTubesOverlaps() || checkGroundOverlaps()) {
      crash();
    }
    if (checkScore()) {
      FlappyBird.incScore();
    }
  }

  void jump() {
    print("Tap screen");
    if (crashing) return;
    print(_GamePageState.tubesController.status);

    FlappyBird.music.play("jump");
    setWing(0, FlappyBird.birdWings.length - 1, Duration(milliseconds: 100));
    setHeight(heightController.value, -280, checkMove);
    setAngle(angleAnimation.value, -23 * pi / 180, Duration(milliseconds: 300),
        Curves.decelerate, () {
      if (angleController.isCompleted) {
        fall(heightController.value, angleAnimation.value);
      }
    });
  }

  void fall(double height, double angle) {
    setWing(0, FlappyBird.birdWings.length - 1, Duration(milliseconds: 1000));
    setHeight(height, 0, checkMove);
    print("angle: $angle");
    setAngle(angle, 90 * pi / 180, Duration(milliseconds: 900), Curves.easeIn,
        () {
      // if (angleAnimation.value <= 0) {
      //   setWing(1, 1, Duration(milliseconds: 1));
      // }
    });
  }

  void crash() {
    if (crashing) return;
    crashing = true;

    // return;
    _GamePageState.tubesController.stop();
    FlappyBird.groundController.stop();

    // 放外面就会播放很多很多次
    FlappyBird.music.play("hit");
    FlappyBird.music.play("die");
    setWing(1, 1, Duration(seconds: 1));

    setAngle(angleAnimation.value, 90 * pi / 180, Duration(milliseconds: 300),
        Curves.easeIn, () {});

    setHeight(heightController.value, 0, () {
      if (checkGroundOverlaps()) {
        heightController.stop();
        Future.delayed(Duration(milliseconds: 500), () {
          gameOver();

          print("game_over");
        });
      }
    });
  }

  bool checkGroundOverlaps() {
    Rect birdRect = FlappyBird.contextToRect(birdContext);

    for (int i = 0; i < 2; i++) {
      Rect rect = FlappyBird.contextToRect(FlappyBird.groundContexts[i]);
      if (rect.overlaps(birdRect)) {
        if (!crashing) {
          print("Ground overlaps");
        }
        return true;
      }
    }

    return false;
  }

  bool checkTubesOverlaps() {
    // print(heightController.value);
    Rect birdRect = FlappyBird.contextToRect(birdContext);
    // _GamePageState.upsideTubes[0].

    // print(_GamePageState.tubeContexts);

    // works, 但很难玩
    for (var context in _GamePageState.tubeContexts) {
      Rect rect = FlappyBird.contextToRect(context);
      if (rect.overlaps(birdRect)) {
        // print("$rect $birdRect");
        if (!crashing) {
          print("Tube overlaps");
        }
        return true;
      }
    }

    return false;
  }
}
