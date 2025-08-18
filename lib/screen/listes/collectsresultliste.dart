import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Collectsresultliste extends StatefulWidget {
  const Collectsresultliste({super.key});

  @override
  State<Collectsresultliste> createState() => _CollectsresultlisteState();
}

class _CollectsresultlisteState extends State<Collectsresultliste> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Listes des résultats collectés',
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
      body: Container(
        child: Column(
          children: [
            Padding(padding: EdgeInsets.all(5)),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              margin: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 241, 235, 235),
                  borderRadius: BorderRadius.circular(10)),
              child: TextFormField(
                decoration: InputDecoration(
                    icon: Icon(Icons.search),
                    hintText: "Recherche",
                    border: InputBorder.none),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text("Résultats collectés")],
            )
          ],
        ),
      ),
    );
  }
}
