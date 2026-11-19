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
            ],
          ),
        );
      },
    );
  }
}
