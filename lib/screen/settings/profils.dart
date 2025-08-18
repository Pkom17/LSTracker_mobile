import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../widgets/bottomnavigation.dart';

class Profils extends StatefulWidget {
  const Profils({super.key});

  @override
  State<Profils> createState() => _ProfilsState();
}

class _ProfilsState extends State<Profils> {
  final _formkey = GlobalKey<FormState>();
  bool _hiddenpassword = true;
  bool _hidenconfirm = false;

  /*masquer le mot de passe */
  void _toggleConfirmPassword() {
    setState(() {
      _hidenconfirm;
    });
  }

  /*masquer et ne pas masquer le mot de passe */
  void _togglePassword() {
    setState(() {
      _hiddenpassword = !_hiddenpassword;
    });
  }

  @override
  void initState() {
    super.initState();
    _hiddenpassword = true;
    _hidenconfirm = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          " Profils",
          style: GoogleFonts.lato(
            textStyle: Theme.of(context).textTheme.displayMedium,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            fontStyle: FontStyle.italic,
          ),
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: Container(
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 207, 232, 235),
              const Color.fromARGB(244, 232, 227, 227),
              const Color.fromARGB(255, 226, 230, 226),
              Colors.blueGrey,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            CircleAvatar(
              backgroundImage: AssetImage("assets/images/mshp.jpg"),
              radius: 30,
            ),
            SizedBox(width: 30),
            Text(
              'Configuration du profils',
              style: GoogleFonts.lato(
                textStyle: Theme.of(context).textTheme.displayMedium,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                fontStyle: FontStyle.italic,
              ),
              overflow: TextOverflow.clip,
            ),
            Expanded(
              child: Form(
                key: _formkey,
                child: Container(
                  padding: EdgeInsets.all(8),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        /* champ nom */
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Nom',
                            suffixIcon: Icon(
                              Icons.perm_identity,
                              color: Colors.black54,
                            ),
                            labelStyle: TextStyle(color: Colors.black54),
                            hintText: 'Entrer votre nom',
                            hintStyle: TextStyle(color: Colors.black54),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blueAccent,
                                width: 3.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: const Color.fromARGB(255, 2, 158, 236),
                                width: 3.0,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez saisir votre nom';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(height: 8),
                        /* champ prenom */
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Prenoms',
                            suffixIcon: Icon(
                              Icons.perm_identity,
                              color: Colors.black54,
                            ),
                            labelStyle: TextStyle(color: Colors.black54),
                            hintText: 'Entrer vos prenoms',
                            hintStyle: TextStyle(color: Colors.black54),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blueAccent,
                                width: 3.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: const Color.fromARGB(255, 2, 158, 236),
                                width: 3.0,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez saisir vos prenoms ';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.text,
                        ),
                        SizedBox(height: 8),
                        /* champ email*/
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Email',
                            suffixIcon: Icon(
                              Icons.email_outlined,
                              color: Colors.black54,
                            ),
                            labelStyle: TextStyle(color: Colors.black54),
                            hintText: 'Entrer votre email',
                            hintStyle: TextStyle(color: Colors.black54),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blueAccent,
                                width: 3.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: const Color.fromARGB(255, 2, 158, 236),
                                width: 3.0,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez saisir votre email';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.emailAddress,
                        ),
                        SizedBox(height: 8),
                        /* champ contact*/
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Contact',
                            suffixIcon: Icon(
                              Icons.contact_phone_outlined,
                              color: Colors.black54,
                            ),
                            labelStyle: TextStyle(color: Colors.black54),
                            hintText: 'Entrer votre contact',
                            hintStyle: TextStyle(color: Colors.black54),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blueAccent,
                                width: 3.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: const Color.fromARGB(255, 2, 158, 236),
                                width: 3.0,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez saisir le contact ';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.phone,
                        ),
                        SizedBox(height: 8),
                        /* champ pour le mot de passe */
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Mot de passe',
                            suffixIcon: GestureDetector(
                              onTap: () {
                                _togglePassword();
                              },
                              child: Icon(
                                _hiddenpassword == true
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                            ),
                            labelStyle: TextStyle(color: Colors.black54),
                            hintText: 'Entrer votre mot de passe',
                            hintStyle: TextStyle(color: Colors.black54),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blueAccent,
                                width: 3.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: const Color.fromARGB(255, 2, 158, 236),
                                width: 3.0,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez saisir le password';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.text,
                          obscureText: _hiddenpassword,
                        ),
                        SizedBox(height: 8),
                        /* confimation du mot de passe */
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Confirmer votre mot de passe',
                            suffixIcon: GestureDetector(
                              onTap: () {
                                _toggleConfirmPassword();
                              },
                              child: Icon(
                                _hidenconfirm == false
                                    ? Icons.visibility_off
                                    : null,
                              ),
                            ),
                            labelStyle: TextStyle(color: Colors.black54),
                            hintText: 'Confirmer mot de passe',
                            hintStyle: TextStyle(color: Colors.black54),
                            border: OutlineInputBorder(),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.blueAccent,
                                width: 3.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: const Color.fromARGB(255, 2, 158, 236),
                                width: 3.0,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez saisir le password valide';
                            }
                            return null;
                          },
                          keyboardType: TextInputType.visiblePassword,
                          obscureText: _hidenconfirm,
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              label: Text("Retour"),
                              icon: Icon(
                                Icons.chevron_left_outlined,
                                color: Colors.white,
                              ),
                              style: ElevatedButton.styleFrom(
                                textStyle: const TextStyle(fontSize: 15),
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.red,
                              ),
                            ),
                            /* Botton suivan et sauvegarder */
                            ElevatedButton.icon(
                              onPressed: () {
                                if (_formkey.currentState!.validate()) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Enregistrement éffectué"),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Veuillez remplir tous les champs",
                                      ),
                                    ),
                                  );
                                }
                              },
                              label: Icon(Icons.save, color: Colors.white),
                              icon: Text("Enregistrer"),
                              style: ElevatedButton.styleFrom(
                                textStyle: const TextStyle(fontSize: 15),
                                foregroundColor: Colors.white,
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  2,
                                  118,
                                  213,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Bottomnavigation(),
    );
  }
}
