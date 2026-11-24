import 'package:flutter/material.dart';

import '../models/registre.dart';
import '../services/auth_service.dart';
import '../services/registre_service.dart';
import '../styles/app_styles.dart';
import '../widgets/camp_targeta.dart';

// A06 · Nou registre
class NouRegistreScreen extends StatefulWidget {
  const NouRegistreScreen({super.key, required this.mascotaId, this.registre});

  final String mascotaId;
  final Registre? registre; // null = nou
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
  void initState() {
    super.initState();
    final r = widget.registre;
    if (r != null) {
      _tipus = r.tipus;
      _nomController.text = r.nom;
      _dataAplicada = r.dataAplicada;
      _properaDosi = r.properaDosi;
      _clinicaController.text = r.clinica ?? '';
      _notesController.text = r.notes ?? '';
    }
  }

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
    final original = widget.registre;
    final registre = Registre(
      id: original?.id ?? '', // nou: l'id el posa Firestore
      mascotaId: widget.mascotaId,
      tipus: _tipus,
      nom: _nomController.text.trim(),
      dataAplicada: _dataAplicada,
      properaDosi: _properaDosi,
      clinica: _textOpcional(_clinicaController),
      avisar: original?.avisar ?? false,
      notes: _textOpcional(_notesController),
    );

    try {
      if (original == null) {
        await RegistreService().crearRegistre(uid, registre);
      } else {
        await RegistreService().actualitzarRegistre(uid, registre);
      }
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

  Future<void> _esborrar() async {
    final confirmat = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Esborrar registre?'),
        content: Text(
          'Segur que vols esborrar «${widget.registre!.nom}»? '
          'No es pot desfer.',
        ),
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
      await RegistreService().esborrarRegistre(uid, widget.registre!);
      if (!mounted) return;
      Navigator.pop(context); // torna a l'historial
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("No s'ha pogut esborrar el registre")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.registre == null ? 'Nou registre' : 'Editar registre',
        ),
        actions: [
          if (widget.registre != null)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Esborrar registre',
              onPressed: _esborrar,
            ),
        ],
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(AppStyles.spaceM),
            children: [
              CampTargeta(
                icona: Icons.category_outlined,
                titol: 'Tipus',
                nota: 'Obligatori',
                child: SegmentedButton<TipusRegistre>(
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
              ),
              CampTargeta(
                icona: Icons.vaccines_outlined,
                titol: 'Nom del producte o tractament',
                nota: 'Obligatori',
                child: TextFormField(
                  controller: _nomController,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'ex: Polivalent, NexGard, Milbemax…',
                  ),
                  validator: (valor) => (valor == null || valor.trim().isEmpty)
                      ? 'Escriu el nom de la vacuna o el producte'
                      : null,
                ),
              ),
              CampTargeta(
                icona: Icons.calendar_today_outlined,
                titol: "Data d'aplicació",
                nota: 'Obligatori',
                child: InkWell(
                  onTap: _triarDataAplicada,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(_data(_dataAplicada)),
                  ),
                ),
              ),
              CampTargeta(
                icona: Icons.event_repeat,
                titol: 'Propera dosi prevista',
                nota: 'Recomanat',
                child: InkWell(
                  onTap: _triarProperaDosi,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      suffixIcon: Icon(Icons.event),
                    ),
                    child: Text(
                      _properaDosi == null ? 'DD/MM/AAAA' : _data(_properaDosi),
                    ),
                  ),
                ),
              ),
              CampTargeta(
                icona: Icons.local_hospital_outlined,
                titol: 'Veterinari o centre',
                nota: 'Opcional',
                child: TextFormField(
                  controller: _clinicaController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    hintText: 'ex: Clínica veterinària de Flix',
                  ),
                ),
              ),
              CampTargeta(
                icona: Icons.notes,
                titol: 'Notes i observacions',
                nota: 'Opcional',
                child: TextFormField(
                  controller: _notesController,
                  textCapitalization: TextCapitalization.sentences,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    hintText: 'ex: Reaccions lleus, lot de la vacuna…',
                  ),
                ),
              ),
              const SizedBox(height: AppStyles.spaceS),
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
