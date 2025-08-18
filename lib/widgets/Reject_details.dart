import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screen/items_convoyeurs/Reject_Items/RejectDetailsautres.dart';
import '../screen/items_convoyeurs/Reject_Items/RejectDetailsbi.dart';
import '../screen/items_convoyeurs/Reject_Items/RejectDetailsbs.dart';
import '../screen/items_convoyeurs/Reject_Items/RejectDetailscv.dart';
import '../screen/items_convoyeurs/Reject_Items/RejectDetailshpv.dart';
import '../screen/items_convoyeurs/Reject_Items/RejectDetailstb.dart';

class RejectDetails extends StatelessWidget {
  const RejectDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          "Echantillons rejétés",
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
                Rejectdetailscv(),
                Rejectdetailsbi(),
                Rejectdetailsbs(),
                Rejectdetailstb(),
                Rejectdetailshpv(),
                Rejectdetailsautres(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
