import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screen/items_convoyeurs/Deposit_items/Detailsautres.dart';
import '../screen/items_convoyeurs/Deposit_items/Detailshpv.dart';
import '../screen/items_convoyeurs/Deposit_items/Detailsbi.dart';
import '../screen/items_convoyeurs/Deposit_items/Detailsbs.dart';
import '../screen/items_convoyeurs/Deposit_items/Detailstb.dart';
import '../screen/items_convoyeurs/Deposit_items/collecteDetails.dart';

class ConvoyeurDetails extends StatelessWidget {
  const ConvoyeurDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          "Déposer des Echantillons",
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
                CollecteDtails(),
                Detailsbi(),
                Detailsbs(),
                Detailstb(),
                Detailshpv(),
                Detailsautres()
              ],
            ),
          ),
        ],
      ),
    );
  }
}
