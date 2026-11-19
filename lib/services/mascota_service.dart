import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/mascota.dart';

class MascotaService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Col·lecció de mascotes d'un usuari: usuaris/{uid}/mascotes
  CollectionReference<Map<String, dynamic>> _mascotes(String uid) {
    return _db.collection('usuaris').doc(uid).collection('mascotes');
  }

  // B06 · Llegeix les mascotes de l'usuari i avisa de cada canvi
  Stream<List<Mascota>> llegirMascotes(String uid) {
    return _mascotes(uid)
        .orderBy('nom')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Mascota.fromFirestore(doc.id, doc.data()))
              .toList(),
        );
  }

  // B07 · Crea una mascota nova i retorna l'id que li dona Firestore
  Future<String> crearMascota(String uid, Mascota mascota) async {
    final doc = await _mascotes(uid).add(mascota.toFirestore());
    return doc.id;
  }

  // B08 · Actualitza les dades d'una mascota que ja existeix
  Future<void> actualitzarMascota(String uid, Mascota mascota) {
    return _mascotes(uid).doc(mascota.id).update(mascota.toFirestore());
  }

  // B09 · Esborra una mascota i tots els seus registres
  Future<void> esborrarMascota(String uid, String id) async {
    final mascota = _mascotes(uid).doc(id);
    final registres = await mascota.collection('registres').get();

    final batch = _db.batch();
    for (final registre in registres.docs) {
      batch.delete(registre.reference);
    }
    batch.delete(mascota);
    await batch.commit();
  }

  // Llegeix una sola mascota i avisa de cada canvi (per a la fitxa A04)
  Stream<Mascota?> llegirMascota(String uid, String id) {
    return _mascotes(uid)
        .doc(id)
        .snapshots()
        .map(
          (doc) =>
              doc.exists ? Mascota.fromFirestore(doc.id, doc.data()!) : null,
        );
  }
}
