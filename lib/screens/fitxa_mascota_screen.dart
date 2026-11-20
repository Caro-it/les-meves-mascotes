import 'package:flutter/material.dart';

import '../models/mascota.dart';
import '../services/auth_service.dart';
import '../services/mascota_service.dart';
import '../styles/app_styles.dart';
import '../widgets/foto_mascota.dart';
import 'historial_screen.dart';
import 'nou_registre_screen.dart';
import 'nova_mascota_screen.dart';

// A04 · Fitxa de la mascota
class FitxaMascotaScreen extends StatefulWidget {
  const FitxaMascotaScreen({super.key, required this.mascotaId});

  final String mascotaId;

  @override
  State<FitxaMascotaScreen> createState() => _FitxaMascotaScreenState();
}

class _FitxaMascotaScreenState extends State<FitxaMascotaScreen> {
  late final Stream<Mascota?> _mascota;

  @override
  void initState() {
    super.initState();
    final uid = AuthService().usuariActual!.uid;
    _mascota = MascotaService().llegirMascota(uid, widget.mascotaId);
  }

  String _data(DateTime? d) => d == null
      ? '—'
      : '${d.day.toString().padLeft(2, '0')}/'
            '${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _textNascut(Sexe? sexe) => switch (sexe) {
    Sexe.mascle => 'Nascut',
    Sexe.femella => 'Nascuda',
    null => 'Nascut/da',
  };

  Future<void> _esborrar(Mascota m) async {
    final confirmat = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Esborrar mascota'),
        content: Text('Segur que vols esborrar ${m.nom}? No es pot desfer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel·lar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppStyles.error),
            child: const Text('Esborrar'),
          ),
        ],
      ),
    );
    if (confirmat != true) return;

    final uid = AuthService().usuariActual!.uid;
    try {
      await MascotaService().esborrarMascota(uid, m.id);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No s'ha pogut esborrar la mascota")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Mascota?>(
      stream: _mascota,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text("No s'ha pogut carregar la fitxa")),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final m = snapshot.data!;
        return Scaffold(
          appBar: AppBar(
            title: Text(m.nom),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Editar',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NovaMascotaScreen(mascota: m),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Esborrar',
                onPressed: () => _esborrar(m),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(AppStyles.spaceM),
            children: [
              // Capçalera amb la foto (o la petjada si no en té)
              FotoMascota(
                rutaFoto: m.rutaFoto,
                color: Color(m.color),
                amplada: double.infinity,
                alcada: 180,
                midaIcona: 72,
              ),
              // Targeta principal, muntada sobre la capçalera
              Transform.translate(
                offset: const Offset(0, -28),
                child: Card(
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppStyles.spaceS,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppStyles.radius),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppStyles.spaceM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.nom,
                          style: AppStyles.titol.copyWith(fontSize: 32),
                        ),
                        const SizedBox(height: AppStyles.spaceXS),
                        Text(
                          [
                            textEspecie(m.especie),
                            if (m.raca != null) m.raca!,
                            if (m.dataNaixement != null)
                              textEdat(m.dataNaixement!),
                          ].join(' · '),
                        ),
                        if (m.dataNaixement != null)
                          Text(
                            '${_textNascut(m.sexe)} el ${_data(m.dataNaixement)}',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppStyles.ink.withValues(alpha: 0.6),
                            ),
                          ),
                        if (m.esterilitzat) ...[
                          const SizedBox(height: AppStyles.spaceS),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppStyles.blue.withValues(alpha: 0.4),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.check_circle_outline,
                                  size: 16,
                                  color: AppStyles.ink,
                                ),
                                const SizedBox(width: AppStyles.spaceXS),
                                Text(
                                  textEsterilitzat(m.sexe),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SizedBox(height: AppStyles.spaceM),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  backgroundColor:
                                      AppStyles.ink.withValues(alpha: 0.06),
                                  side: BorderSide.none,
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => HistorialScreen(
                                        mascotaId: m.id,
                                        nomMascota: m.nom,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.menu_book_outlined),
                                label: const Text('Historial'),
                              ),
                            ),
                            const SizedBox(width: AppStyles.spaceS),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          NouRegistreScreen(mascotaId: m.id),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Nou registre'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // Dades de la 2.1 que no surten a Stitch
              // (també es puja, perquè no quedi un forat entre les targetes)
              Transform.translate(
                offset: const Offset(0, -16),
                child: Card(
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(
                    horizontal: AppStyles.spaceS,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppStyles.radius),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.wc),
                        title: const Text('Sexe'),
                        subtitle: Text(switch (m.sexe) {
                          Sexe.mascle => 'Mascle',
                          Sexe.femella => 'Femella',
                          null => '—',
                        }),
                      ),
                      ListTile(
                        leading: const Icon(Icons.monitor_weight_outlined),
                        title: const Text('Pes'),
                        subtitle: Text(
                          m.pes == null
                              ? '—'
                              : '${m.pes!.toString().replaceAll('.', ',')} kg',
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.memory),
                        title: const Text('Xip'),
                        subtitle: Text(m.numXip ?? '—'),
                      ),
                      if (m.esterilitzat)
                        ListTile(
                          leading: const Icon(Icons.event_available),
                          title: const Text("Data d'esterilització"),
                          subtitle: Text(_data(m.dataEsterilitzacio)),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
