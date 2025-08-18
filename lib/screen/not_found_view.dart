import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NotFoundView extends StatelessWidget {
  const NotFoundView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Text(
          'not found !!!',
          style: GoogleFonts.lato(
            textStyle: Theme.of(context).textTheme.displayMedium,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: const Color.fromARGB(255, 6, 10, 231),
            fontStyle: FontStyle.italic,
          ),
        ),
      ),
    );
  }
}
