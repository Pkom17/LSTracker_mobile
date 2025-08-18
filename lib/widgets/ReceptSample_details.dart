import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screen/laboratory/Recept_sample/ReceptDetailstautres.dart';
import '../screen/laboratory/Recept_sample/ReceptDetailsbs.dart';
import '../screen/laboratory/Recept_sample/ReceptDetailshpv.dart';
import '../screen/laboratory/Recept_sample/ReceptDetailstb.dart';
import '../screen/laboratory/Recept_sample/ReceptDetailscv.dart';
import '../screen/laboratory/Recept_sample/ReceptDeatilsbi.dart';

class ReceptsampleDetails extends StatelessWidget {
  const ReceptsampleDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          "Réceptionner Echantillons",
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
                Receptdetailscv(),
                Receptdeatilsbi(),
                Receptdetailsbs(),
                Receptdetailstb(),
                Receptdetailshpv(),
                Receptdetailstautres()
              ],
            ),
          ),
        ],
      ),
    );
  }
}
