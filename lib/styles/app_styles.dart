import 'package:flutter/material.dart';

class AppStyles {
  // Colors (paleta del document de la 2.1)
  static const Color primary = Color(0xFF5B3FD6); // violeta
  static const Color ink = Color(0xFF302B27); // grafit: text i icones
  static const Color blue = Color(0xFF87BCDE); // accent mascota
  static const Color pink = Color(0xFFF59CA9); // accent mascota
  static const Color coral = Color(0xFFF6828C); // accent mascota
  static const Color error = Color(0xFFC62828); // errors i vençuts

  // Colors que es poden assignar a cada mascota
  static const List<Color> petColors = [blue, pink, coral];

  // Espais
  static const double spaceXS = 4;
  static const double spaceS = 8;
  static const double spaceM = 16;
  static const double spaceL = 24;
  static const double spaceXL = 32;

  // Cantonades arrodonides
  static const double radius = 16;
}
