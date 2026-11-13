import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../styles/app_styles.dart';

// PANTALLA PROVISIONAL: només per provar AuthService. S'esborrarà.
class ProvaAuthScreen extends StatefulWidget {
  const ProvaAuthScreen({super.key});

  @override
  State<ProvaAuthScreen> createState() => _ProvaAuthScreenState();
}

class _ProvaAuthScreenState extends State<ProvaAuthScreen> {
  final _auth = AuthService();
  final _correu = TextEditingController();
  final _contrasenya = TextEditingController();
  String _missatge = '';

  Future<void> _executa(Future<void> Function() accio, String ok) async {
    try {
      await accio();
      setState(() => _missatge = ok);
    } on FirebaseAuthException catch (e) {
      setState(() => _missatge = '${AuthService.missatgeError(e)} (${e.code})');
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuari = _auth.usuariActual;
    return Scaffold(
      appBar: AppBar(title: const Text('Prova AuthService')),
      body: Padding(
        padding: const EdgeInsets.all(AppStyles.spaceM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              usuari == null
                  ? 'Sense sessió'
                  : 'Sessió iniciada: ${usuari.email}',
            ),
            const SizedBox(height: AppStyles.spaceM),
            TextField(
              controller: _correu,
              decoration: const InputDecoration(labelText: 'Correu'),
            ),
            TextField(
              controller: _contrasenya,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contrasenya'),
            ),
            const SizedBox(height: AppStyles.spaceM),
            FilledButton(
              onPressed: () => _executa(
                () => _auth.crearCompte(
                  correu: _correu.text.trim(),
                  contrasenya: _contrasenya.text,
                ),
                'Compte creat',
              ),
              child: const Text('Crear compte'),
            ),
            OutlinedButton(
              onPressed: () => _executa(
                () => _auth.iniciarSessio(
                  correu: _correu.text.trim(),
                  contrasenya: _contrasenya.text,
                ),
                'Sessió iniciada',
              ),
              child: const Text('Entrar'),
            ),
            TextButton(
              onPressed: () => _executa(_auth.tancarSessio, 'Sessió tancada'),
              child: const Text('Sortir'),
            ),
            const SizedBox(height: AppStyles.spaceM),
            Text(_missatge),
          ],
        ),
      ),
    );
  }
}
