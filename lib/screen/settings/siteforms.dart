import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/data_sample.dart';
import '../../models/site_models.dart';
import '../../widgets/bottomnavigation.dart';
import '../../widgets/settings_dashboard.dart';
import '../listes/siteliste.dart';

class Siteforms extends StatefulWidget {
  const Siteforms({super.key});

  @override
  State<Siteforms> createState() => _SiteformsState();
}

class _SiteformsState extends State<Siteforms> {
  final _formkey = GlobalKey<FormState>();
  final TextEditingController _siteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _siteController.text;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          " Sites",
          style: GoogleFonts.lato(
            textStyle: Theme.of(context).textTheme.displayMedium,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontStyle: FontStyle.italic,
          ),
        ),
        backgroundColor: Colors.blueAccent,
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
              'Configuration des Etablissements Sanitaires',
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
                        /* champ nom de circuit */
                        TextFormField(
                          controller: _siteController,
                          decoration: InputDecoration(
                            labelText: 'Sites',
                            suffixIcon: Icon(
                              Icons.perm_identity,
                              color: Colors.black54,
                            ),
                            labelStyle: TextStyle(color: Colors.black54),
                            hintText:
                                'Entrer le nom de l\'établissement Sanitaire ',
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
                              return 'Veuillez saisir le nom de l\'établissement Sanitaire ';
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
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (ctx) => SettingsDashboard(),
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
                            /* Botton sauvegarder */
                            ElevatedButton.icon(
                              onPressed: () async {
                                if (_formkey.currentState!.validate()) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Enregistrement éffectué"),
                                    ),
                                  );
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => Siteliste(),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Veuillez remplir tous les champs",
                                      ),
                                    ),
                                  );
                                }
                                await DatabaseHelper.instance.addSite(
                                  SiteModels(namesite: _siteController.text),
                                );
                              },
                              label: Icon(Icons.save, color: Colors.white),
                              icon: Text("Enregistrer"),
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
      bottomNavigationBar: Bottomnavigation(),
    );
  }
}
