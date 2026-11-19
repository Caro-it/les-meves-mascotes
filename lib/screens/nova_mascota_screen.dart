import 'package:flutter/material.dart';

import '../models/mascota.dart';
import '../services/auth_service.dart';
import '../services/mascota_service.dart';
import '../styles/app_styles.dart';

// A03 · Nova mascota
class NovaMascotaScreen extends StatefulWidget {
  const NovaMascotaScreen({super.key, this.mascota});

  final Mascota? mascota; // null = nova · amb dades = editar

  @override
  State<NovaMascotaScreen> createState() => _NovaMascotaScreenState();
}

class _NovaMascotaScreenState extends State<NovaMascotaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _racaController = TextEditingController();
  final _pesController = TextEditingController();
  Especie _especie = Especie.gos;
  Sexe? _sexe;
  DateTime? _dataNaixement;
  bool _desant = false;

  @override
  void initState() {
    super.initState();
    final m = widget.mascota;
    if (m != null) {
      _nomController.text = m.nom;
      _racaController.text = m.raca ?? '';
      _pesController.text = m.pes?.toString() ?? '';
      _especie = m.especie;
      _sexe = m.sexe;
      _dataNaixement = m.dataNaixement;
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _racaController.dispose();
    _pesController.dispose();
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
    final original = widget.mascota; // null si és nova
    final mascota = Mascota(
      id: original?.id ?? '', // nova: l'id el posa Firestore
      nom: _nomController.text.trim(),
      especie: _especie,
      raca: _racaController.text.trim().isEmpty
          ? null
          : _racaController.text.trim(),
      sexe: _sexe,
      dataNaixement: _dataNaixement,
      // camps que encara no són al formulari: es conserven els de l'original
      pes: double.tryParse(_pesController.text.trim().replaceAll(',', '.')),
      numXip: original?.numXip,
      esterilitzat: original?.esterilitzat ?? false,
      dataEsterilitzacio: original?.dataEsterilitzacio,
      rutaFoto: original?.rutaFoto,
      color: original?.color ?? AppStyles.petColors.first.toARGB32(),
    );

    try {
      if (original == null) {
        await MascotaService().crearMascota(uid, mascota);
      } else {
        await MascotaService().actualitzarMascota(uid, mascota);
      }
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
      appBar: AppBar(
        title: Text(widget.mascota == null ? 'Nova mascota' : 'Editar mascota'),
      ),
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
              const SizedBox(height: AppStyles.spaceM),
              TextFormField(
                controller: _pesController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Pes (kg)',
                  hintText: 'ex: 4,5',
                ),
                validator: (valor) {
                  final text = valor?.trim() ?? '';
                  if (text.isEmpty) return null; // és opcional
                  final pes = double.tryParse(text.replaceAll(',', '.'));
                  if (pes == null || pes <= 0 || pes > 150) {
                    return 'Escriu un pes vàlid en kg';
                  }
                  return null;
                },
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
