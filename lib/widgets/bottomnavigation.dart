import 'package:flutter/material.dart';
import 'package:lstracker/widgets/conveyoraction.dart';

import '../screen/home.dart';
import '../screen/listes/availableresults.dart';
import 'laboratoryaction.dart';

class Bottomnavigation extends StatefulWidget {
  const Bottomnavigation({super.key});

  @override
  State<Bottomnavigation> createState() => _BottomnavigationState();
}

class _BottomnavigationState extends State<Bottomnavigation> {
  @override
  Widget build(BuildContext context) {
    /*final moveChange = Provider.of<DepalceProvider>(context);*/
    return BottomAppBar(
      child: Container(
        height: 100,
        width: 400,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            /* Redirection vers la page home  */
            Card(
              child: IconButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (ctx) => HomeView()));
                },
                icon: Icon(Icons.now_widgets_outlined, color: Colors.orange),
              ),
            ),
            /* Redirection vers la liste des actions du convoyeur  */
            Card(
              child: IconButton(
                onPressed: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(builder: (ctx) => ConvoyeurView()));
                },
                icon: Icon(
                  Icons.delivery_dining_outlined,
                  color: Colors.orange,
                ),
              ),
            ),
            /* Redirection vers la liste des actions du laboratoire */
            Card(
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (ctx) => Laboratoryaction()),
                  );
                },
                icon: Icon(Icons.local_hospital_outlined, color: Colors.orange),
              ),
            ),
            /* Redirection vers la liste des résultats disponibles ajouter badge Count*/
            Card(
              child: IconButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => Availableresults()),
                  );
                },
                icon: Badge.count(
                  count: 15,
                  /*decompter lorsque un résultat disponibles*/
                  child: Icon(Icons.add_alert_outlined, color: Colors.orange),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    /*
    
    BottomNavigationBar(     
             items: [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.now_widgets_outlined,
            color: Colors.white,
          ),
          label: "LSTracker",
          backgroundColor: Colors.orange,
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.delivery_dining_outlined,
            color: Colors.white,
            fill: 0.2,
          ),
          label: "Menu Convoyage",
          backgroundColor: Colors.green,
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.local_hospital_outlined,
            color: Colors.white,
            fill: 0.2,
          ),
          label: "Menu Laboratoire",
          backgroundColor: Colors.green,
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.receipt_long_outlined,
            color: Colors.white,
            fill: 0.2,
          ),
          label: "resulats collectés",
          backgroundColor: Colors.green,
        ),
      ],
      backgroundColor: const Color.fromARGB(255, 216, 218, 219),
      selectedItemColor: const Color.fromARGB(255, 216, 218, 219),
      onTap: moveChange.itemClique,
      currentIndex: moveChange.nav,
      */
  }
}
