import 'package:flutter/material.dart';
import '../theme/colors.dart';

class Sparkline extends StatelessWidget {
  final List<double> data;
  final double width;
  final double height;
  final Color color;
  final double strokeWidth;

  const Sparkline({
    Key? key,
    required this.data,
    this.width = 120,
    this.height = 40,
    this.color = AppColors.accent,
    this.strokeWidth = 2.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (data.length < 2) return SizedBox(width: width, height: height);

    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(painter: _SparklinePainter(data, color, strokeWidth)),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final Color color;
  final double strokeWidth;

  _SparklinePainter(this.data, this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    final double max = data.reduce((a, b) => a > b ? a : b);
    final double min = data.reduce((a, b) => a < b ? a : b);
    final double range = max - min == 0 ? 1.0 : max - min;
    const double padding = 4.0;

    final Paint linePaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final Path path = Path();
    final double xStep = (size.width - padding * 2) / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final double x = padding + i * xStep;
      final double y =
          padding +
          (1.0 - (data[i] - min) / range) * (size.height - padding * 2);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    // Draw the sparkline
    canvas.drawPath(path, linePaint);

    // Draw the gradient fill under the line
    final Paint fillPaint = Paint()
      ..style = PaintingStyle.fill
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [color.withOpacity(0.15), color.withOpacity(0.0)],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final Path fillPath = Path.from(path);
    fillPath.lineTo(padding + (data.length - 1) * xStep, size.height - padding);
    fillPath.lineTo(padding, size.height - padding);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
