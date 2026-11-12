import 'package:flutter/material.dart';

import '../services/auth_service.dart';

// A02 · Inici (provisional: de moment només serveix per provar la sessió)
class IniciScreen extends StatelessWidget {
  const IniciScreen({super.key});

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
      body: const Center(child: Text('Encara no tens cap mascota')),
    );
  }
}
