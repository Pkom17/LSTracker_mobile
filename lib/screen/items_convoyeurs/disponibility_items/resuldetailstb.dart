import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../listes/disponibility_result/disporesulttb.dart';

class Resuldetailstb extends StatelessWidget {
  const Resuldetailstb({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.hardEdge,
      elevation: 2,
      child: GestureDetector(
        onTap: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => Disporesulttb()));
        },
        child: Stack(
          children: [
            Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.orange,
                      child: Text("TB",
                          style: GoogleFonts.lato(
                            textStyle: Theme.of(context).textTheme.bodyMedium,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          )),
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Text(
                        "Collecter Résultats TB",
                        style: GoogleFonts.lato(
                          textStyle: Theme.of(context).textTheme.displayMedium,
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Card(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        color: Colors.black54,
                        child: Column(
                          children: [
                            Text(
                              'A Collecter',
                              /* Item representant la récuperation des échantillons par le convoyeur*/
                              style: GoogleFonts.lato(
                                textStyle:
                                    Theme.of(context).textTheme.displayMedium,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            Text(
                              '00',
                              /* Afficher le nombre total d'echantillons collectés par le convoyeur. Cette valeur doit être décrementer après la remise de ou des échantillons aux laboratoires*/
                              style: GoogleFonts.lato(
                                textStyle:
                                    Theme.of(context).textTheme.displayMedium,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontStyle: FontStyle.italic,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                    Card(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        color: Colors.black54,
                        child: Column(
                          children: [
                            Text(
                              'Collecter',
                              /* Item representant la remise des échantillons aux laboratoires par le convoyeur*/
                              style: GoogleFonts.lato(
                                textStyle:
                                    Theme.of(context).textTheme.displayMedium,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            Text(
                              '25',
                              /* Afficher le nombre total d'echantillons collectés par le convoyeur remis au laboratoire.Cette valeure elle doit être incrémenter après la remise de ou des échantillons aux laboratoires*/
                              style: GoogleFonts.lato(
                                textStyle:
                                    Theme.of(context).textTheme.displayMedium,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                fontStyle: FontStyle.italic,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
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
