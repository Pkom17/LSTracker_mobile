import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../listes/samplevalide.dart';

/*Echantillons Analysés*/
class Sampleanalyze extends StatelessWidget {
  const Sampleanalyze({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Ink.image(
            image: AssetImage("assets/images/shutterstock.webp"),
            fit: BoxFit.cover,
            child: InkWell(
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => Samplevalide()));
              },
            ),
          ),
          Positioned(
            bottom: 5,
            right: 10,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              color: Colors.black54,
              child: Text(
                'Echantillons analysés',
                style: GoogleFonts.lato(
                  textStyle: Theme.of(context).textTheme.displayMedium,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ),
          Positioned(
            top: 10,
            left: 10,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 5,
              ),
              color: Colors.black54,
              child: Text(
                '25',
                /*Nombre d'échantillon collectés apres avoir cliquer sur sauvegarder*/
                style: TextStyle(fontSize: 15, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
