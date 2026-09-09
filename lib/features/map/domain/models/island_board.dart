import 'package:flutter/material.dart';

class IslandInfo {
  final int number;
  final String title;
  final String subtitle;
  final Color themeColor;
  final double mapX;
  final double mapY;
  final double dockX;
  final double dockY;
  final double verticalY;
  final double verticalXRatio;

  const IslandInfo({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.themeColor,
    required this.mapX,
    required this.mapY,
    required this.dockX,
    required this.dockY,
    required this.verticalY,
    required this.verticalXRatio,
  });
}

class SnakesAndLaddersConfig {
  static const int gridCols = 6;
  static const int gridRows = 8;
  static const int totalSquares = 48; // 6 * 8

  static const Map<int, int> ladders = {
    4: 15,
    11: 22,
    18: 29,
    24: 37,
    33: 44,
  };

  static const Map<int, int> snakes = {
    16: 5,
    23: 8,
    32: 19,
    39: 26,
    46: 30,
  };

  static const Set<int> blueSquares = {4, 11, 18, 24, 33};
  static const Set<int> redSquares = {16, 23, 32, 39, 46};

  static const double verticalMapHeight = 2100.0;

  static const List<IslandInfo> islands = [
    IslandInfo(
      number: 1,
      title: 'Foosha Köyü',
      subtitle: 'Büyük Maceranın Başlangıcı ⚓',
      themeColor: Color(0xFFFFD1DC),
      mapX: 0.14,
      mapY: 0.77,
      dockX: 0.18,
      dockY: 0.83,
      verticalY: 1860,
      verticalXRatio: 0.30,
    ),
    IslandInfo(
      number: 2,
      title: 'Alabasta',
      subtitle: 'Çöl Krallığı & Poneglyph 🏜️',
      themeColor: Color(0xFFD8F3DC),
      mapX: 0.31,
      mapY: 0.74,
      dockX: 0.35,
      dockY: 0.80,
      verticalY: 1680,
      verticalXRatio: 0.72,
    ),
    IslandInfo(
      number: 3,
      title: 'Skypiea',
      subtitle: 'Gökyüzü Adası & Altın Çan ☁️',
      themeColor: Color(0xFFFFDFD3),
      mapX: 0.16,
      mapY: 0.49,
      dockX: 0.20,
      dockY: 0.42,
      verticalY: 1480,
      verticalXRatio: 0.25,
    ),
    IslandInfo(
      number: 4,
      title: 'Water 7',
      subtitle: 'Sular Şehri & Deniz Treni 🚂',
      themeColor: Color(0xFFD4F0F7),
      mapX: 0.12,
      mapY: 0.18,
      dockX: 0.17,
      dockY: 0.22,
      verticalY: 1290,
      verticalXRatio: 0.60,
    ),
    IslandInfo(
      number: 5,
      title: 'Sabaody',
      subtitle: 'Yeni Dünya Öncesi Buluşma 🫧',
      themeColor: Color(0xFFE6E6FA),
      mapX: 0.26,
      mapY: 0.25,
      dockX: 0.32,
      dockY: 0.27,
      verticalY: 1100,
      verticalXRatio: 0.76,
    ),
    IslandInfo(
      number: 6,
      title: 'Balıkadam Adası',
      subtitle: 'Denizaltı Krallığı 🧜‍♂️',
      themeColor: Color(0xFFFFD6BA),
      mapX: 0.44,
      mapY: 0.27,
      dockX: 0.40,
      dockY: 0.36,
      verticalY: 910,
      verticalXRatio: 0.28,
    ),
    IslandInfo(
      number: 7,
      title: 'Dressrosa',
      subtitle: 'Alev Meyvesi & Gladyatörler ⚔️',
      themeColor: Color(0xFFFFF1BD),
      mapX: 0.53,
      mapY: 0.52,
      dockX: 0.48,
      dockY: 0.55,
      verticalY: 720,
      verticalXRatio: 0.68,
    ),
    IslandInfo(
      number: 8,
      title: 'Zou',
      subtitle: 'Bin Yaşındaki Dev Fil 🐘',
      themeColor: Color(0xFFC7F9CC),
      mapX: 0.65,
      mapY: 0.76,
      dockX: 0.61,
      dockY: 0.73,
      verticalY: 530,
      verticalXRatio: 0.26,
    ),
    IslandInfo(
      number: 9,
      title: 'Wano',
      subtitle: 'Samuraylar Ülkesi & Kaido 🏯',
      themeColor: Color(0xFFFFE5EC),
      mapX: 0.84,
      mapY: 0.75,
      dockX: 0.79,
      dockY: 0.80,
      verticalY: 340,
      verticalXRatio: 0.70,
    ),
    IslandInfo(
      number: 10,
      title: 'Raftel',
      subtitle: 'Büyük Hazine & One Piece! 👑🏴‍☠️',
      themeColor: Color(0xFFFFC857),
      mapX: 0.76,
      mapY: 0.28,
      dockX: 0.67,
      dockY: 0.49,
      verticalY: 130,
      verticalXRatio: 0.50,
    ),
  ];

  /// Computes (col, row) on a 6x8 grid from square number [1..48].
  /// col in 0..5 (x axis), row in 0..7 (y axis, 0 is top, 7 is bottom).
  static Point<int> getGridPosition(int? squareNumber) {
    final safe = (squareNumber ?? 1).clamp(1, totalSquares);
    final rowFromBottom = (safe - 1) ~/ gridCols;
    int col = (safe - 1) % gridCols;
    if (rowFromBottom % 2 == 1) {
      col = (gridCols - 1) - col; // right to left for alternating rows
    }
    final row = (gridRows - 1) - rowFromBottom;
    return Point<int>(col, row);
  }
}

class Point<T extends num> {
  final T x;
  final T y;
  const Point(this.x, this.y);
}
