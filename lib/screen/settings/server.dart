import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lstracker/widgets/bottomnavigation.dart';

class Server extends StatefulWidget {
  const Server({super.key});

  @override
  State<Server> createState() => _ServerState();
}

class _ServerState extends State<Server> {
  final _formkey = GlobalKey<FormState>();
  bool _hiddenpassword = true;
  void _togglePassword() {
    setState(() {
      _hiddenpassword = !_hiddenpassword;
    });
  }

  @override
  void initState() {
    super.initState();
    _hiddenpassword = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          " Paramètres Serveurs",
          style: GoogleFonts.lato(
            textStyle: Theme.of(context).textTheme.displayMedium,
            fontSize: 25,
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
              radius: 50,
            ),
            Text(
              'Configuration des paramètres du serveur ',
              style: GoogleFonts.lato(
                textStyle: Theme.of(context).textTheme.displayMedium,
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Colors.black,
                fontStyle: FontStyle.italic,
              ),
              overflow: TextOverflow.clip,
            ),
            Form(
              key: _formkey,
              child: Container(
                padding: EdgeInsets.all(8),
                child: Column(
                  children: [
                    /* champ une Url */
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Url',
                        suffixIcon: Icon(Icons.cloud, color: Colors.black54),
                        labelStyle: TextStyle(color: Colors.black54),
                        hintText: 'Entrer une Url',
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
                          return 'Veuillez saisir une Url';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.text,
                    ),
                    SizedBox(height: 10),
                    /* champ pour le nom utilisateur */
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'User',
                        suffixIcon: Icon(Icons.dns, color: Colors.black54),
                        labelStyle: TextStyle(color: Colors.black54),
                        hintText: 'Nom utilisateur',
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
                          return 'Veuillez saisir le nom utilisateur ';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.text,
                    ),
                    SizedBox(height: 10),
                    /* champ pour le mot de passe */
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Password',
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
                        hintText: 'Entrer password',
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
                    SizedBox(height: 15),
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
          ],
        ),
      ),
      bottomNavigationBar: Bottomnavigation(),
    );
  }
}
