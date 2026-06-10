import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Import nécessaire
import 'questionnaire_med.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Neuro Consult CHRU',
      debugShowCheckedModeBanner: false,
      // --- CONFIGURATION FRANÇAIS ---
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('fr', 'FR'), // Français
      ],
      locale: const Locale('fr', 'FR'), // Force la langue en français
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const QuestionnairePatient(),
    );
  }
}