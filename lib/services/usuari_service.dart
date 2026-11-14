import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/usuari.dart';

class UsuariService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // B05 · Crea el perfil a usuaris/{uid}
  Future<void> crearPerfil(Usuari usuari) {
    return _db.collection('usuaris').doc(usuari.uid).set(usuari.toFirestore());
  }
}