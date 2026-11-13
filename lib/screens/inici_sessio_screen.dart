import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../styles/app_styles.dart';

// A01 · Inici de sessió / Crear compte
class IniciSessioScreen extends StatefulWidget {
  const IniciSessioScreen({super.key});

  @override
  State<IniciSessioScreen> createState() => _IniciSessioScreenState();
}

class _IniciSessioScreenState extends State<IniciSessioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correuCtrl = TextEditingController();
  final _contrasenyaCtrl = TextEditingController();
  bool _amagarContrasenya = true;
  bool _carregant = false;
  final _auth = AuthService();

  @override
  void dispose() {
    _correuCtrl.dispose();
    _contrasenyaCtrl.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _carregant = true);
    try {
      await _auth.iniciarSessio(
        correu: _correuCtrl.text.trim(),
        contrasenya: _contrasenyaCtrl.text,
      );
      // Si va bé, no cal fer res: la porta de main.dart ens porta a l'A02
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(AuthService.missatgeError(e))));
    } finally {
      if (mounted) setState(() => _carregant = false);
    }
  }

  Future<void> _recuperarContrasenya() async {
    final correu = _correuCtrl.text.trim();
    final missatger = ScaffoldMessenger.of(context);

    if (correu.isEmpty || !correu.contains('@')) {
      missatger.showSnackBar(
        const SnackBar(
          content: Text(
            'Escriu el teu correu a dalt i torna a tocar l\'enllaç.',
          ),
        ),
      );
      return;
    }

    try {
      await _auth.recuperarContrasenya(correu);
      missatger.showSnackBar(
        const SnackBar(
          content: Text(
            'Si hi ha un compte amb aquest correu, t\'hem enviat un enllaç.',
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      missatger.showSnackBar(
        SnackBar(content: Text(AuthService.missatgeError(e))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppStyles.spaceL),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset('assets/images/logo.png', height: 88),
                  const SizedBox(height: AppStyles.spaceM),
                  Text(
                    'Les meves mascotes',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppStyles.spaceXS),
                  const Text(
                    'La cartilla de salut digital per a les teves mascotes',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppStyles.ink),
                  ),
                  const SizedBox(height: AppStyles.spaceXL),
                  const Text(
                    'Correu electrònic',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppStyles.spaceS),
                  TextFormField(
                    controller: _correuCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'hola@exemple.cat',
                      prefixIcon: Icon(Icons.mail_outline),
                    ),
                    validator: (valor) {
                      final correu = valor?.trim() ?? '';
                      if (correu.isEmpty) return 'Escriu el teu correu';
                      if (!correu.contains('@')) return 'El correu no és vàlid';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppStyles.spaceM),
                  const Text(
                    'Contrasenya',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppStyles.spaceS),
                  TextFormField(
                    controller: _contrasenyaCtrl,
                    obscureText: _amagarContrasenya,
                    decoration: InputDecoration(
                      hintText: 'Escriu la contrasenya',
                      prefixIcon: const Icon(Icons.key_outlined),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _amagarContrasenya
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        tooltip: _amagarContrasenya
                            ? 'Mostrar la contrasenya'
                            : 'Amagar la contrasenya',
                        onPressed: () {
                          setState(() {
                            _amagarContrasenya = !_amagarContrasenya;
                          });
                        },
                      ),
                    ),
                    validator: (valor) {
                      if (valor == null || valor.isEmpty) {
                        return 'Escriu la contrasenya';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppStyles.spaceL),
                  FilledButton(
                    onPressed: _carregant ? null : _entrar,
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Entrar'),
                        SizedBox(width: AppStyles.spaceS),
                        Icon(Icons.arrow_forward),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppStyles.spaceM),
                  TextButton(
                    onPressed: _recuperarContrasenya,
                    child: const Text('Has oblidat la contrasenya?'),
                  ),
                  const SizedBox(height: AppStyles.spaceS),
                  const Text(
                    'Protegim les dades clíniques de les teves mascotes',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12, color: AppStyles.ink),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
