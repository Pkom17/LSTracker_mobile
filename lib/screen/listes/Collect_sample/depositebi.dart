import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../qr/qr_scanner_screen.dart';
import '../../formulaires/acceptsampleform.dart';

class Depositebi extends StatefulWidget {
  const Depositebi({super.key});

  @override
  State<Depositebi> createState() => _DepositebiState();
}

class _DepositebiState extends State<Depositebi> {
  final List<String> contents = ['Deposer', 'Scan'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Listes des échantillons BI à déposer',
          style: GoogleFonts.lato(
            textStyle: Theme.of(context).textTheme.displayMedium,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontStyle: FontStyle.italic,
          ),
        ),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return contents
                  .map((e) => PopupMenuItem<String>(value: e, child: Text(e)))
                  .toList();
            },
            onSelected: (value) {
              if (value == 'Deposer') {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Acceptsampleform()));
              } else if (value == 'Scan') {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => QrScannerScreen()));
              }
            },
          ),
          // IconButton(
          //   onPressed: () {
          //     /*creer un script permettant de deposer les échantillons aux laboratoires */
          //   },
          //   icon: Icon(Icons.more_vert_outlined),
          //   /*cette icone doit être activé lorsque un échantillon est séléctionné pour être deposer */
          // ),
        ],
        backgroundColor: Colors.blueAccent,
      ),
      body: Column(
        children: [
          Padding(padding: EdgeInsets.all(5)),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            margin: EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
                color: Colors.grey, borderRadius: BorderRadius.circular(10)),
            child: TextFormField(
              decoration: InputDecoration(
                  icon: Icon(Icons.search),
                  hintText: "Recherche",
                  border: InputBorder.none),
            ),
          ),
          Text("Echantillons BI à déposer")
        ],
      ),
    );
  }
}
