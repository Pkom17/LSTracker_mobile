import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'screen/home.dart';

final theme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    brightness: Brightness.light,
    seedColor: Color.fromARGB(255, 52, 155, 240),
  ),
);

void main() {
  WidgetsFlutterBinding.ensureInitialized;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: [GlobalMaterialLocalizations.delegate],
      supportedLocales: [Locale('en'), Locale('fr')],
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: theme,
      home: HomeView(),
    );
  }
}
