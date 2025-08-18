import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../screen/settings/circuitforms.dart';
import '../../screen/settings/editcircuit.dart';
import 'package:provider/provider.dart';
import '../../models/circuit_models.dart';
import '../../provider/circuit_notifier.dart';

class Circuitliste extends StatefulWidget {
  const Circuitliste({super.key});

  @override
  State<Circuitliste> createState() => _CircuitlisteState();
}

class _CircuitlisteState extends State<Circuitliste> {
  late CircuitNotifier _circuitNotifier;
  late Future<List<CircuitModels>> _circuitsFuture;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _circuitNotifier = CircuitNotifier();
    _circuitsFuture = _circuitNotifier.loadCircuits();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CircuitNotifier>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Liste Circuits',
          style: GoogleFonts.lato(
            textStyle: Theme.of(context).textTheme.displayMedium,
            fontSize: 25,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontStyle: FontStyle.italic,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Padding(padding: EdgeInsets.all(5)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            margin: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.circular(10),
            ),
            child: TextFormField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Search",
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {},
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<CircuitModels>>(
              future: _circuitsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text(" Aucun circuit ajouté"));
                }
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    CircuitModels circuitModels = snapshot.data![index];
                    return ListTile(
                      title: Text(circuitModels.name),
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
                                  builder: (context) =>
                                      Editcircuit(circuitModels: circuitModels),
                                ),
                              );
                              setState(() {
                                _circuitsFuture = _circuitNotifier
                                    .loadCircuits();
                              });
                            },
                            icon: Icon(Icons.edit),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () async {
                              await _circuitNotifier.deleteCircuit(
                                circuitModels.idcircuit!,
                              );
                              setState(() {
                                _circuitsFuture = _circuitNotifier
                                    .loadCircuits();
                              });
                            },
                          ),
                        ],
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
          ).push(MaterialPageRoute(builder: (context) => Circuitforms()));
          setState(() {
            _circuitsFuture = _circuitNotifier.loadCircuits();
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
