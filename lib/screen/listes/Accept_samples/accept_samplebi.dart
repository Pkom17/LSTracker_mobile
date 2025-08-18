import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AcceptSamplebi extends StatefulWidget {
  const AcceptSamplebi({super.key});

  @override
  State<AcceptSamplebi> createState() => _AcceptSamplebiState();
}

class _AcceptSamplebiState extends State<AcceptSamplebi> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Accepter Echantillons BI',
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
              /*creer un script permettant de collecter des résultats aux laboratoires */
            },
            icon: Icon(Icons.more_vert_outlined),
            /*cette icone doit être activé lorsque un résultat est séléctionné pour être deposer */
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
          Text("Aucun échantillon BI à accepter")
          /*l'affichage doit comporter : 
          le site de demande, le type d'échantillon (CV, EID, BI, BS, TB, HPV)/ 
          type de prélèvement(Plasma, Dbs, prc, crachat), 
          le code patient, date de disponibilité des résultats  */
        ],
      ),
    );
  }
}
