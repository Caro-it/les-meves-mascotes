import 'package:flutter/material.dart';

import '../styles/app_styles.dart';

// Selector «Iniciar sessió | Crear compte» de la A01 amb una pastilla violeta
// que llisca d'un costat a l'altre (substitueix el SegmentedButton).
class SelectorMode extends StatelessWidget {
  const SelectorMode({
    super.key,
    required this.modeCrear,
    required this.onChanged,
  });

  final bool modeCrear; // false = Iniciar sessió · true = Crear compte
  final ValueChanged<bool> onChanged;

  static const _durada = Duration(milliseconds: 250);
  static const _gris = Color(0xFFEAE5E2); // gris del selector (Stitch)

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: _gris,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Stack(
        children: [
          // La pastilla: ocupa la meitat i es mou amb AnimatedAlign
          AnimatedAlign(
            duration: _durada,
            curve: Curves.easeInOut,
            alignment:
                modeCrear ? Alignment.centerRight : Alignment.centerLeft,
            child: FractionallySizedBox(
              widthFactor: 0.5,
              heightFactor: 1,
              child: Container(
                decoration: BoxDecoration(
                  color: AppStyles.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
          // Els dos botons, per sobre de la pastilla. Positioned.fill + stretch:
          // ocupen tota l'alçada (text centrat i tota la zona es pot tocar)
          Positioned.fill(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _Segment(
                  text: 'Iniciar sessió',
                  icona: Icons.lock_outline,
                  seleccionat: !modeCrear,
                  onTap: () => onChanged(false),
                ),
                _Segment(
                  text: 'Crear compte',
                  icona: Icons.person_add_alt,
                  seleccionat: modeCrear,
                  onTap: () => onChanged(true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.text,
    required this.icona,
    required this.seleccionat,
    required this.onTap,
  });

  final String text;
  final IconData icona;
  final bool seleccionat;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        selected: seleccionat,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          // El color del text i de la icona també canvia a poc a poc
          child: TweenAnimationBuilder<Color?>(
            duration: SelectorMode._durada,
            tween: ColorTween(
              end: seleccionat ? Colors.white : AppStyles.ink,
            ),
            builder: (context, color, _) => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icona, size: 18, color: color),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    text,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: color, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
