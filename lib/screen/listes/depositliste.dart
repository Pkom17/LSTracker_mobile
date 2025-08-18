import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Depositliste extends StatefulWidget {
  const Depositliste({super.key});

  @override
  State<Depositliste> createState() => _DepositlisteState();
}

class _DepositlisteState extends State<Depositliste> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Listes des échantillons déposés',
          style: GoogleFonts.lato(
            textStyle: Theme.of(context).textTheme.displayMedium,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontStyle: FontStyle.italic,
          ),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [Text("Echantillons déposés")],
      ),
    );
  }
}
