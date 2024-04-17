import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'connexion.dart';

class InscriptionPage extends StatefulWidget {
  @override
  _InscriptionPageState createState() => _InscriptionPageState();
}

class _InscriptionPageState extends State<InscriptionPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();

  bool _isObscured = true;

  Future<void> _showChangePasswordDialog() async {
    TextEditingController confirmPasswordController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Choisir un nouveau mot de passe'),
          content: Column(
            children: [
              TextField(
                controller: newPasswordController,
                decoration: InputDecoration(labelText: 'Créer un nouveau mot de passe'),
                obscureText: true,
              ),
              SizedBox(height: 10),
              TextField(
                controller: confirmPasswordController,
                decoration: InputDecoration(labelText: 'Confirmer le nouveau mot de passe'),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (newPasswordController.text.isEmpty || confirmPasswordController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Tous les champs sont obligatoires.'),
                        duration: Duration(seconds: 4),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else if (newPasswordController.text == confirmPasswordController.text) {
                    _mettreAJourMotDePasse();
                    Navigator.of(context).pop();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Les deux mots de passe ne correspondent pas.'),
                        duration: Duration(seconds: 4),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                },
                child: Text('Accéder à la page de connexion'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _mettreAJourMotDePasse() async {
    final url = 'http://${AppConfig.ipAddress}/PHP/inscription2.php';

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'email': emailController.text,
          'newPassword': newPasswordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['success']),
            duration: Duration(seconds: 4),
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => ConnexionPage(),
          ),
        );
      } else {
        final Map<String, dynamic> data = jsonDecode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['error']),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de connexion: $e'),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> inscription() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Veuillez remplir tous les champs obligatoires.'),
          duration: Duration(seconds: 4),
        ),
      );
      return;
    }

    final url = 'http://${AppConfig.ipAddress}/PHP/inscription2.php';

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'email': emailController.text,
          'password': passwordController.text,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['success']),
            duration: Duration(seconds: 4),
          ),
        );

        _showChangePasswordDialog();
      } else {
        final Map<String, dynamic> data = jsonDecode(response.body);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['error']),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de connexion: $e'),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null,
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20.0, 30.0, 20.0, 20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 0),
                Container(
                  height: 150.0,
                  width: 150.0,
                  margin: const EdgeInsets.only(bottom: 0.0),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('pieces_jointe/ico/logconnectservices.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                SizedBox(height: 40),
                TextField(
                  controller: emailController,
                  onChanged: (value) {},
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: passwordController,
                  onChanged: (value) {},
                  decoration: InputDecoration(
                    labelText: 'Saisir le mot de passe fourni par l\'administrateur',
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(_isObscured ? Icons.visibility : Icons.visibility_off),
                      onPressed: () {
                        setState(() {
                          _isObscured = !_isObscured;
                        });
                      },
                    ),
                  ),
                  obscureText: _isObscured,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    inscription();
                  },
                  child: Text("S'inscrire"),
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      /*floatingActionButton: Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 60.0),
        child: Align(
          alignment: Alignment.topLeft,
          child: FloatingActionButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Icon(Icons.arrow_back),
          ),
        ),
      ),*/
    );
  }
}
