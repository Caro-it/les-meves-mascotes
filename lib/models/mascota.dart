import 'package:cloud_firestore/cloud_firestore.dart';

enum Especie { gos, gat, altres }

enum Sexe { mascle, femella }

class Mascota {
  final String id;
  final String nom;
  final Especie especie;
  final String? raca;
  final Sexe? sexe;
  final DateTime? dataNaixement;
  final double? pes; // kg
  final String? numXip; // 15 xifres
  final bool esterilitzat;
  final DateTime? dataEsterilitzacio;
  final String? rutaFoto; // fitxer al mòbil
  final int color; // un dels colors d'AppStyles.petColors

  const Mascota({
    required this.id,
    required this.nom,
    required this.especie,
    this.raca,
    this.sexe,
    this.dataNaixement,
    this.pes,
    this.numXip,
    this.esterilitzat = false,
    this.dataEsterilitzacio,
    this.rutaFoto,
    required this.color,
  });

  // Firestore -> objecte Mascota
  factory Mascota.fromFirestore(String id, Map<String, dynamic> data) {
    return Mascota(
      id: id,
      nom: data['nom'] as String,
      especie: Especie.values.byName(data['especie'] as String),
      raca: data['raca'] as String?,
      sexe: data['sexe'] == null
          ? null
          : Sexe.values.byName(data['sexe'] as String),
      dataNaixement: (data['dataNaixement'] as Timestamp?)?.toDate(),
      pes: (data['pes'] as num?)?.toDouble(),
      numXip: data['numXip'] as String?,
      esterilitzat: data['esterilitzat'] as bool? ?? false,
      dataEsterilitzacio: (data['dataEsterilitzacio'] as Timestamp?)?.toDate(),
      rutaFoto: data['rutaFoto'] as String?,
      color: data['color'] as int,
    );
  }

  // Objecte Mascota -> Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'nom': nom,
      'especie': especie.name,
      'raca': raca,
      'sexe': sexe?.name,
      'dataNaixement':
          dataNaixement != null ? Timestamp.fromDate(dataNaixement!) : null,
      'pes': pes,
      'numXip': numXip,
      'esterilitzat': esterilitzat,
      'dataEsterilitzacio': dataEsterilitzacio != null
          ? Timestamp.fromDate(dataEsterilitzacio!)
          : null,
      'rutaFoto': rutaFoto,
      'color': color,
    };
  }
}