import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../models/district_models.dart';
import '../../notifications/showlocalnotification.dart';
import '../../provider/district_notifier.dart';
import '../settings/districtforms.dart';
import '../settings/editdistrict.dart';

class Districtliste extends StatefulWidget {
  const Districtliste({super.key});

  @override
  State<Districtliste> createState() => _DistrictlisteState();
}

class _DistrictlisteState extends State<Districtliste> {
  late DistrictNotifier _districtNotifier;
  late Future<List<DistrictModels>> _districtsFuture;

  @override
  void initState() {
    super.initState();
    _districtNotifier = DistrictNotifier();
    _districtsFuture = _districtNotifier.loadDistricts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Listes des Districts',
          style: GoogleFonts.lato(
            textStyle: Theme.of(context).textTheme.displayMedium,
            fontSize: 25,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontStyle: FontStyle.italic,
          ),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Padding(padding: EdgeInsets.all(5)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            margin: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 241, 235, 235),
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextFormField(
              decoration: InputDecoration(
                icon: Icon(Icons.search),
                hintText: "Recherche",
                border: InputBorder.none,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<DistrictModels>>(
              future: _districtsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text(" Aucun district ajouté"));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    DistrictModels districtModels = snapshot.data![index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                      elevation: 3,
                      color: Colors.grey,
                      child: ListTile(
                        title: Text(districtModels.namedistrict),
                        leading: CircleAvatar(
                          backgroundImage: AssetImage('assets/images/mshp.jpg'),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              onPressed: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => Editdistrict(
                                      districtModels: districtModels,
                                    ),
                                  ),
                                );
                                setState(() {
                                  _districtsFuture = _districtNotifier
                                      .loadDistricts();
                                });
                                Showlocalnotification().shownotification(
                                  'District Enregistré',
                                  'This is a local notification',
                                );
                              },
                              icon: Icon(Icons.edit, color: Colors.blue),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await _districtNotifier.deleteDistrict(
                                  districtModels.iddistrict!,
                                );
                                setState(() {
                                  _districtsFuture = _districtNotifier
                                      .loadDistricts();
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => Districtforms()));
          setState(() {
            _districtsFuture = _districtNotifier.loadDistricts();
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
