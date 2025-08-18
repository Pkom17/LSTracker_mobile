import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ReportCvList extends StatefulWidget {
  const ReportCvList({super.key});

  @override
  State<ReportCvList> createState() => _ReportCvListState();
}

class _ReportCvListState extends State<ReportCvList> {
  var cvDate = null;
  var cvDateEnd = null;
  Future<Null> _selectionDate() async {
    DateTime? _dateChoisi = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2050));
    if (_dateChoisi != null) {
      setState(() {
        cvDate = _dateChoisi;
      });
    }
  }

  Future<Null> _selectionEnDate() async {
    DateTime? _datefin = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime(2050));
    if (_datefin != null) {
      setState(() {
        cvDateEnd = _datefin;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Bilan des échantillons CV transportés',
          style: GoogleFonts.lato(
            textStyle: Theme.of(context).textTheme.displayMedium,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontStyle: FontStyle.italic,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              /*creer un script permettant de deposer des résultats aux laboratoires */
            },
            icon: Icon(Icons.more_vert_outlined),
            /*cette icone doit être activé lorsque un résultat est séléctionné pour être deposer */
          ),
        ],
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _selectionDate,
                  label: Text(
                    cvDate == null
                        ? "Date de début"
                        : '${cvDate.day}/${cvDate.month}/${cvDate.year}',
                    style: cvDate == null
                        ? TextStyle(color: Colors.blue)
                        : TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 15),
                  ),
                ),
                SizedBox(
                  width: 120,
                ),
                Expanded(
                    child: Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _selectionEnDate,
                      label: Text(
                        cvDateEnd == null
                            ? "Date de fin"
                            : '${cvDateEnd.day}/${cvDateEnd.month}/${cvDateEnd.year}',
                        style: cvDateEnd == null
                            ? TextStyle(color: Colors.blue)
                            : TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 15),
                      ),
                    )
                  ],
                )),
              ],
            ),
            Text(
              "Aucun bilian de CV à Disponible",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            )
            /*l'affichage doit comporter : 
          le site de demande, le type d'échantillon (CV, EID, BI, BS, TB, HPV)/ 
          type de prélèvement(Plasma, Dbs, prc, crachat), 
          le code patient, en fonction des différents états   */
          ],
        ),
      ),
    );
  }
}
