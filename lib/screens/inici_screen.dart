import 'package:flutter/material.dart';

import '../models/mascota.dart';
import '../models/usuari.dart';
import '../services/auth_service.dart';
import '../services/mascota_service.dart';
import '../services/usuari_service.dart';
import '../styles/app_styles.dart';
import '../widgets/mascota_card.dart';
import 'fitxa_mascota_screen.dart';
import 'nova_mascota_screen.dart';

// A02 · Inici
class IniciScreen extends StatefulWidget {
  const IniciScreen({super.key});

  @override
  State<IniciScreen> createState() => _IniciScreenState();
}

class _IniciScreenState extends State<IniciScreen> {
  late final Future<Usuari?> _perfil;
  late final Stream<List<Mascota>> _mascotes;

  @override
  void initState() {
    super.initState();
    final uid = AuthService().usuariActual!.uid;
    _perfil = UsuariService().llegirPerfil(uid);
    _mascotes = MascotaService().llegirMascotes(uid);
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
            padding: const EdgeInsets.all(AppStyles.spaceM),
            child: FutureBuilder<Usuari?>(
              future: _perfil,
              builder: (context, snapshot) {
                final nom = snapshot.data?.nom;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BENVINGUT/DA DE NOU',
                      style: Theme.of(context).textTheme.labelMedium
                          ?.copyWith(letterSpacing: 1.2),
                    ),
                    Text(
                      nom == null ? 'Hola!' : 'Hola, $nom',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                );
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Mascota>>(
              stream: _mascotes,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return const Center(
                    child: Text("No s'han pogut carregar les mascotes"),
                  );
                }

                final mascotes = snapshot.data ?? [];

                // Estat buit
                if (mascotes.isEmpty) {
                  return Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(AppStyles.spaceL),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 56,
                            backgroundColor: AppStyles.primary.withValues(
                              alpha: 0.1,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(AppStyles.spaceM),
                              child: Image.asset('assets/images/logo.png'),
                            ),
                          ),
                          const SizedBox(height: AppStyles.spaceL),
                          Text(
                            'Encara no tens cap mascota',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: AppStyles.spaceS),
                          const Text(
                            'Afegeix la primera i comença a portar-ne la cartilla de salut',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppStyles.spaceL),
                          FilledButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const NovaMascotaScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.add),
                            label: const Text('Afegeix la primera mascota'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Llista de mascotes + botó per afegir-ne més
                return Stack(
                  children: [
                    ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        AppStyles.spaceM,
                        AppStyles.spaceM,
                        AppStyles.spaceM,
                        96, // espai perquè el botó no tapi l'última targeta
                      ),
                      itemCount: mascotes.length,
                      itemBuilder: (context, i) {
                        final mascota = mascotes[i];
                        return MascotaCard(
                          mascota: mascota,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    FitxaMascotaScreen(mascotaId: mascota.id),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    Positioned(
                      right: AppStyles.spaceM,
                      bottom: AppStyles.spaceM,
                      child: FloatingActionButton.extended(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NovaMascotaScreen(),
                            ),
                          );
                        },
                        backgroundColor: AppStyles.primary,
                        foregroundColor: Colors.white,
                        icon: const Icon(Icons.add),
                        label: const Text('Afegir mascota'),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
