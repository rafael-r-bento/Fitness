/*
 * Fitness - a fitness app
 * Copyright (C) 2023-2025  Rafael Bento
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:flutter/material.dart';

class ActivityCircle extends CustomPainter {
  int value, limit;
  ui.Image image;

  ActivityCircle({this.value = 0, this.limit = 0, required this.image});

  @override
  void paint(Canvas canvas, Size size) {
    Paint paintCircle = Paint()..color = const Color(0xFF424242);

    Paint backgroundArc = Paint()
      ..color = ThemeData.dark().canvasColor
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    Paint paintArc = Paint()
      ..color = ThemeData.dark().colorScheme.secondary
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2, paintCircle);
    canvas.drawArc(
        Rect.fromCircle(
          center: size.center(Offset.zero),
          radius: (size.width / 2) * 0.8,
        ),
        0.60 * math.pi,
        1.80 * math.pi,
        false,
        backgroundArc);
    canvas.drawArc(
        Rect.fromCircle(
          center: size.center(Offset.zero),
          radius: (size.width / 2) * 0.8,
        ),
        0.60 * math.pi,
        value >= limit ? 1.80 * math.pi : (value / limit) * 1.80 * math.pi,
        false,
        paintArc);
    paintImage(
      canvas: canvas,
      rect: Rect.fromCircle(
        center: size.center(Offset.zero),
        radius: (size.width / 2) * 0.6,
      ),
      image: image,
    );
  }

  @override
  bool shouldRepaint(ActivityCircle oldDelegate) => true;
}
