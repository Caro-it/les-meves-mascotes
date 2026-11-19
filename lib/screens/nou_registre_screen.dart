import 'package:flutter/material.dart';

import '../models/registre.dart';
import '../services/auth_service.dart';
import '../services/registre_service.dart';
import '../styles/app_styles.dart';

// A06 · Nou registre
class NouRegistreScreen extends StatefulWidget {
  const NouRegistreScreen({super.key, required this.mascotaId});

  final String mascotaId;

  @override
  State<NouRegistreScreen> createState() => _NouRegistreScreenState();
}

class _NouRegistreScreenState extends State<NouRegistreScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _clinicaController = TextEditingController();
  final _notesController = TextEditingController();
  TipusRegistre _tipus = TipusRegistre.vacuna;
  DateTime _dataAplicada = DateUtils.dateOnly(DateTime.now());
  DateTime? _properaDosi;
  bool _desant = false;

  @override
  void dispose() {
    _nomController.dispose();
    _clinicaController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  String _data(DateTime? d) => d == null
      ? 'Toca per triar'
      : '${d.day.toString().padLeft(2, '0')}/'
            '${d.month.toString().padLeft(2, '0')}/${d.year}';

  String? _textOpcional(TextEditingController c) =>
      c.text.trim().isEmpty ? null : c.text.trim();

  Future<void> _triarDataAplicada() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataAplicada,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      helpText: "Data d'aplicació",
    );
    if (!mounted) return;
    if (data != null) setState(() => _dataAplicada = data);
  }

  Future<void> _triarProperaDosi() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _properaDosi ?? _dataAplicada.add(const Duration(days: 365)),
      firstDate: _dataAplicada,
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
      helpText: 'Propera dosi',
    );
    if (!mounted) return;
    if (data != null) setState(() => _properaDosi = data);
  }

  Future<void> _desar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _desant = true);

    final uid = AuthService().usuariActual!.uid;
    final registre = Registre(
      id: '', // l'id el posa Firestore
      mascotaId: widget.mascotaId,
      tipus: _tipus,
      nom: _nomController.text.trim(),
      dataAplicada: _dataAplicada,
      properaDosi: _properaDosi,
      clinica: _textOpcional(_clinicaController),
      notes: _textOpcional(_notesController),
    );

    try {
      await RegistreService().crearRegistre(uid, registre);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      setState(() => _desant = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No s'ha pogut desar el registre")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nou registre')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppStyles.spaceM),
            children: [
              Text('Tipus *', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: AppStyles.spaceS),
              SegmentedButton<TipusRegistre>(
                segments: const [
                  ButtonSegment(
                    value: TipusRegistre.vacuna,
                    label: Text('Vacuna'),
                  ),
                  ButtonSegment(
                    value: TipusRegistre.desparasitacioInterna,
                    label: Text('Desp. interna'),
                  ),
                  ButtonSegment(
                    value: TipusRegistre.desparasitacioExterna,
                    label: Text('Desp. externa'),
                  ),
                ],
                selected: {_tipus},
                onSelectionChanged: (seleccio) =>
                    setState(() => _tipus = seleccio.first),
              ),
              const SizedBox(height: AppStyles.spaceM),
              TextFormField(
                controller: _nomController,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Nom *',
                  hintText: 'ex: Ràbia, Polivalent, Pipeta…',
                ),
                validator: (valor) => (valor == null || valor.trim().isEmpty)
                    ? 'Escriu el nom de la vacuna o el producte'
                    : null,
              ),
              const SizedBox(height: AppStyles.spaceM),
              InkWell(
                onTap: _triarDataAplicada,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: "Data d'aplicació *",
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(_data(_dataAplicada)),
                ),
              ),
              const SizedBox(height: AppStyles.spaceM),
              InkWell(
                onTap: _triarProperaDosi,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Propera dosi',
                    suffixIcon: Icon(Icons.event),
                  ),
                  child: Text(_data(_properaDosi)),
                ),
              ),
              const SizedBox(height: AppStyles.spaceM),
              TextFormField(
                controller: _clinicaController,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(labelText: 'Clínica'),
              ),
              const SizedBox(height: AppStyles.spaceM),
              TextFormField(
                controller: _notesController,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Notes'),
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
