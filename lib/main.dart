import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/inici_screen.dart';
import 'screens/inici_sessio_screen.dart';
import 'services/auth_service.dart';
import 'styles/app_styles.dart';

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppStyles.primary,
          primary: AppStyles.primary,
        ),
        scaffoldBackgroundColor: AppStyles.fons,
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppStyles.radius),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppStyles.radius),
            borderSide: const BorderSide(color: AppStyles.primary, width: 1.5),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(52)),
        ),
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
          return const IniciSessioScreen();
        },
      ),
    );
  }
}
