import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Samplevalide extends StatefulWidget {
  const Samplevalide({super.key});

  @override
  State<Samplevalide> createState() => _SamplevalideState();
}

class _SamplevalideState extends State<Samplevalide> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Listes des échantillons acceptés',
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
        children: [Text("Echantillons acceptés aux laboratoires")],
      ),
    );
  }
}
