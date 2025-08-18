import 'package:flutter/material.dart';

import 'package:transparent_image/transparent_image.dart';

import '../listes/availableresults.dart';

class Collectresult extends StatefulWidget {
  const Collectresult({super.key});

  @override
  State<Collectresult> createState() => _CollectresultState();
}

class _CollectresultState extends State<Collectresult> {
  void completed() {
    setState(() {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => Availableresults()));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.hardEdge,
      elevation: 2,
      child: InkWell(
        onTap: () {
          completed();
        },
        child: Stack(
          children: [
            FadeInImage(
              placeholder: MemoryImage(kTransparentImage),
              image: AssetImage("assets/images/tuber.jpg"),
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
                      "Collecter des résultats",
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
  }
}
