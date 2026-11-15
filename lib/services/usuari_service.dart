import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/usuari.dart';

class UsuariService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // B05 · Crea el perfil a usuaris/{uid}
  Future<void> crearPerfil(Usuari usuari) {
    return _db.collection('usuaris').doc(usuari.uid).set(usuari.toFirestore());
  }

  // B05 · Llegeix el perfil de usuaris/{uid} (null si no en té)
  Future<Usuari?> llegirPerfil(String uid) async {
    final doc = await _db.collection('usuaris').doc(uid).get();
    if (!doc.exists) return null;
    return Usuari.fromFirestore(doc.id, doc.data()!);
  }
}
