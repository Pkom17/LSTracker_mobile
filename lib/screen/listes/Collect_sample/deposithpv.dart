import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Deposithpv extends StatefulWidget {
  const Deposithpv({super.key});

  @override
  State<Deposithpv> createState() => _DeposithpvState();
}

class _DeposithpvState extends State<Deposithpv> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Listes des échantillons HPV à déposer',
          style: GoogleFonts.lato(
            textStyle: Theme.of(context).textTheme.displayMedium,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontStyle: FontStyle.italic,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              /*creer un script permettant de deposer les échantillons aux laboratoires */
            },
            icon: Icon(Icons.more_vert_outlined),
            /*cette icone doit être activé lorsque un échantillon est séléctionné pour être deposer */
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
          Text("Echantillons HPV à déposer")
        ],
      ),
    );
  }
}
