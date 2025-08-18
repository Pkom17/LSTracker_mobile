import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screen/laboratory/Retrieve_results/retrivedetailsautres.dart';
import '../screen/laboratory/Retrieve_results/retrivedetailsbi.dart';
import '../screen/laboratory/Retrieve_results/retrivedetailsbs.dart';
import '../screen/laboratory/Retrieve_results/retrivedetailscv.dart';
import '../screen/laboratory/Retrieve_results/retrivedetailshpv.dart';
import '../screen/laboratory/Retrieve_results/retrivedetailstb.dart';

class RetriveresultDetails extends StatelessWidget {
  const RetriveresultDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          "Récupérer Résultats",
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
          Padding(padding: EdgeInsets.all(10)),
          Expanded(
            child: ListView(
              children: [
                Retrivedetailscv(),
                Retrivedetailsbs(),
                Retrivedetailsbi(),
                Retrivedetailstb(),
                Retrivedetailshpv(),
                RetrivedetailsAutres(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
