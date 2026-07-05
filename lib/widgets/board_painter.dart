import 'dart:math';
import 'dart:ui' as ui;

import 'package:baghchal_app/theme/app_theme.dart';
import 'package:flutter/material.dart';

class BoardPainter extends CustomPainter {
  final List<int> board;
  final List<int> tigerIndices;
  final List<int> goatIndices;
  final int? selectedTiger;
  final int? selectedGoat;
  final bool selectedGoatFromReserve;
  final String phase;
  final String turn;
  final bool aiEnabled;
  final bool showHints;
  final int? lastMoveFrom;
  final int? lastMoveTo;

  final List<Map<String, dynamic>> Function(int) getTigerMoves;
  final List<Map<String, dynamic>> Function(int) getGoatMoves;
  final ThemeColors themeColors;
  final ui.Image? tigerImage;
  final ui.Image? goatImage;

  const BoardPainter({
    required this.board,
    required this.tigerIndices,
    required this.goatIndices,
    required this.selectedTiger,
    required this.selectedGoat,
    required this.selectedGoatFromReserve,
    required this.phase,
    required this.turn,
    required this.aiEnabled,
    required this.showHints,
    required this.lastMoveFrom,
    required this.lastMoveTo,
    required this.getTigerMoves,
    required this.getGoatMoves,
    required this.themeColors,
    required this.tigerImage,
    required this.goatImage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final boardSize = size.width;
    final margin = boardSize * 0.1;
    final step = (boardSize - 2 * margin) / 4;

    Offset getPosPx(int index) {
      final row = index ~/ 5;
      final col = index % 5;
      return Offset(margin + col * step, margin + row * step);
    }

    final bgPaint = Paint()..color = themeColors.boardBg;
    canvas.drawRect(Rect.fromLTWH(0, 0, boardSize, boardSize), bgPaint);

    final linePaint = Paint()
      ..color = themeColors.lineColor.withOpacity(0.85)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const lineSegments = [
      [0, 1, 2, 3, 4],
      [5, 6, 7, 8, 9],
      [10, 11, 12, 13, 14],
      [15, 16, 17, 18, 19],
      [20, 21, 22, 23, 24],
      [0, 5, 10, 15, 20],
      [1, 6, 11, 16, 21],
      [2, 7, 12, 17, 22],
      [3, 8, 13, 18, 23],
      [4, 9, 14, 19, 24],
      [0, 6, 12, 18, 24],
      [4, 8, 12, 16, 20],
      [2, 6, 10],
      [2, 8, 14],
      [10, 16, 22],
      [14, 18, 22],
      [0, 12],
      [4, 12],
      [20, 12],
      [24, 12],
      [2, 12],
      [12, 22],
      [22, 10],
      [10, 2],
    ];
    final drawn = <String>{};
    for (final seg in lineSegments) {
      for (int i = 0; i < seg.length - 1; i++) {
        final a = seg[i], b = seg[i + 1];
        final key = '${min(a, b)}-${max(a, b)}';
        if (!drawn.contains(key)) {
          drawn.add(key);
          final p1 = getPosPx(a);
          final p2 = getPosPx(b);
          canvas.drawLine(p1, p2, linePaint);
        }
      }
    }

    final dotPaint = Paint()..color = themeColors.dotColor.withOpacity(0.7);
    for (int i = 0; i < 25; i++) {
      final pos = getPosPx(i);
      canvas.drawCircle(pos, 5, dotPaint);
    }

    if (lastMoveFrom != null && lastMoveTo != null) {
      final p1 = getPosPx(lastMoveFrom!);
      final p2 = getPosPx(lastMoveTo!);
      final paint = Paint()
        ..color = Colors.yellow.withOpacity(0.25)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(p1, 20, paint);
      canvas.drawCircle(p2, 20, paint);
    }

    if (showHints) {
      if (selectedTiger != null && turn == 'tiger' && !aiEnabled) {
        final moves = getTigerMoves(selectedTiger!);
        for (final m in moves) {
          final pos = getPosPx(m['to']);
          final color = m['capture'] != null
              ? const Color(0xFFE74C3C).withOpacity(0.5)
              : const Color(0xFF2ECC71).withOpacity(0.45);
          final paint = Paint()
            ..color = color
            ..style = PaintingStyle.fill;
          canvas.drawCircle(pos, 18, paint);
          final borderPaint = Paint()
            ..color = themeColors.lineColor.withOpacity(0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1;
          canvas.drawCircle(pos, 18, borderPaint);
        }
      }

      if (selectedGoat != null && turn == 'goat' && phase == 'movement') {
        final moves = getGoatMoves(selectedGoat!);
        for (final m in moves) {
          final pos = getPosPx(m['to']);
          final paint = Paint()
            ..color = const Color(0xFF3498DB).withOpacity(0.45)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(pos, 18, paint);
          final borderPaint = Paint()
            ..color = themeColors.lineColor.withOpacity(0.3)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1;
          canvas.drawCircle(pos, 18, borderPaint);
        }
      }

      if (selectedGoatFromReserve && turn == 'goat' && phase == 'placement') {
        for (int i = 0; i < 25; i++) {
          if (board[i] == 0) {
            final pos = getPosPx(i);
            final paint = Paint()
              ..color = const Color(0xFF2ECC71).withOpacity(0.25)
              ..style = PaintingStyle.fill;
            canvas.drawCircle(pos, 16, paint);
            final borderPaint = Paint()
              ..color = themeColors.lineColor.withOpacity(0.15)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1;
            canvas.drawCircle(pos, 16, borderPaint);
          }
        }
      }
    }

    for (int i = 0; i < 25; i++) {
      if (board[i] == 0) continue;
      final pos = getPosPx(i);
      final isTiger = board[i] == 1;
      final double r = isTiger ? 22 : 19;

      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(pos + const Offset(0, 4), r, shadowPaint);

      final strokeColor =
          isTiger ? themeColors.tigerBorder : themeColors.goatBorder;
      final Paint strokePaint = Paint()
        ..color = strokeColor
        ..strokeWidth = 3
        ..style = PaintingStyle.stroke;
      final image = isTiger ? tigerImage : goatImage;
      if (image != null) {
        final imageRect = Rect.fromCircle(center: pos, radius: r);
        final imageSize = Size(
          image.width.toDouble(),
          image.height.toDouble(),
        );
        final sourceRect = _coverSourceRect(imageSize);

        canvas.save();
        canvas.clipPath(Path()..addOval(imageRect));
        canvas.drawImageRect(image, sourceRect, imageRect, Paint());
        canvas.restore();
      } else {
        final fillColor =
            isTiger ? themeColors.tigerColor : themeColors.goatColor;
        final Paint piecePaint = Paint()
          ..color = fillColor
          ..style = PaintingStyle.fill;
        canvas.drawCircle(pos, r, piecePaint);
      }
      canvas.drawCircle(pos, r, strokePaint);

      if (isTiger && selectedTiger == i && !aiEnabled) {
        final glowPaint = Paint()
          ..color = themeColors.selectedGlow.withOpacity(0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4;
        canvas.drawCircle(pos, r + 6, glowPaint);
      }
      if (!isTiger && selectedGoat == i) {
        final glowPaint = Paint()
          ..color = const Color(0xFF3498DB).withOpacity(0.8)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4;
        canvas.drawCircle(pos, r + 5, glowPaint);
      }
    }
  }

  @override
  bool shouldRepaint(BoardPainter oldDelegate) => true;

  Rect _coverSourceRect(Size imageSize) {
    final imageAspect = imageSize.width / imageSize.height;
    const targetAspect = 1.0;

    if (imageAspect > targetAspect) {
      final width = imageSize.height * targetAspect;
      final left = (imageSize.width - width) / 2;
      return Rect.fromLTWH(left, 0, width, imageSize.height);
    }

    final height = imageSize.width / targetAspect;
    final top = (imageSize.height - height) / 2;
    return Rect.fromLTWH(0, top, imageSize.width, height);
  }
}
