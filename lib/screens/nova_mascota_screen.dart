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
  Sexe? _sexe;
  DateTime? _dataNaixement;
  bool _desant = false;

  @override
  void dispose() {
    _nomController.dispose();
    _racaController.dispose();
    super.dispose();
  }

 

  Future<void> _triarDataNaixement() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataNaixement ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: 'Data de naixement',
    );
    if (!mounted) return;
    if (data != null) setState(() => _dataNaixement = data);
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
      sexe: _sexe,
      dataNaixement: _dataNaixement,
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
              const SizedBox(height: AppStyles.spaceL),
              Text('Sexe', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppStyles.spaceS),
              SegmentedButton<Sexe>(
                segments: const [
                  ButtonSegment(value: Sexe.mascle, label: Text('Mascle')),
                  ButtonSegment(value: Sexe.femella, label: Text('Femella')),
                ],
                selected: _sexe == null ? <Sexe>{} : {_sexe!},
                emptySelectionAllowed: true,
                onSelectionChanged: (seleccio) => setState(
                  () => _sexe = seleccio.isEmpty ? null : seleccio.first,
                ),
              ),
              const SizedBox(height: AppStyles.spaceL),
              InkWell(
                onTap: _triarDataNaixement,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Data de naixement',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _dataNaixement == null
                        ? 'Toca per triar'
                        : '${_dataNaixement!.day.toString().padLeft(2, '0')}/'
                              '${_dataNaixement!.month.toString().padLeft(2, '0')}/'
                              '${_dataNaixement!.year}',
                  ),
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
