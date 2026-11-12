import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/prova_auth_screen.dart';
import 'styles/app_styles.dart';

import 'package:firebase_auth/firebase_auth.dart';

import 'screens/inici_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const LesMevesMascotesApp());
}

class LesMevesMascotesApp extends StatelessWidget {
  const LesMevesMascotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Les meves mascotes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: AppStyles.primary),
        fontFamily: AppStyles.fontText,
        textTheme: const TextTheme(
          displayLarge: AppStyles.titol,
          displayMedium: AppStyles.titol,
          displaySmall: AppStyles.titol,
          headlineLarge: AppStyles.titol,
          headlineMedium: AppStyles.titol,
          headlineSmall: AppStyles.titol,
          titleLarge: AppStyles.titol,
          labelLarge: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      home: StreamBuilder<User?>(
        stream: AuthService().canvisSessio,
        builder: (context, snapshot) {
          // Mentre Firebase comprova si hi ha sessió guardada
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          // Hi ha usuari → A02 Inici
          if (snapshot.hasData) {
            return const IniciScreen();
          }
          // No hi ha usuari → pantalla d'entrar (de moment, la de prova)
          return const ProvaAuthScreen();
        },
      ),
    );
  }
}
