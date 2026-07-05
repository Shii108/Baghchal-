import 'package:flutter/material.dart';

enum AppTheme { green, blue, brown, purple, dark, wood, stone, gold }

class ThemeColors {
  final Color boardBg;
  final Color lineColor;
  final Color dotColor;
  final Color boardFrame;
  final Color boardShadow;
  final Color tigerColor;
  final Color goatColor;
  final Color goatBorder;
  final Color tigerBorder;
  final Color selectedGlow;

  const ThemeColors({
    required this.boardBg,
    required this.lineColor,
    required this.dotColor,
    required this.boardFrame,
    required this.boardShadow,
    required this.tigerColor,
    required this.goatColor,
    required this.goatBorder,
    required this.tigerBorder,
    required this.selectedGlow,
  });

  static const Map<AppTheme, ThemeColors> _map = {
    AppTheme.green: ThemeColors(
      boardBg: Color(0xFF2d5a27),
      lineColor: Color(0xFFdcc29e),
      dotColor: Color(0xFFdcc29e),
      boardFrame: Color(0xFFb3926e),
      boardShadow: Color(0xFF8a7a5a),
      tigerColor: Color(0xFFE67E22),
      goatColor: Color(0xFFFFFFFF),
      goatBorder: Color(0xFF000000),
      tigerBorder: Color(0xFFFFFFFF),
      selectedGlow: Color(0xFFf1c40f),
    ),
    AppTheme.blue: ThemeColors(
      boardBg: Color(0xFF1a4a6b),
      lineColor: Color(0xFFb0d4f1),
      dotColor: Color(0xFFb0d4f1),
      boardFrame: Color(0xFF4a7a9c),
      boardShadow: Color(0xFF2a5a7a),
      tigerColor: Color(0xFFE67E22),
      goatColor: Color(0xFFFFFFFF),
      goatBorder: Color(0xFF000000),
      tigerBorder: Color(0xFFFFFFFF),
      selectedGlow: Color(0xFFf1c40f),
    ),
    AppTheme.brown: ThemeColors(
      boardBg: Color(0xFF6b4c3b),
      lineColor: Color(0xFFe8d5b5),
      dotColor: Color(0xFFe8d5b5),
      boardFrame: Color(0xFF8a6b4a),
      boardShadow: Color(0xFF5a3b2a),
      tigerColor: Color(0xFFE67E22),
      goatColor: Color(0xFFFFFFFF),
      goatBorder: Color(0xFF000000),
      tigerBorder: Color(0xFFFFFFFF),
      selectedGlow: Color(0xFFf1c40f),
    ),
    AppTheme.purple: ThemeColors(
      boardBg: Color(0xFF3a2a5a),
      lineColor: Color(0xFFc9b8e8),
      dotColor: Color(0xFFc9b8e8),
      boardFrame: Color(0xFF6a4a8a),
      boardShadow: Color(0xFF2a1a4a),
      tigerColor: Color(0xFFE67E22),
      goatColor: Color(0xFFFFFFFF),
      goatBorder: Color(0xFF000000),
      tigerBorder: Color(0xFFFFFFFF),
      selectedGlow: Color(0xFFf1c40f),
    ),
    AppTheme.dark: ThemeColors(
      boardBg: Color(0xFF1a1a1a),
      lineColor: Color(0xFF888888),
      dotColor: Color(0xFF888888),
      boardFrame: Color(0xFF444444),
      boardShadow: Color(0xFF0a0a0a),
      tigerColor: Color(0xFFE67E22),
      goatColor: Color(0xFFCCCCCC),
      goatBorder: Color(0xFF000000),
      tigerBorder: Color(0xFFFFFFFF),
      selectedGlow: Color(0xFFf1c40f),
    ),
    AppTheme.wood: ThemeColors(
      boardBg: Color(0xFFb58a5a),
      lineColor: Color(0xFF5a3a1a),
      dotColor: Color(0xFF5a3a1a),
      boardFrame: Color(0xFF8a6a3a),
      boardShadow: Color(0xFF7a5a2a),
      tigerColor: Color(0xFFE67E22),
      goatColor: Color(0xFFFFFFFF),
      goatBorder: Color(0xFF000000),
      tigerBorder: Color(0xFFFFFFFF),
      selectedGlow: Color(0xFFf1c40f),
    ),
    AppTheme.stone: ThemeColors(
      boardBg: Color(0xFF4a4a4a),
      lineColor: Color(0xFFaaaaaa),
      dotColor: Color(0xFFaaaaaa),
      boardFrame: Color(0xFF2a2a2a),
      boardShadow: Color(0xFF1a1a1a),
      tigerColor: Color(0xFFE67E22),
      goatColor: Color(0xFFCCCCCC),
      goatBorder: Color(0xFF000000),
      tigerBorder: Color(0xFFFFFFFF),
      selectedGlow: Color(0xFFf1c40f),
    ),
    AppTheme.gold: ThemeColors(
      boardBg: Color(0xFFc9a84c),
      lineColor: Color(0xFF8a6a2a),
      dotColor: Color(0xFF8a6a2a),
      boardFrame: Color(0xFFa8863a),
      boardShadow: Color(0xFF8a6a2a),
      tigerColor: Color(0xFFE67E22),
      goatColor: Color(0xFFFFFFFF),
      goatBorder: Color(0xFF000000),
      tigerBorder: Color(0xFFFFFFFF),
      selectedGlow: Color(0xFFf1c40f),
    ),
  };

  static ThemeColors of(AppTheme theme) => _map[theme]!;
}
