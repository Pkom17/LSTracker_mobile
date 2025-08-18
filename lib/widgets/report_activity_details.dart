import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../screen/items_convoyeurs/Activity_report_items/report_bi.dart';
import '../screen/items_convoyeurs/Activity_report_items/report_bs.dart';
import '../screen/items_convoyeurs/Activity_report_items/report_cv.dart';
import '../screen/items_convoyeurs/Activity_report_items/report_eid.dart';
import '../screen/items_convoyeurs/Activity_report_items/report_hpv.dart';
import '../screen/items_convoyeurs/Activity_report_items/report_tb.dart';

class ReportActivityDetails extends StatefulWidget {
  const ReportActivityDetails({super.key});

  @override
  State<ReportActivityDetails> createState() => _ReportActivityDetailsState();
}

class _ReportActivityDetailsState extends State<ReportActivityDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        title: Text(
          "Bilan des activités de transports des échantillons",
          style: GoogleFonts.lato(
            textStyle: Theme.of(context).textTheme.displayMedium,
            fontSize: 16,
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
                ReportBi(),
                ReportBs(),
                ReportCv(),
                ReportEid(),
                ReportHpv(),
                ReportTb(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
