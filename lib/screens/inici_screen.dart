import 'package:flutter/material.dart';

import '../models/usuari.dart';
import '../services/auth_service.dart';
import '../services/usuari_service.dart';

// A02 · Inici
class IniciScreen extends StatefulWidget {
  const IniciScreen({super.key});

  @override
  State<IniciScreen> createState() => _IniciScreenState();
}

class _IniciScreenState extends State<IniciScreen> {
  late final Future<Usuari?> _perfil;

  @override
  void initState() {
    super.initState();
    final uid = AuthService().usuariActual!.uid;
    _perfil = UsuariService().llegirPerfil(uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Les meves mascotes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Tancar sessió',
            onPressed: () => AuthService().tancarSessio(),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: FutureBuilder<Usuari?>(
              future: _perfil,
              builder: (context, snapshot) {
                final nom = snapshot.data?.nom;
                return Text(nom == null ? 'Hola!' : 'Hola, $nom');
              },
            ),
          ),
          const Expanded(
            child: Center(child: Text('Encara no tens cap mascota')),
          ),
        ],
      ),
    );
  }
}
