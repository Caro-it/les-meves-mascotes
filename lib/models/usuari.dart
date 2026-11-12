import 'package:cloud_firestore/cloud_firestore.dart';

class Usuari {
  final String uid; // el dona Firebase Authentication
  final String nom;
  final String correu;
  final DateTime dataAlta;

  const Usuari({
    required this.uid,
    required this.nom,
    required this.correu,
    required this.dataAlta,
  });

  factory Usuari.fromFirestore(String uid, Map<String, dynamic> data) {
    return Usuari(
      uid: uid,
      nom: data['nom'] as String,
      correu: data['correu'] as String,
      dataAlta: (data['dataAlta'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'nom': nom,
      'correu': correu,
      'dataAlta': Timestamp.fromDate(dataAlta),
    };
  }
}
