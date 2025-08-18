import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screen/items_convoyeurs/Collect_Items/ResultDetailstb.dart';
import '../screen/items_convoyeurs/Collect_Items/ResultatDetailsbs.dart';
import '../screen/items_convoyeurs/Collect_Items/ResultatsDetailshpv.dart';
import '../screen/items_convoyeurs/disponibility_items/resultdetailsbi.dart';
import '../screen/items_convoyeurs/disponibility_items/resultdetailscv.dart';

class DisponibiltyresultDetails extends StatelessWidget {
  const DisponibiltyresultDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          "Disponibilités des résultats",
          style: GoogleFonts.lato(
            textStyle: Theme.of(context).textTheme.displayMedium,
            fontSize: 25,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
          ),
          Expanded(
            child: ListView(
              children: [
                Resultdetailscv(),
                Resultdetailsbi(),
                Resultatdetailsbs(),
                Resultatsdetailshpv(),
                Resultdetailstb()
              ],
            ),
          ),
        ],
      ),
    );
  }
}
