import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';

import '../../widgets/report_activity_details.dart';

class Bilancollect extends StatefulWidget {
  const Bilancollect({super.key});

  @override
  State<Bilancollect> createState() => _BilancollectState();
}

class _BilancollectState extends State<Bilancollect> {
  void collect() {
    setState(() {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (context) => ReportActivityDetails()));
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
          collect();
        },
        child: Stack(
          children: [
            FadeInImage(
              placeholder: MemoryImage(kTransparentImage),
              image: AssetImage("assets/images/test-scaled.jpg"),
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
                      "Bilan des échantillons collectés",
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
                  '125',
                  /* Somme Total des échantillons deposés aux laboratoires (CV, BI, BS, EID, TB, HPV)*/
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
