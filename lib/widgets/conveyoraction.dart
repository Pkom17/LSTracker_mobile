import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screen/convoyeur/bilancollect.dart';
import '../screen/convoyeur/collecte.dart';
import '../screen/convoyeur/collectresult.dart';
import '../screen/convoyeur/dataoffline.dart';
import '../screen/convoyeur/deposit.dart';
import '../screen/convoyeur/fileresult.dart';
import '../screen/convoyeur/listsamplecollect.dart';
import '../screen/convoyeur/reject.dart';

class ConvoyeurView extends StatelessWidget {
  const ConvoyeurView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          "Menu Convoyage",
          style: GoogleFonts.lato(
            textStyle: Theme.of(context).textTheme.displayMedium,
            fontSize: 25,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
      body: ListView(
        scrollDirection: Axis.vertical,
        children: [
          CollecteItem(),
          Deposit(),
          Dataoffline(),
          Listsamplecollect(),
          Collectresult(),
          Fileresult(),
          Reject(),
          Bilancollect(),
        ],
      ),
    );
  }
}
