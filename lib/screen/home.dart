import 'package:flutter/material.dart';
import '../qr/Qr_screen.dart';
import '../screen/settings/profils.dart';
import '../widgets/bottomnavigation.dart';
import '../widgets/dashboard.dart';
import '../widgets/drawer.dart';
import '../widgets/settings_dashboard.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final List<String> contents = ['Profils', 'Paramètres', 'Scan'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Tableau de board",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 30,
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
              if (value == 'Profils') {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => Profils()));
              } else if (value == 'Paramètres') {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SettingsDashboard()));
              } else if (value == 'Scan') {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => QrScreen()));
              }
            },
          ),

          // IconButton(
          //   onPressed: () {
          //     showDialog(
          //       context: context,
          //       builder: (BuildContext context) {
          //         return AlertDialog(
          //           title: Text("Profils"),
          //           content: SingleChildScrollView(
          //             child: ListBody(
          //               children: [
          //                 ListTile(
          //                   leading: Icon(Icons.logout_outlined),
          //                   title: Text('Se deconnecter'),
          //                   onTap: null,
          //                 ),
          //                 ListTile(
          //                   leading: Icon(Icons.settings_accessibility_rounded),
          //                   title: Text('Paramètres'),
          //                   onTap: () {
          //                     Navigator.of(context).push(MaterialPageRoute(
          //                         builder: (context) => SettingsDashboard()));
          //                   },
          //                 ),
          //                 ListTile(
          //                   leading: Icon(Icons.qr_code_scanner),
          //                   title: Text('Scanner Code'),
          //                   onTap: () {
          //                     Navigator.of(context).push(MaterialPageRoute(
          //                         builder: (context) => Scanner()));
          //                   },
          //                 )
          //               ],
          //             ),
          //           ),
          //         );
          //       },
          //     );
          //   },
          //   icon: Icon(Icons.more_vert),
          // )
        ],
        backgroundColor: Colors.orange,
      ),
      drawer: MainDrawer(),
      body: DashboardView(),
      bottomNavigationBar: Bottomnavigation(),
    );
  }
}
