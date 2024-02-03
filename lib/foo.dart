import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CollisionDetectionDemo(),
    );
  }
}

class CollisionDetectionDemo extends StatefulWidget {
  const CollisionDetectionDemo({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _CollisionDetectionDemoState createState() => _CollisionDetectionDemoState();
}

class _CollisionDetectionDemoState extends State<CollisionDetectionDemo> {
  Rect playerRect = Rect.fromPoints(Offset(50.0, 50.0), Offset(100.0, 100.0));
  Rect obstacleRect =
      Rect.fromPoints(Offset(150.0, 150.0), Offset(200.0, 200.0));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Collision Detection Demo'),
      ),
      body: GestureDetector(
        onPanDown: (details) {
          setState(() {
            print("${details}");
            // playerRect =
            //     playerRect.translate(details.delta.dx, details.delta.dy);

            // 碰撞检测
            if (playerRect.overlaps(obstacleRect)) {
              // 处理碰撞逻辑，例如停止移动或执行其他操作
              print('Collision detected!');
            }
          });
        },
        child: CustomPaint(
          painter: CollisionPainter(playerRect, obstacleRect),
        ),
      ),
    );
  }
}

class CollisionPainter extends CustomPainter {
  final Rect playerRect;
  final Rect obstacleRect;

  CollisionPainter(this.playerRect, this.obstacleRect);

  @override
  void paint(Canvas canvas, Size size) {
    // 绘制玩家和障碍物
    Paint playerPaint = Paint()..color = Colors.blue;
    Paint obstaclePaint = Paint()..color = Colors.red;

    canvas.drawRect(playerRect, playerPaint);
    canvas.drawRect(obstacleRect, obstaclePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
