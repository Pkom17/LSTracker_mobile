import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screen/listes/circuitliste.dart';
import '../screen/listes/districtliste.dart';
import '../screen/listes/regionliste.dart';
import '../screen/listes/siteliste.dart';
import '../screen/settings/profils.dart';
import '../screen/settings/server.dart';

class SettingsDashboard extends StatefulWidget {
  const SettingsDashboard({super.key});

  @override
  State<SettingsDashboard> createState() => _SettingsDashboardState();
}

class _SettingsDashboardState extends State<SettingsDashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Paramètres",
          style: GoogleFonts.lato(
            textStyle: Theme.of(context).textTheme.displayMedium,
            fontSize: 25,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontStyle: FontStyle.italic,
          ),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Container(
        width: double.infinity,
        color: const Color.fromARGB(255, 233, 241, 242),
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    /*Serveur*/
                    Card(
                      child: IconButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => Server()));
                        },
                        icon: Icon(Icons.cloud_circle),
                        color: Colors.blue,
                        iconSize: 40,
                        tooltip: 'Settings',
                        hoverColor: Colors.blue,
                      ),
                    ),
                    Text(
                      'Serveurs',
                      style: TextStyle(
                        fontFamily: 'RobotoCondensed',
                      ),
                    )
                  ],
                ),
                Column(
                  children: [
                    /*user profil*/
                    Card(
                      child: IconButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => Profils()));
                        },
                        icon: Icon(Icons.location_history),
                        color: Colors.blue,
                        iconSize: 40,
                        tooltip: 'proflis',
                        hoverColor: Colors.blue,
                      ),
                    ),
                    Text(
                      'Profils',
                      style: TextStyle(
                        fontFamily: 'RobotoCondensed',
                      ),
                    )
                  ],
                ),
                Column(
                  /*user circuit*/
                  children: [
                    Card(
                      child: IconButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => Circuitliste()));
                        },
                        icon: Icon(Icons.business_outlined),
                        color: Colors.blue,
                        iconSize: 40,
                        tooltip: 'Circuits',
                        hoverColor: Colors.blue,
                      ),
                    ),
                    Text(
                      'Circuits',
                      style: TextStyle(
                        fontFamily: 'RobotoCondensed',
                      ),
                    )
                  ],
                ),
                Column(
                  /*Region*/
                  children: [
                    Card(
                      child: IconButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => Regionliste()));
                        },
                        icon: Icon(Icons.business_outlined),
                        color: Colors.blue,
                        iconSize: 40,
                        tooltip: 'Settings',
                        hoverColor: Colors.blue,
                      ),
                    ),
                    Text(
                      'Regions',
                      style: TextStyle(
                        fontFamily: 'RobotoCondensed',
                      ),
                    )
                  ],
                ),
              ],
            ),
            Divider(thickness: 5, indent: 10, endIndent: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    /*Districts*/
                    Card(
                      child: IconButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => Districtliste()));
                        },
                        icon: Icon(Icons.business_outlined),
                        color: Colors.blue,
                        iconSize: 40,
                        tooltip: 'Districts',
                        hoverColor: Colors.blue,
                      ),
                    ),
                    Text(
                      'Districts',
                      style: TextStyle(
                        fontFamily: 'RobotoCondensed',
                      ),
                    )
                  ],
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    /*Sites*/
                    Card(
                      child: IconButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => Siteliste()));
                        },
                        icon: Icon(Icons.business_outlined),
                        color: Colors.blue,
                        iconSize: 40,
                        tooltip: 'proflis',
                        hoverColor: Colors.blue,
                      ),
                    ),
                    Text(
                      'Sites',
                      style: TextStyle(
                        fontFamily: 'RobotoCondensed',
                      ),
                    )
                  ],
                ),
                Column(
                  /*user circuit*/
                  children: [
                    Card(
                      child: IconButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => Circuitliste()));
                        },
                        icon: Icon(Icons.add_home_outlined),
                        color: Colors.blue,
                        iconSize: 40,
                        tooltip: 'Circuits',
                        hoverColor: Colors.blue,
                      ),
                    ),
                    Text(
                      'Circuits',
                      style: TextStyle(
                        fontFamily: 'RobotoCondensed',
                      ),
                    )
                  ],
                ),
                Column(
                  children: [
                    Card(
                      child: IconButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => Server()));
                        },
                        icon: Icon(Icons.cloud_circle),
                        color: Colors.blue,
                        iconSize: 40,
                        tooltip: 'Settings',
                        hoverColor: Colors.blue,
                      ),
                    ),
                    Text(
                      'Serveurs',
                      style: TextStyle(
                        fontFamily: 'RobotoCondensed',
                      ),
                    )
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
