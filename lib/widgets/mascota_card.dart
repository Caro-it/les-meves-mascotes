import 'package:flutter/material.dart';

import '../models/mascota.dart';
import '../styles/app_styles.dart';

// Targeta d'una mascota per a la llista de la A02 (disseny de Stitch)
class MascotaCard extends StatelessWidget {
  const MascotaCard({super.key, required this.mascota, required this.onTap});

  final Mascota mascota;
  final VoidCallback onTap;

  // «Raça · Espècie · edat», només amb les dades que hi hagi
  String get _detall {
    final parts = <String>[
      if (mascota.raca != null) mascota.raca!,
      textEspecie(mascota.especie),
      if (mascota.dataNaixement != null) textEdat(mascota.dataNaixement!),
    ];
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final color = Color(mascota.color);

    return Card(
      clipBehavior: Clip.antiAlias,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: AppStyles.spaceM),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppStyles.radius),
      ),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(height: 6, color: color), // franja de color
            Padding(
              padding: const EdgeInsets.all(AppStyles.spaceM),
              child: Row(
                children: [
                  // Avatar (més endavant hi anirà la foto)
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(AppStyles.radius),
                    ),
                    child: Icon(Icons.pets, color: color, size: 32),
                  ),
                  const SizedBox(width: AppStyles.spaceM),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                mascota.nom,
                                overflow: TextOverflow.ellipsis,
                                style: AppStyles.titol.copyWith(fontSize: 20),
                              ),
                            ),
                            if (mascota.esterilitzat)
                              _Etiqueta(text: textEsterilitzat(mascota.sexe)),
                          ],
                        ),
                        const SizedBox(height: AppStyles.spaceXS),
                        Text(
                          _detall,
                          style: const TextStyle(color: AppStyles.ink),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppStyles.spaceS),
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppStyles.ink.withValues(alpha: 0.06),
                    child: const Icon(
                      Icons.chevron_right,
                      color: AppStyles.ink,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Etiqueta rosa petita, com «Esterilitzada» al disseny
class _Etiqueta extends StatelessWidget {
  const _Etiqueta({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppStyles.pink.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppStyles.ink,
        ),
      ),
    );
  }
}
