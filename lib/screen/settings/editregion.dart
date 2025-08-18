import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/region_models.dart';
import '../../data/data_sample.dart';

class Editregion extends StatefulWidget {
  const Editregion({super.key, required this.regionModels});
  final RegionModels regionModels;

  @override
  State<Editregion> createState() => _EditregionState();
}

class _EditregionState extends State<Editregion> {
  final _formkey = GlobalKey<FormState>();
  late TextEditingController _regionController;

  @override
  void initState() {
    super.initState();
    _regionController = TextEditingController(text: widget.regionModels.region);
  }

  @override
  void dispose() {
    _regionController.dispose();
    super.dispose();
  }

  /* Function update region */
  Future _updateRegion() async {
    RegionModels updateRegion = RegionModels(
        regionid: widget.regionModels.regionid, region: _regionController.text);
    await DatabaseHelper.instance.updateRegion(updateRegion);
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          " Modifier circuit",
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
              'Configuration de circuits',
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
                        /* champ nom de circuit  à modifier*/
                        TextFormField(
                          controller: _regionController,
                          decoration: InputDecoration(
                            labelText: 'Region',
                            suffixIcon: Icon(
                              Icons.perm_identity,
                              color: Colors.black54,
                            ),
                            labelStyle: TextStyle(color: Colors.black54),
                            hintText: 'Entrer votre nom',
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
                              return 'Veuillez saisir votre nom';
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
                            /* Botton sauvegarder */
                            ElevatedButton.icon(
                              onPressed: () {
                                _updateRegion();
                                if (_formkey.currentState!.validate()) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              "Modifications éffectuées")));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              "Veuillez remplir tous les champs")));
                                }
                              },
                              label: Icon(Icons.save, color: Colors.white),
                              icon: Text("Enregistrer"),
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
