import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Resultdeposit extends StatefulWidget {
  const Resultdeposit({super.key});

  @override
  State<Resultdeposit> createState() => _ResultdepositState();
}

class _ResultdepositState extends State<Resultdeposit> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Listes des résultats à déposer',
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
          Text("Résultats à déposér")
        ],
      ),
    );
  }
}
