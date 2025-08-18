import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Availableresults extends StatefulWidget {
  const Availableresults({super.key});

  @override
  State<Availableresults> createState() => _AvailableresultsState();
}

class _AvailableresultsState extends State<Availableresults> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Listes des résultats disponibles',
          style: GoogleFonts.lato(
            textStyle: Theme.of(context).textTheme.displayMedium,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontStyle: FontStyle.italic,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_vert_outlined),
          ),
        ],
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Padding(padding: EdgeInsets.all(5)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            margin: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
                color: Colors.grey, borderRadius: BorderRadius.circular(10)),
            child: TextFormField(
              decoration: InputDecoration(
                  icon: Icon(Icons.search),
                  hintText: "Recherche",
                  border: InputBorder.none),
            ),
          ),
          Text("Résultats Disponibles")
        ],
      ),
    );
  }
}
