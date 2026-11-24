import 'package:flutter/material.dart';

import '../styles/app_styles.dart';

// Targeta blanca amb icona i títol per a cada camp d'un formulari
// (disseny de Stitch de la A03 i la A06). Dins, els camps tenen fons beix.
class CampTargeta extends StatelessWidget {
  const CampTargeta({
    super.key,
    required this.icona,
    required this.titol,
    required this.child,
    this.nota,
    this.trailing,
  });

  final IconData icona;
  final String titol;
  final Widget child;
  final String? nota; // p. ex. «Obligatori» o «Opcional»
  final Widget? trailing; // p. ex. un interruptor al costat del títol

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: AppStyles.spaceM),
      padding: const EdgeInsets.all(AppStyles.spaceM),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppStyles.radius),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icona, size: 20, color: AppStyles.primary),
              const SizedBox(width: AppStyles.spaceS),
              Expanded(
                child: Text(
                  titol,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              if (nota != null)
                Text(
                  nota!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppStyles.primary,
                  ),
                ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: AppStyles.spaceS),
          // Els camps de dins, amb fons beix en lloc de blanc
          Theme(
            data: tema.copyWith(
              inputDecorationTheme: tema.inputDecorationTheme.copyWith(
                fillColor: AppStyles.beige,
              ),
            ),
            child: child,
          ),
        ],
      ),
    );
  }
}
