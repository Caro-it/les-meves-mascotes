import 'package:flutter/material.dart';

import '../models/mascota.dart';
import '../services/auth_service.dart';
import '../services/mascota_service.dart';
import '../styles/app_styles.dart';

// A03 · Nova mascota
class NovaMascotaScreen extends StatefulWidget {
  const NovaMascotaScreen({super.key});

  @override
  State<NovaMascotaScreen> createState() => _NovaMascotaScreenState();
}

class _NovaMascotaScreenState extends State<NovaMascotaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _racaController = TextEditingController();
  Especie _especie = Especie.gos;
  bool _desant = false;

  @override
  void dispose() {
    _nomController.dispose();
    _racaController.dispose();
    super.dispose();
  }

  Future<void> _desar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _desant = true);

    final uid = AuthService().usuariActual!.uid;
    final mascota = Mascota(
      id: '', // l'id el posa Firestore
      nom: _nomController.text.trim(),
      especie: _especie,
      raca: _racaController.text.trim().isEmpty
          ? null
          : _racaController.text.trim(),
      color: AppStyles.petColors.first.toARGB32(),
    );

    try {
      await MascotaService().crearMascota(uid, mascota);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _desant = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No s'ha pogut desar la mascota")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nova mascota')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppStyles.spaceM),
            children: [
              TextFormField(
                controller: _nomController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nom *',
                  hintText: 'ex: Lluna, Thor, Boira…',
                ),
                validator: (valor) => (valor == null || valor.trim().isEmpty)
                    ? 'Escriu el nom de la mascota'
                    : null,
              ),
              const SizedBox(height: AppStyles.spaceL),
              Text('Espècie *', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppStyles.spaceS),
              SegmentedButton<Especie>(
                segments: const [
                  ButtonSegment(value: Especie.gos, label: Text('Gos')),
                  ButtonSegment(value: Especie.gat, label: Text('Gat')),
                  ButtonSegment(value: Especie.altres, label: Text('Altres')),
                ],
                selected: {_especie},
                onSelectionChanged: (seleccio) =>
                    setState(() => _especie = seleccio.first),
              ),
              const SizedBox(height: AppStyles.spaceM),
              TextFormField(
                controller: _racaController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Raça',
                  hintText: 'ex: Golden Retriever, Comú europeu…',
                ),
              ),
              const SizedBox(height: AppStyles.spaceXL),
              FilledButton.icon(
                onPressed: _desant ? null : _desar,
                icon: const Icon(Icons.check),
                label: Text(_desant ? 'Desant…' : 'Desar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
