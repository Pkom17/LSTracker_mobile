import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/site_models.dart';
import '../../widgets/settings_dashboard.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import '../../data/data_sample.dart';
import '../../screen/listes/circuitliste.dart';
import '../../models/circuit_models.dart';
import '../../widgets/bottomnavigation.dart';

class Circuitforms extends StatefulWidget {
  const Circuitforms({super.key});

  @override
  State<Circuitforms> createState() => _CircuitformsState();
}

class _CircuitformsState extends State<Circuitforms> {
  final _formkey = GlobalKey<FormState>();
  final TextEditingController _circuitController = TextEditingController();
  List<SiteModels> _siteModels = [];
  List<SiteModels> _selectedModels = [];

  @override
  void initState() {
    _circuitController.text;
    _loadItems();
    super.initState();
  }

  Future<void> _loadItems() async {
    List<SiteModels> sites = await DatabaseHelper.instance.getSite();
    setState(() {
      _siteModels = sites;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          " Circuits",
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
                        /* champ nom de circuit */
                        TextFormField(
                          controller: _circuitController,
                          decoration: InputDecoration(
                            labelText: 'Circuit',
                            suffixIcon: Icon(
                              Icons.perm_identity,
                              color: Colors.black54,
                            ),
                            labelStyle: TextStyle(color: Colors.black54),
                            hintText: 'Entrer le nom du circuit',
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
                              return 'Veuillez saisir le circuit';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(height: 10),

                        /*Select Multiple Item */
                        Column(
                          children: [
                            _siteModels.isEmpty
                                ? CircularProgressIndicator()
                                : MultiSelectDialogField(
                                    items: _siteModels
                                        .map((site) =>
                                            MultiSelectItem<SiteModels>(
                                                site, site.namesite))
                                        .toList(),
                                    title: Text("Selectionner des sites"),
                                    selectedColor: Colors.blueAccent,
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                          color: Colors.blue, width: 2),
                                    ),
                                    buttonText: Text("Choisir des sites"),
                                    onConfirm: (results) {
                                      setState(() {
                                        _selectedModels =
                                            results.cast<SiteModels>();
                                      });
                                    }),
                          ],
                        ),
                        SizedBox(height: 10),
                        Wrap(
                          children: _selectedModels
                              .map((site) => Chip(
                                    label: Text(site.namesite),
                                    backgroundColor: Colors.blue.shade100,
                                  ))
                              .toList(),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => SettingsDashboard()));
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
                            /* Botton suivan et sauvegarder */
                            ElevatedButton.icon(
                              onPressed: () async {
                                if (_formkey.currentState!.validate()) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content:
                                              Text("Enregistrement éffectué")));
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => Circuitliste()));
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              "Veuillez remplir tous les champs")));
                                }
                                await DatabaseHelper.instance.addCircuit(
                                    CircuitModels(
                                        name: _circuitController.text,
                                        sites: _selectedModels));
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
      bottomNavigationBar: Bottomnavigation(),
    );
  }
}
