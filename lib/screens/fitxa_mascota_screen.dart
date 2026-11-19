import 'package:flutter/material.dart';

import '../models/mascota.dart';
import '../services/auth_service.dart';
import '../services/mascota_service.dart';
import '../styles/app_styles.dart';
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
              ListTile(
                title: const Text('Espècie'),
                subtitle: Text(m.especie.name),
              ),
              ListTile(
                title: const Text('Raça'),
                subtitle: Text(m.raca ?? '—'),
              ),
              ListTile(
                title: const Text('Sexe'),
                subtitle: Text(m.sexe?.name ?? '—'),
              ),
              ListTile(
                title: const Text('Data de naixement'),
                subtitle: Text(_data(m.dataNaixement)),
              ),
              ListTile(
                title: const Text('Pes'),
                subtitle: Text(
                  m.pes == null
                      ? '—'
                      : '${m.pes!.toString().replaceAll('.', ',')} kg',
                ),
              ),
              ListTile(
                title: const Text('Xip'),
                subtitle: Text(m.numXip ?? '—'),
              ),
            ],
          ),
        );
      },
    );
  }
}
