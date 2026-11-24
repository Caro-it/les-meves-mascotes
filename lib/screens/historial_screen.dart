import 'package:flutter/material.dart';

import '../models/registre.dart';
import '../services/auth_service.dart';
import '../services/registre_service.dart';
import '../styles/app_styles.dart';
import 'nou_registre_screen.dart';

// A05 · Historial de la mascota
class HistorialScreen extends StatefulWidget {
  const HistorialScreen({
    super.key,
    required this.mascotaId,
    required this.nomMascota,
  });

  final String mascotaId;
  final String nomMascota;

  @override
  State<HistorialScreen> createState() => _HistorialScreenState();
}

class _HistorialScreenState extends State<HistorialScreen> {
  late final Stream<List<Registre>> _registres;

  @override
  void initState() {
    super.initState();
    final uid = AuthService().usuariActual!.uid;
    _registres = RegistreService().llegirRegistres(uid, widget.mascotaId);
  }

  String _data(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/'
      '${d.month.toString().padLeft(2, '0')}/${d.year}';

  String _textTipus(TipusRegistre t) => switch (t) {
    TipusRegistre.vacuna => 'Vacuna',
    TipusRegistre.desparasitacioInterna => 'Desparasitació interna',
    TipusRegistre.desparasitacioExterna => 'Desparasitació externa',
  };

  // Etiqueta de color segons l'estat (null si no hi ha propera dosi)
  Widget? _etiquetaEstat(EstatRegistre? estat) {
    if (estat == null) return null;
    final (text, color) = switch (estat) {
      EstatRegistre.alDia => ('Al dia', AppStyles.ok),
      EstatRegistre.tocaAviat => ('Toca aviat', AppStyles.avis),
      EstatRegistre.vencut => ('Vençut', AppStyles.error),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppStyles.radius),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
  Widget _llista(List<Registre> registres, String textBuit) {
    if (registres.isEmpty) {
      return Center(child: Text(textBuit));
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 88), // no tapar amb el botó
      itemCount: registres.length,
      itemBuilder: (context, index) {
        final r = registres[index];
        final propera = r.properaDosi == null
            ? ''
            : '\nPropera dosi: ${_data(r.properaDosi!)}';
        return Card(
          child: ListTile(
            leading: Icon(
              r.tipus == TipusRegistre.vacuna
                  ? Icons.vaccines
                  : Icons.bug_report_outlined,
              color: AppStyles.primary,
            ),
            title: Text(r.nom),
            subtitle: Text(
              '${_textTipus(r.tipus)} · ${_data(r.dataAplicada)}$propera',
            ),
            isThreeLine: r.properaDosi != null,
            trailing: _etiquetaEstat(estatRegistre(r)),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Historial · ${widget.nomMascota}'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Vacunes'),
              Tab(text: 'Desparasitacions'),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    NouRegistreScreen(mascotaId: widget.mascotaId),
              ),
            );
          },
          backgroundColor: AppStyles.primary,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add),
          label: const Text('Afegir registre'),
        ),
        body: StreamBuilder<List<Registre>>(
          stream: _registres,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return const Center(
                child: Text("No s'ha pogut carregar l'historial"),
              );
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final tots = snapshot.data!;
            final vacunes = tots
                .where((r) => r.tipus == TipusRegistre.vacuna)
                .toList();
            final desparasitacions = tots
                .where((r) => r.tipus != TipusRegistre.vacuna)
                .toList();
            return TabBarView(
              children: [
                _llista(vacunes, 'Encara no hi ha vacunes'),
                _llista(desparasitacions, 'Encara no hi ha desparasitacions'),
              ],
            );
          },
        ),
      ),
    );
  }
}
