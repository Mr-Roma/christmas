import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

const double angleIncrementation = 0.01;

class SnowWidget extends StatefulWidget {
  final int totalSnow;
  final double speed;
  final bool isRunning;
  final double maxRadius;
  final Color snowColor;
  final bool hasSpinningEffect;
  final bool startSnowing;
  final bool linearFallOff;

  const SnowWidget({
    Key? key,
    required this.totalSnow,
    required this.speed,
    required this.isRunning,
    required this.snowColor,
    this.maxRadius = 4,
    this.linearFallOff = false,
    this.hasSpinningEffect = true,
    this.startSnowing = false,
  }) : super(key: key);

  @override
  _SnowWidgetState createState() => _SnowWidgetState();
}

class _SnowWidgetState extends State<SnowWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  double W = 0;
  double H = 0;

  final Random _rnd = Random();
  final List<SnowBall> _snows = [];
  double angle = 0;

  @override
  void initState() {
    super.initState();
    init(); // Initialize snowballs and animation
  }

  @override
  void didUpdateWidget(covariant SnowWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_hasParametersChanged(oldWidget)) {
      init(hasInit: true, previousTotalSnow: oldWidget.totalSnow);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_snows.isEmpty) {
      init();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> init({bool hasInit = false, int previousTotalSnow = 0}) async {
    W = MediaQuery.of(context).size.width;
    H = MediaQuery.of(context).size.height;

    if (hasInit) {
      // Reset snowballs if parameters have changed
      final int newTotalSnow = widget.totalSnow - previousTotalSnow;
      if (newTotalSnow > 0) {
        await _createSnowBall(newBallToAdd: newTotalSnow);
      }
    } else {
      controller = AnimationController(
        lowerBound: 0,
        upperBound: 1,
        vsync: this,
        duration: const Duration(milliseconds: 5000),
      )..addListener(() {
          if (mounted) {
            setState(() {
              update(); // Update snowball positions
            });
          }
        });

      controller.repeat();
    }
  }

  Future<void> _createSnowBall({required int newBallToAdd}) async {
    final int inverseYAxis = widget.startSnowing ? -1 : 1;

    for (int i = 0; i < newBallToAdd; i++) {
      final double radius = _rnd.nextDouble() * widget.maxRadius + 2;
      final double density = _rnd.nextDouble() * widget.speed;

      final double x = _rnd.nextDouble() * W;
      final double y = _rnd.nextDouble() * H * inverseYAxis;

      _snows.add(SnowBall(x: x, y: y, radius: radius, density: density));
    }
  }

  bool _hasParametersChanged(covariant SnowWidget oldWidget) {
    return oldWidget.startSnowing != widget.startSnowing ||
        oldWidget.totalSnow != widget.totalSnow ||
        oldWidget.maxRadius != widget.maxRadius ||
        oldWidget.snowColor != widget.snowColor;
  }

  Future<void> update() async {
    angle += angleIncrementation;

    if (widget.totalSnow != _snows.length) {
      await _createSnowBall(newBallToAdd: widget.totalSnow - _snows.length);
    }

    for (int i = 0; i < widget.totalSnow; i++) {
      final SnowBall snow = _snows.elementAt(i);
      final double sinX = widget.linearFallOff ? snow.density : snow.radius;

      snow.y += (cos(angle + snow.density) + snow.radius).abs() * widget.speed;
      snow.x += sin(sinX) * 2 * widget.speed;

      if (snow.x > W + snow.radius ||
          snow.x < -snow.radius ||
          snow.y > H + snow.radius ||
          snow.y < -snow.radius) {
        _snows[i] = SnowBall(
          x: _rnd.nextDouble() * W,
          y: -10,
          radius: snow.radius,
          density: snow.density,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isRunning && !controller.isAnimating) {
      controller.repeat();
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        W = constraints.maxWidth;
        H = constraints.maxHeight;

        return CustomPaint(
          willChange: widget.isRunning,
          isComplex: true,
          size: Size.infinite,
          painter: SnowPainter(
            isRunning: widget.isRunning,
            snows: _snows,
            snowColor: widget.snowColor,
            hasSpinningEffect: widget.hasSpinningEffect,
          ),
        );
      },
    );
  }
}

// Dummy SnowBall and SnowPainter definitions for completeness
class SnowBall {
  double x, y, radius, density;
  SnowBall(
      {required this.x,
      required this.y,
      required this.radius,
      required this.density});
}

class SnowPainter extends CustomPainter {
  final bool isRunning;
  final List<SnowBall> snows;
  final Color snowColor;
  final bool hasSpinningEffect;

  SnowPainter({
    required this.isRunning,
    required this.snows,
    required this.snowColor,
    required this.hasSpinningEffect,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()..color = snowColor;

    for (final snow in snows) {
      // Draw spinning effect if enabled
      if (hasSpinningEffect) {
        paint.shader = RadialGradient(
          colors: [snowColor.withOpacity(0.7), snowColor.withOpacity(0.2)],
        ).createShader(Rect.fromCircle(
          center: Offset(snow.x, snow.y),
          radius: snow.radius,
        ));
      }

      // Draw the snowball
      canvas.drawCircle(Offset(snow.x, snow.y), snow.radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => isRunning;
}
