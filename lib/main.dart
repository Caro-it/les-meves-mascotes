import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/prova_auth_screen.dart';
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
      home: const ProvaAuthScreen(),
    );
  }
}
