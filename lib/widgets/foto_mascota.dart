import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../styles/app_styles.dart';

// Foto de la mascota o, si no n'hi ha (o no es pot llegir), la petjada
class FotoMascota extends StatelessWidget {
  const FotoMascota({
    super.key,
    required this.rutaFoto,
    required this.color,
    this.amplada = 64,
    this.alcada = 64,
    this.midaIcona = 32,
  });

  final String? rutaFoto;
  final Color color;
  final double amplada;
  final double alcada;
  final double midaIcona;

  @override
  Widget build(BuildContext context) {
    final petjada = Container(
      color: color.withValues(alpha: 0.25),
      alignment: Alignment.center,
      child: Icon(Icons.pets, color: color, size: midaIcona),
    );

    Widget contingut = petjada;
    if (rutaFoto != null) {
      contingut = kIsWeb
          // A Chrome la ruta és una adreça temporal (blob:)
          ? Image.network(
              rutaFoto!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => petjada,
            )
          // Al mòbil és un fitxer de la carpeta de l'app
          : Image.file(
              File(rutaFoto!),
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => petjada,
            );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppStyles.radius),
      child: SizedBox(width: amplada, height: alcada, child: contingut),
    );
  }
}
