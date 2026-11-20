import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

import '../models/mascota.dart';
import '../services/auth_service.dart';
import '../services/mascota_service.dart';
import '../styles/app_styles.dart';
import '../widgets/foto_mascota.dart';

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
  final _xipController = TextEditingController();
  Especie _especie = Especie.gos;
  Sexe? _sexe;
  DateTime? _dataNaixement;
  bool _esterilitzat = false;
  DateTime? _dataEsterilitzacio;
  String? _rutaFoto;
  bool _desant = false;

  @override
  void initState() {
    super.initState();
    final m = widget.mascota;
    if (m != null) {
      _nomController.text = m.nom;
      _racaController.text = m.raca ?? '';
      _pesController.text = m.pes?.toString() ?? '';
      _xipController.text = m.numXip ?? '';
      _especie = m.especie;
      _sexe = m.sexe;
      _dataNaixement = m.dataNaixement;
      _esterilitzat = m.esterilitzat;
      _dataEsterilitzacio = m.dataEsterilitzacio;
      _rutaFoto = m.rutaFoto;
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _racaController.dispose();
    _pesController.dispose();
    _xipController.dispose();
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

  Future<void> _triarDataEsterilitzacio() async {
    final data = await showDatePicker(
      context: context,
      initialDate: _dataEsterilitzacio ?? DateTime.now(),
      firstDate: _dataNaixement ?? DateTime(2000),
      lastDate: DateTime.now(),
      helpText: "Data d'esterilització",
    );
    if (!mounted) return;
    if (data != null) setState(() => _dataEsterilitzacio = data);
  }

  String _data(DateTime? d) => d == null
      ? 'Toca per triar'
      : '${d.day.toString().padLeft(2, '0')}/'
            '${d.month.toString().padLeft(2, '0')}/${d.year}';

  // Tria una foto de la galeria i, al mòbil, la copia a la carpeta de l'app
  Future<void> _triarFoto() async {
    final imatge = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024, // més petita: ocupa menys al mòbil
      imageQuality: 85,
    );
    if (imatge == null) return; // ha cancel·lat

    var ruta = imatge.path; // a Chrome és una adreça temporal (blob:)
    if (!kIsWeb) {
      final carpeta = await getApplicationDocumentsDirectory();
      final nom = 'mascota_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final copia = await File(imatge.path).copy('${carpeta.path}/$nom');
      ruta = copia.path;
    }
    if (!mounted) return;
    setState(() => _rutaFoto = ruta);
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
      pes: double.tryParse(_pesController.text.trim().replaceAll(',', '.')),
      numXip: _xipController.text.trim().isEmpty
          ? null
          : _xipController.text.trim(),
      esterilitzat: _esterilitzat,
      dataEsterilitzacio: _esterilitzat ? _dataEsterilitzacio : null,
      rutaFoto: _rutaFoto,
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
              // Foto: tocar-la per triar-ne una de la galeria
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _triarFoto,
                      child: FotoMascota(
                        rutaFoto: _rutaFoto,
                        color: Color(
                          widget.mascota?.color ??
                              AppStyles.petColors.first.toARGB32(),
                        ),
                        amplada: 120,
                        alcada: 120,
                        midaIcona: 48,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: _triarFoto,
                      icon: const Icon(Icons.photo_library_outlined),
                      label: Text(
                        _rutaFoto == null ? 'Afegir foto' : 'Canviar foto',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppStyles.spaceM),
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
              const SizedBox(height: AppStyles.spaceM),
              TextFormField(
                controller: _xipController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                maxLength: 15,
                decoration: const InputDecoration(
                  labelText: 'Número de xip',
                  hintText: '15 xifres',
                ),
                validator: (valor) {
                  final text = valor?.trim() ?? '';
                  if (text.isEmpty) return null; // és opcional
                  if (text.length != 15) return 'El xip ha de tenir 15 xifres';
                  return null;
                },
              ),
              const SizedBox(height: AppStyles.spaceS),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(textEsterilitzat(_sexe)),
                value: _esterilitzat,
                onChanged: (valor) => setState(() {
                  _esterilitzat = valor;
                  if (!valor) _dataEsterilitzacio = null;
                }),
              ),
              if (_esterilitzat)
                InkWell(
                  onTap: _triarDataEsterilitzacio,
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: "Data d'esterilització",
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    child: Text(_data(_dataEsterilitzacio)),
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
