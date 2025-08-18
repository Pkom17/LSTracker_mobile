import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../formulaires/acceptsampleform.dart';

class SubmitBs extends StatefulWidget {
  const SubmitBs({super.key});

  @override
  State<SubmitBs> createState() => _SubmitBsState();
}

class _SubmitBsState extends State<SubmitBs> {
  final List<String> contents = ['Déposer résultats'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Listes des résultats BS à deposer',
          style: GoogleFonts.lato(
            textStyle: Theme.of(context).textTheme.displayMedium,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontStyle: FontStyle.italic,
          ),
        ),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return contents
                  .map((e) => PopupMenuItem<String>(value: e, child: Text(e)))
                  .toList();
            },
            onSelected: (value) {
              if (value == 'Récuperer') {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Acceptsampleform()));
              }
            },
          ),
          // IconButton(
          //   onPressed: () {
          //     /*creer un script permettant de deposer des résultats aux laboratoires */
          //   },
          //   icon: Icon(Icons.more_vert_outlined),
          //   /*cette icone doit être activé lorsque un résultat est séléctionné pour être deposer */
          // ),
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
          Text("Resultats BS à deposer pas disponibles")
          /*l'affichage doit comporter : 
          le site de demande, le type d'échantillon (CV, EID, BI, BS, TB, HPV)/ 
          type de prélèvement(Plasma, Dbs, prc, crachat), 
          le code patient, date de disponibilité des résultats */
        ],
      ),
    );
  }
}
