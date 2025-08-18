import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Acceptsampleform extends StatefulWidget {
  const Acceptsampleform({super.key});

  @override
  State<Acceptsampleform> createState() => _AcceptsampleformState();
}

class _AcceptsampleformState extends State<Acceptsampleform> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Depot automatique',
          style: GoogleFonts.lato(
            textStyle: Theme.of(context).textTheme.displayMedium,
            fontSize: 25,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontStyle: FontStyle.italic,
          ),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Row(
            children: [
              Text("Deposer automatiquement les échantillons aux laboratoires")
            ],
          )
        ],
      ),
    );
  }
}
