import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'connexion.dart';
import 'inscription.dart';
import 'package:intl/date_symbol_data_local.dart'; 

void main() async {
  await initializeDateFormatting('fr_FR', null);
  runApp(Menu());
}

class Menu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Connexion',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
         Locale('fr', 'FR'), 
      ],
      initialRoute: '/',
      routes: {
        '/': (context) => ConnexionPage(),
        '/inscription': (context) => InscriptionPage(),
      },
    );
  }
}

 