import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screen/laboratory/acceptsample.dart';
import '../screen/convoyeur/reject.dart';
import '../screen/laboratory/break_activity.dart';
import '../screen/laboratory/receptsample.dart';
import '../screen/laboratory/retrieve.dart';

class Laboratoryaction extends StatelessWidget {
  const Laboratoryaction({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          "Menu laboratoire",
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
          Receptsample(),
          Acceptsample(),
          Reject(),
          Retrieve(),
          BreakActivity(),
        ],
      ),
    );
  }
}
