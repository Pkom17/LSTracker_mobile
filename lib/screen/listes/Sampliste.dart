import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Sampliste extends StatefulWidget {
  const Sampliste({super.key});

  @override
  State<Sampliste> createState() => _SamplisteState();
}

class _SamplisteState extends State<Sampliste> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Listes des échantillons reçues',
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
        children: [Text("Echantillons reçues aux laboratoires")],
      ),
    );
  }
}
