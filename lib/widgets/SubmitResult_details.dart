import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screen/items_convoyeurs/Submit_Items/SubmitDetailsbi.dart';
import '../screen/items_convoyeurs/Submit_Items/SubmitDetailsbs.dart';
import '../screen/items_convoyeurs/Submit_Items/SubmitDetailscv.dart';
import '../screen/items_convoyeurs/Submit_Items/SubmitDetailshpv.dart';
import '../screen/items_convoyeurs/Submit_Items/SubmitDetailstb.dart';

class SubmitresultDetails extends StatelessWidget {
  const SubmitresultDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          "Résultats à deposer",
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
                Submitdetailscv(),
                Submitdetailsbi(),
                Submitdetailsbs(),
                Submitdetailshpv(),
                Submitdetailstb()
              ],
            ),
          ),
        ],
      ),
    );
  }
}
