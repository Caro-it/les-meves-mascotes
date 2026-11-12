import 'package:cloud_firestore/cloud_firestore.dart';

enum TipusRegistre { vacuna, desparasitacioInterna, desparasitacioExterna }

class Registre {
  final String id;
  final String mascotaId;
  final TipusRegistre tipus;
  final String nom; // p. ex. "Ràbia", "Pipeta"
  final DateTime dataAplicada;
  final DateTime? properaDosi;
  final String? clinica;
  final String? notes;
  final bool avisar; // per a l'extra E01 (notificacions)

  const Registre({
    required this.id,
    required this.mascotaId,
    required this.tipus,
    required this.nom,
    required this.dataAplicada,
    this.properaDosi,
    this.clinica,
    this.notes,
    this.avisar = false,
  });

  factory Registre.fromFirestore(String id, Map<String, dynamic> data) {
    return Registre(
      id: id,
      mascotaId: data['mascotaId'] as String,
      tipus: TipusRegistre.values.byName(data['tipus'] as String),
      nom: data['nom'] as String,
      dataAplicada: (data['dataAplicada'] as Timestamp).toDate(),
      properaDosi: (data['properaDosi'] as Timestamp?)?.toDate(),
      clinica: data['clinica'] as String?,
      notes: data['notes'] as String?,
      avisar: data['avisar'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'mascotaId': mascotaId,
      'tipus': tipus.name,
      'nom': nom,
      'dataAplicada': Timestamp.fromDate(dataAplicada),
      'properaDosi': properaDosi != null
          ? Timestamp.fromDate(properaDosi!)
          : null,
      'clinica': clinica,
      'notes': notes,
      'avisar': avisar,
    };
  }
}
