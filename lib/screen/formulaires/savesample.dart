import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class Savesample extends StatefulWidget {
  const Savesample({super.key});

  @override
  State<Savesample> createState() => _SavesampleState();
}

class _SavesampleState extends State<Savesample> {
  final _formkey = GlobalKey<FormState>();
  final _collectionDateController = TextEditingController();
  final _collectionTimeController = TextEditingController();
  final _collectionDateTimeController = TextEditingController();

  clear() async {
    _collectionDateController.text = "";
    _collectionTimeController.text = "";
    _collectionDateTimeController.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Enregistrer échantillon",
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
              Colors.blueGrey
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
                        /* Affichage du site selectionné depuis commencé à collecter */
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Site de collecte',
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
                                  color: Colors.blueAccent, width: 3.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: const Color.fromARGB(255, 2, 158, 236),
                                  width: 3.0),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez choisir un site';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(height: 10),
                        /* Selectionner le type d'échantillon depuis un dropdown value faire apparaitre ( VIH, TB,HPV et autres) */
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Types d\'échantillons',
                            suffixIcon: Icon(
                              Icons.local_hospital_outlined,
                              color: Colors.black54,
                            ),
                            labelStyle: TextStyle(color: Colors.black54),
                            hintText: 'choisir un type d\'échantillons',
                            hintStyle: TextStyle(color: Colors.black54),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.blueAccent, width: 3.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: const Color.fromARGB(255, 2, 158, 236),
                                  width: 3.0),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez choisir un type d\'échantillons';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(height: 10),
                        /* Selectionner la nature de prélèvement qui doit être lié au type d'échantillon 
                        (DBS, Sang Total, Plasma, Serum, PSC, Crachat,  Lcr, Selles, PV, Autre )*/
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Nature du prélèvement',
                            suffixIcon: Icon(
                              Icons.local_hospital_outlined,
                              color: Colors.black54,
                            ),
                            labelStyle: TextStyle(color: Colors.black54),
                            hintText: 'choisir la nature de prélèvements',
                            hintStyle: TextStyle(color: Colors.black54),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.blueAccent, width: 3.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: const Color.fromARGB(255, 2, 158, 236),
                                  width: 3.0),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez choisir la nature de prélèvement';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(height: 10),
                        /* Saisir le code patient ou scanner le code patient */
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Code patient',
                            suffixIcon: Icon(
                              Icons.qr_code_2_outlined,
                              color: Colors.black54,
                            ),
                            labelStyle: TextStyle(color: Colors.black54),
                            hintText: 'Saisir le code patient',
                            hintStyle: TextStyle(color: Colors.black54),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.blueAccent, width: 3.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: const Color.fromARGB(255, 2, 158, 236),
                                  width: 3.0),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez saisir le kilometrage arrivée sur site';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(height: 10),
                        /* Date de prelèvement */
                        TextFormField(
                          controller: _collectionDateController,
                          keyboardType: TextInputType.datetime,
                          decoration: InputDecoration(
                            labelText: 'Date de prelèvement',
                            suffixIcon: IconButton(
                              icon: Icon(
                                Icons.calendar_month_outlined,
                              ),
                              color: Colors.black54,
                              onPressed: () async {
                                final DateTime? collectionDate =
                                    await showDatePicker(
                                        locale: const Locale('fr', 'FR'),
                                        context: context,
                                        firstDate: DateTime.now().add(
                                            const Duration(
                                                days: 365 * 120 * -1)),
                                        lastDate: DateTime.now());
                                if (collectionDate == null) return;
                                final formattedDate = DateFormat("dd/MM/yyyy")
                                    .format(collectionDate);
                                setState(() {
                                  _collectionDateController.text =
                                      formattedDate.toString();
                                });
                                const Icon(Icons.calendar_month);
                              },
                            ),
                            labelStyle: TextStyle(color: Colors.black54),
                            hintText:
                                'choisir la date de prèlèvement de l\'échantillon',
                            hintStyle: TextStyle(color: Colors.black54),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.blueAccent, width: 3.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: const Color.fromARGB(255, 2, 158, 236),
                                  width: 3.0),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez choisir la date de prélèvement de l\'échantillon';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        /* heure de prélèvement */
                        TextFormField(
                          controller: _collectionTimeController,
                          decoration: InputDecoration(
                            labelText: 'Heure de prelèvement',
                            suffixIcon: IconButton(
                              icon: Icon(
                                Icons.watch,
                              ),
                              color: Colors.black54,
                              onPressed: () async {
                                final TimeOfDay? collectionTime =
                                    await showTimePicker(
                                  builder:
                                      (BuildContext context, Widget? child) {
                                    return MediaQuery(
                                        data: MediaQuery.of(context).copyWith(
                                            alwaysUse24HourFormat: true),
                                        child: child!);
                                  },
                                  context: context,
                                  initialTime: TimeOfDay.now(),
                                );
                                setState(() {
                                  if (collectionTime == null) return;
                                  _collectionTimeController.text =
                                      ('${collectionTime.hour}:${collectionTime.minute}');
                                });
                              },
                            ),
                            labelStyle: TextStyle(color: Colors.black54),
                            hintText:
                                'choisir la date de prèlèvement de l\'échantillon',
                            hintStyle: TextStyle(color: Colors.black54),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.blueAccent, width: 3.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: const Color.fromARGB(255, 2, 158, 236),
                                  width: 3.0),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez choisir la date de prélèvement de l\'échantillon';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        /* date et heure de collecte */
                        TextFormField(
                          controller: _collectionDateTimeController,
                          decoration: InputDecoration(
                            labelText: 'Date et heure de collecte',
                            suffixIcon: IconButton(
                              icon: Icon(
                                Icons.calendar_month_outlined,
                              ),
                              color: Colors.black54,
                              onPressed: () async {
                                final DateTime? collectionDateTime =
                                    await showDatePicker(
                                        locale: const Locale('fr', 'FR'),
                                        context: context,
                                        firstDate: DateTime.now().add(
                                            const Duration(
                                                days: 365 * 120 * -1,
                                                hours: Duration.hoursPerDay)),
                                        lastDate: DateTime.now());
                                if (collectionDateTime == null) return;
                                final formattedDatetime =
                                    DateFormat("dd/MM/yyyy | HH:mm")
                                        .format(collectionDateTime);
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
                                  color: Colors.blueAccent, width: 3.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: const Color.fromARGB(255, 2, 158, 236),
                                  width: 3.0),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez choisir la date de colecte de l\'échantillon';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 10),
                        /* Laboratoire de destination dans dropdown value */
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'laboratoire de destination',
                            suffixIcon: Icon(
                              Icons.local_hospital_outlined,
                              color: Colors.black54,
                            ),
                            labelStyle: TextStyle(color: Colors.black54),
                            hintText: 'choisir le laboratoire de destination',
                            hintStyle: TextStyle(color: Colors.black54),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.blueAccent, width: 3.0),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: const Color.fromARGB(255, 2, 158, 236),
                                  width: 3.0),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez choisir un type de prélèvement';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.text,
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
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                ),
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
                                      content: Text("Enregistrement éffectué"),
                                    ),
                                  );
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (ctx) => Savesample()));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              "Veuillez saisir tous les champs de votre formulaire")));
                                }
                              },
                              label: Icon(Icons.save_outlined,
                                  color: Colors.white),
                              icon: Text("Sauvegarder"),
                              style: ElevatedButton.styleFrom(
                                textStyle: const TextStyle(
                                  fontSize: 15,
                                ),
                                foregroundColor: Colors.white,
                                backgroundColor:
                                    const Color.fromARGB(255, 2, 118, 213),
                              ),
                            ),
                          ],
                        )
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
