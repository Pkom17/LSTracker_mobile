import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'savesample.dart';

class Startcollect extends StatefulWidget {
  const Startcollect({super.key});

  @override
  State<Startcollect> createState() => _Startcollect();
}

class _Startcollect extends State<Startcollect> {
  final _formkey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Commencer la collecte",
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
              'Selectionner un circuit :',
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
                        /* Affichage axe selectionné depuis commencé le circuit */
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Axe',
                            suffixIcon: Icon(
                              Icons.local_hospital_outlined,
                              color: Colors.black54,
                            ),
                            labelStyle: TextStyle(color: Colors.black54),
                            hintText: 'choisir un circuit',
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
                              return 'Veuillez choisir un circuit';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(height: 10),
                        /* Site à selectionner depuis un dropdown value */
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Site de collecte',
                            suffixIcon: Icon(
                              Icons.local_hospital_outlined,
                              color: Colors.black54,
                            ),
                            labelStyle: TextStyle(color: Colors.black54),
                            hintText: 'choisir un site',
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
                              return 'Veuillez choisir un site de collecte';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(height: 10),
                        /* Saisir le kilometrage à l'arrivé sur site (km sur site) */
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Kilométrage arrivée sur site',
                            suffixIcon: Icon(
                              Icons.map_outlined,
                              color: Colors.black54,
                            ),
                            labelStyle: TextStyle(color: Colors.black54),
                            hintText:
                                'Saisir le Kilométrage d\' arrivée sur site',
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
                              return 'Veuillez saisir le kilometrage arrivée sur site';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.number,
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
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
                            /* Botton suivant et sauvegarder */
                            ElevatedButton.icon(
                              onPressed: () async {
                                if (_formkey.currentState!.validate()) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Etape 2 Enregistrée"),
                                    ),
                                  );
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (ctx) => Savesample(),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Veuillez saisir tous les champs de votre formulaire",
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
