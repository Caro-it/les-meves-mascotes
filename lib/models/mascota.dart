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
      'dataNaixement': dataNaixement != null
          ? Timestamp.fromDate(dataNaixement!)
          : null,
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

// Text segons el sexe: «Esterilitzat», «Esterilitzada» o «Esterilitzat/da»
String textEsterilitzat(Sexe? sexe) => switch (sexe) {
  Sexe.mascle => 'Esterilitzat',
  Sexe.femella => 'Esterilitzada',
  null => 'Esterilitzat/da',
};

// Text de l'espècie en català
String textEspecie(Especie especie) => switch (especie) {
  Especie.gos => 'Gos',
  Especie.gat => 'Gat',
  Especie.altres => 'Altres',
};

// Edat en anys i mesos, p. ex. «2 anys i 3 mesos»
String textEdat(DateTime naixement) {
  final avui = DateTime.now();
  var mesos = (avui.year - naixement.year) * 12 + avui.month - naixement.month;
  if (avui.day < naixement.day) mesos--; // encara no ha fet el mes
  final anys = mesos ~/ 12;
  final resta = mesos % 12;

  if (anys == 0 && resta == 0) return "Menys d'un mes";
  final textAnys = anys == 0 ? '' : '$anys ${anys == 1 ? 'any' : 'anys'}';
  final textMesos = resta == 0 ? '' : '$resta ${resta == 1 ? 'mes' : 'mesos'}';
  if (textAnys.isEmpty) return textMesos;
  if (textMesos.isEmpty) return textAnys;
  return '$textAnys i $textMesos';
}
