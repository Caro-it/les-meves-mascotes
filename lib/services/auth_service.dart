import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // L'usuari que té la sessió iniciada ara mateix (o null si no n'hi ha cap)
  User? get usuariActual => _auth.currentUser;

  // Avisa cada vegada que algú entra o surt
  Stream<User?> get canvisSessio => _auth.authStateChanges();

  Future<User?> crearCompte({
    required String correu,
    required String contrasenya,
  }) async {
    final credencial = await _auth.createUserWithEmailAndPassword(
      email: correu,
      password: contrasenya,
    );
    return credencial.user;
  }

  Future<User?> iniciarSessio({
    required String correu,
    required String contrasenya,
  }) async {
    final credencial = await _auth.signInWithEmailAndPassword(
      email: correu,
      password: contrasenya,
    );
    return credencial.user;
  }

  Future<void> tancarSessio() => _auth.signOut();

  Future<void> recuperarContrasenya(String correu) =>
      _auth.sendPasswordResetEmail(email: correu);

  // Tradueix els codis d'error de Firebase a missatges en català
  static String missatgeError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'El correu no és vàlid.';
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'El correu o la contrasenya no són correctes.';
      case 'email-already-in-use':
        return 'Ja hi ha un compte amb aquest correu.';
      case 'weak-password':
        return 'La contrasenya ha de tenir almenys 6 caràcters.';
      case 'too-many-requests':
        return 'Massa intents. Torna-ho a provar d\'aquí a una estona.';
      case 'network-request-failed':
        return 'No hi ha connexió a internet.';
      default:
        return 'Hi ha hagut un error. Torna-ho a provar.';
    }
  }
}