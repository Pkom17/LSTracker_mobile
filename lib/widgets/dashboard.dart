import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screen/dashboard/availableresult.dart';
import '../screen/dashboard/collectionresults.dart';
import '../screen/dashboard/onsiteresults.dart';
import '../screen/dashboard/sampleanalyze.dart';
import '../screen/dashboard/sampledeposit.dart';
import '../screen/dashboard/samplereject.dart';
import '../screen/dashboard/sampletransit.dart';

class DashboardView extends StatelessWidget {
  const DashboardView({super.key});
  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 216, 218, 219),
      child: GridView(
        scrollDirection: Axis.vertical,
        padding: EdgeInsets.all(10),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 3 / 2,
          crossAxisSpacing: 5,
          mainAxisSpacing: 5,
        ),
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                color: const Color.fromARGB(136, 24, 23, 23),
                child: Text(
                  'Tableau de board',
                  style: GoogleFonts.lato(
                    textStyle: Theme.of(context).textTheme.bodyLarge,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Sampletransit(),
          SampleDeposit(),
          Sampleanalyze(),
          Availableresult(),
          Collectionresults(),
          Onsiteresults(),
          Samplereject(),
        ],
      ),
    );
  }
}
