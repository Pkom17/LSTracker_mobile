import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../widgets/laboratoryaction.dart';
import '../listes/Break/breakList.dart';

class Breakactivityform extends StatefulWidget {
  const Breakactivityform({super.key});

  @override
  State<Breakactivityform> createState() => _BreakactivityformState();
}

class _BreakactivityformState extends State<Breakactivityform> {
  final _formkey = GlobalKey<FormState>();
  final _collectionDateTimeController = TextEditingController();
  clear() async {
    _collectionDateTimeController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Enregistrement des ruptures",
          style: GoogleFonts.lato(
            textStyle: Theme.of(context).textTheme.displayMedium,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontStyle: FontStyle.italic,
          ),
        ),
        backgroundColor: Colors.green,
      ),
      body: Container(
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 207, 232, 235),
              const Color.fromARGB(244, 232, 227, 227),
              const Color.fromARGB(255, 226, 230, 226),
              Colors.blueGrey,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage("assets/images/mshp.jpg"),
              radius: 30,
            ),
            SizedBox(width: 30),
            Text(
              'Rupture d\' intrants :',
              style: GoogleFonts.lato(
                textStyle: Theme.of(context).textTheme.displayMedium,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                fontStyle: FontStyle.italic,
              ),
              overflow: TextOverflow.clip,
            ),
            Expanded(
              child: Form(
                key: _formkey,
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        /*Type d'intrants faire un menu deroulant avec avec des cases à cocher permettant de 
                        selectionner un ou plusieurs intrants pas disponibles aux laboratoires */
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: "Type d'intrants",
                            suffixIcon: Icon(
                              Icons.local_hospital_outlined,
                              color: Colors.black54,
                            ),
                            labelStyle: TextStyle(color: Colors.black54),
                            hintText: "choisir le ou les intrants",
                            hintStyle: TextStyle(color: Colors.black54),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blueAccent,
                                width: 3.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: const Color.fromARGB(255, 2, 158, 236),
                                width: 3.0,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Veuillez choisir le ou les intrants en ruptures";
                            }
                            return null;
                          },
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(height: 10),
                        /* date et heure de collecte */
                        TextFormField(
                          controller: _collectionDateTimeController,
                          decoration: InputDecoration(
                            labelText: 'Date de collecte de l\'échantillon',
                            suffixIcon: IconButton(
                              icon: Icon(Icons.calendar_month_outlined),
                              color: Colors.black54,
                              onPressed: () async {
                                final DateTime? collectionDateTime =
                                    await showDatePicker(
                                      locale: const Locale('fr', 'FR'),
                                      context: context,
                                      firstDate: DateTime.now().add(
                                        const Duration(
                                          days: 365 * 120 * -1,
                                          hours: Duration.hoursPerDay,
                                        ),
                                      ),
                                      lastDate: DateTime.now(),
                                    );
                                if (collectionDateTime == null) return;
                                final formattedDatetime = DateFormat(
                                  "dd/MM/yyyy | HH:mm",
                                ).format(collectionDateTime);
                                setState(() {
                                  _collectionDateTimeController.text =
                                      formattedDatetime.toString();
                                });
                                const Icon(Icons.calendar_month);
                              },
                            ),
                            labelStyle: TextStyle(color: Colors.black54),
                            hintText: 'choisir la date de collecte',
                            hintStyle: TextStyle(color: Colors.black54),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blueAccent,
                                width: 3.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: const Color.fromARGB(255, 2, 158, 236),
                                width: 3.0,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez choisir la date de collecte de l\'échantillon';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => Laboratoryaction(),
                                  ),
                                );
                              },
                              label: Text("Retour"),
                              icon: Icon(
                                Icons.chevron_left_outlined,
                                color: Colors.white,
                              ),
                              style: ElevatedButton.styleFrom(
                                textStyle: const TextStyle(fontSize: 15),
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.red,
                              ),
                            ),
                            /* Botton suivan et sauvegarder */
                            ElevatedButton.icon(
                              onPressed: () async {
                                if (_formkey.currentState!.validate()) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Notification Enregistrée"),
                                    ),
                                  );
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (ctx) => Breaklist(),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Veuillez selectionner le ou les intrants indisponibles et la date de rupture",
                                      ),
                                    ),
                                  );
                                }
                              },
                              label: Icon(
                                Icons.chevron_right_outlined,
                                color: Colors.white,
                              ),
                              icon: Text("Suivant"),
                              style: ElevatedButton.styleFrom(
                                textStyle: const TextStyle(fontSize: 15),
                                foregroundColor: Colors.white,
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  2,
                                  118,
                                  213,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
