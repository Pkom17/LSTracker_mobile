import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../provider/region_notifier.dart';
import '../../screen/settings/regionforms.dart';
import '../../screen/settings/editregion.dart';
import '../../models/region_models.dart';

class Regionliste extends StatefulWidget {
  const Regionliste({super.key});

  @override
  State<Regionliste> createState() => _RegionlisteState();
}

class _RegionlisteState extends State<Regionliste> {
  late RegionNotifier _regionNotifier;
  late Future<List<RegionModels>> _regionsFuture;
  final _searchRegion = TextEditingController();

  @override
  void initState() {
    super.initState();
    _regionNotifier = RegionNotifier();
    _regionsFuture = _regionNotifier.loadRegions();
  }

  @override
  Widget build(BuildContext context) {
    final providerReg = Provider.of<RegionNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Listes de Regions',
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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(padding: EdgeInsets.all(5)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            margin: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
                color: Color.fromARGB(255, 241, 235, 235),
                borderRadius: BorderRadius.circular(10)),
            child: TextFormField(
              controller: _searchRegion,
              decoration: InputDecoration(
                  labelText: "Recherche",
                  suffixIcon: IconButton(
                    icon: Icon(Icons.search),
                    onPressed: () {},
                  ),
                  border: InputBorder.none),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<RegionModels>>(
                future: _regionsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Text(" Aucune région ajoutée"),
                    );
                  }
                  return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        RegionModels regionModels = snapshot.data![index];
                        return Card(
                          margin:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 5),
                          elevation: 3,
                          color: Colors.grey,
                          child: ListTile(
                            title: Text(regionModels.region),
                            leading: CircleAvatar(
                              backgroundImage:
                                  AssetImage('assets/images/unicef.png'),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                    onPressed: () async {
                                      await Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) => Editregion(
                                            regionModels: regionModels),
                                      ));
                                      setState(() {
                                        _regionsFuture =
                                            _regionNotifier.loadRegions();
                                      });
                                    },
                                    icon: Icon(
                                      Icons.edit,
                                      color: Colors.blue,
                                    )),
                                IconButton(
                                  icon: Icon(Icons.delete, color: Colors.red),
                                  onPressed: () async {
                                    await _regionNotifier
                                        .deleteRegion(regionModels.regionid!);
                                    setState(() {
                                      _regionsFuture =
                                          _regionNotifier.loadRegions();
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      });
                }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => Regionforms()));
          setState(() {
            _regionsFuture = _regionNotifier.loadRegions();
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
