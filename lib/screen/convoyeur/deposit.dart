import 'package:flutter/material.dart';

import 'package:transparent_image/transparent_image.dart';

import '../listes/Collect_sample/depositliste.dart';

class Deposit extends StatefulWidget {
  const Deposit({super.key});

  @override
  State<Deposit> createState() => _DepositState();
}

class _DepositState extends State<Deposit> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.hardEdge,
      elevation: 2,
      child: GestureDetector(
        onTap: () {
          setState(() {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (context) => Depositliste()));
          });
        },
        child: Stack(
          children: [
            FadeInImage(
              placeholder: MemoryImage(kTransparentImage),
              image: AssetImage("assets/images/tuberculose.jpg"),
              fit: BoxFit.cover,
              height: 200,
              width: double.infinity,
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black54,
                padding: EdgeInsets.symmetric(vertical: 6, horizontal: 44),
                child: Column(
                  children: [
                    Text(
                      "Déposer des échantillons",
                      maxLines: 2,
                      textAlign: TextAlign.center,
                      softWrap: true,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                color: Colors.black54,
                child: Text(
                  '25',
                  /*Nombre d'échantillon collectés apres avoir cliquer sur sauvegarder*/
                  style: TextStyle(fontSize: 25, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    /*
    
    Container(
      padding: EdgeInsets.all(3),
      height: 120,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Ink.image(
            image: AssetImage(listActions.image),
            fit: BoxFit.cover,
            child: InkWell(
              onTap: () {},
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /* Afficher le total d'échantillons Transmis au Laboratoire*/
                      Text(
                        listActions.total,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        listActions.name,
                        style: GoogleFonts.robotoCondensed(
                          textStyle: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );

*/
  }
}
