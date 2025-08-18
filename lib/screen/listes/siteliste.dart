import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/site_models.dart';
import '../../provider/site_notifier.dart';
import '../../screen/settings/siteforms.dart';
import '../settings/editSite.dart';

class Siteliste extends StatefulWidget {
  const Siteliste({super.key});

  @override
  State<Siteliste> createState() => _SitelisteState();
}

class _SitelisteState extends State<Siteliste> {
  late SiteNotifier _siteNotifier;
  late Future<List<SiteModels>> _siteFuture;

  @override
  void initState() {
    super.initState();
    _siteNotifier = SiteNotifier();
    _siteFuture = _siteNotifier.loadSites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Listes des Sites',
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
                color: Color.fromARGB(255, 241, 235, 235),
                borderRadius: BorderRadius.circular(10)),
            child: TextFormField(
              decoration: InputDecoration(
                  icon: Icon(Icons.search),
                  hintText: "Recherche",
                  border: InputBorder.none),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<SiteModels>>(
                future: _siteFuture,
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
                        SiteModels siteModels = snapshot.data![index];
                        return ListTile(
                          title: Text(siteModels.namesite),
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
                                      builder: (context) =>
                                          Editsite(siteModels: siteModels),
                                    ));
                                    setState(() {
                                      _siteFuture = _siteNotifier.loadSites();
                                    });
                                  },
                                  icon: Icon(Icons.edit)),
                              IconButton(
                                icon: Icon(Icons.delete),
                                onPressed: () async {
                                  await _siteNotifier
                                      .deleteSite(siteModels.idsite!);
                                  setState(() {
                                    _siteFuture = _siteNotifier.loadSites();
                                  });
                                },
                              ),
                            ],
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
              .push(MaterialPageRoute(builder: (context) => Siteforms()));
          setState(() {
            _siteFuture = _siteNotifier.loadSites();
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
