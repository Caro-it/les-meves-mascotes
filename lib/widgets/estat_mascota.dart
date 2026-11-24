import 'package:flutter/material.dart';

import '../models/registre.dart';
import '../services/auth_service.dart';
import '../services/registre_service.dart';
import '../styles/app_styles.dart';

// Etiqueta «Tot al dia / Toca aviat / Vençut» d'una mascota (A02)
class EstatMascota extends StatefulWidget {
  const EstatMascota({super.key, required this.mascotaId});

  final String mascotaId;

  @override
  State<EstatMascota> createState() => _EstatMascotaState();
}

class _EstatMascotaState extends State<EstatMascota> {
  late final Stream<List<Registre>> _registres;

  @override
  void initState() {
    super.initState();
    final uid = AuthService().usuariActual!.uid;
    _registres = RegistreService().llegirRegistres(uid, widget.mascotaId);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Registre>>(
      stream: _registres,
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();
        final estat = estatMascota(snapshot.data!);
        if (estat == null) return const SizedBox.shrink();

        // Registres que tenen aquest estat (el més urgent primer)
        final afectats =
            snapshot.data!.where((r) => estatRegistre(r) == estat).toList()
              ..sort((a, b) => a.properaDosi!.compareTo(b.properaDosi!));
        final primer = afectats.first;
        final mes = afectats.length > 1 ? ' +${afectats.length - 1}' : '';
        final dia =
            '${primer.properaDosi!.day.toString().padLeft(2, '0')}/'
            '${primer.properaDosi!.month.toString().padLeft(2, '0')}';

        final (text, color) = switch (estat) {
          EstatRegistre.alDia => ('Tot al dia', AppStyles.ok),
          EstatRegistre.tocaAviat => (
            'Toca aviat: ${primer.nom} ($dia)$mes',
            AppStyles.avis,
          ),
          EstatRegistre.vencut => (
            'Vençut: ${primer.nom}$mes',
            AppStyles.error,
          ),
        };
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        );
      },
    );
  }
}
