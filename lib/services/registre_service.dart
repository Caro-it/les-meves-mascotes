import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/registre.dart';

class RegistreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Registres d'una mascota: usuaris/{uid}/mascotes/{mascotaId}/registres
  CollectionReference<Map<String, dynamic>> _registres(
    String uid,
    String mascotaId,
  ) {
    return _db
        .collection('usuaris')
        .doc(uid)
        .collection('mascotes')
        .doc(mascotaId)
        .collection('registres');
  }

  // Llegeix els registres d'una mascota, del més recent al més antic
  Stream<List<Registre>> llegirRegistres(String uid, String mascotaId) {
    return _registres(uid, mascotaId)
        .orderBy('dataAplicada', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Registre.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  // Crea un registre nou
  Future<String> crearRegistre(String uid, Registre registre) async {
    final doc = await _registres(
      uid,
      registre.mascotaId,
    ).add(registre.toFirestore());
    return doc.id;
  }
}
