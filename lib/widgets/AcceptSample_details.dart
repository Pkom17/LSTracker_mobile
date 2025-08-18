import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screen/laboratory/Accept_samples/acceptdetailsautres.dart';
import '../screen/laboratory/Accept_samples/acceptdetailsbi.dart';
import '../screen/laboratory/Accept_samples/acceptdetailsbs.dart';
import '../screen/laboratory/Accept_samples/acceptdetailscv.dart';
import '../screen/laboratory/Accept_samples/acceptdetailshpv.dart';
import '../screen/laboratory/Accept_samples/acceptdetailstb.dart';

class AcceptsampleDetails extends StatelessWidget {
  const AcceptsampleDetails({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          "Accepter Echantillons",
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
                Acceptdetailscv(),
                Acceptdetailsbi(),
                Acceptdetailsbs(),
                Acceptdetailstb(),
                Acceptdetailshpv(),
                Acceptdetailsautres()
              ],
            ),
          ),
        ],
      ),
    );
  }
}
