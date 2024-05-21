import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'config.dart';
import 'technicien/accueilTechnicien.dart';
import 'politique_confidentialite.dart';

class ConnexionPage extends StatefulWidget {
  @override
  _ConnexionPageState createState() => _ConnexionPageState();
}

class _ConnexionPageState extends State<ConnexionPage> {
  String _pseudoEmailError = '';
  String _motDePasseError = '';
  bool _isObscure = true;

  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _motDePasseController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _submitForm() async {
    setState(() {
      _pseudoEmailError = '';
      _motDePasseError = '';
    });

    if (_loginController.text.isEmpty) {
      setState(() {
        _pseudoEmailError = 'Le champ Email est requis.';
      });
    }

    if (_motDePasseController.text.isEmpty) {
      setState(() {
        _motDePasseError = 'Le champ Mot de passe est requis.';
      });
    }

    if (_loginController.text.isEmpty || _motDePasseController.text.isEmpty) {
      _showSnackBar('Veuillez remplir tous les champs.');
      return;
    }

    Map<String, dynamic> data = {
      'login': _loginController.text,
      'password': _motDePasseController.text,
    };

    String jsonData = json.encode(data);

    final response = await http.post(
      Uri.parse('http://${AppConfig.ipAddress}/PHP/connexion.php'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonData,
    );

    print('Réponse de l\'API : ${response.body}');
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('message')) {
        _showSnackBar(responseData['message']);

        int idType = responseData['id_type'];
        int idUser = responseData['id_utilisateur'];

        if (idType == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => AccueilTechnicien(userId: idUser),
            ),
          );
        } else if (idType == 3) {
        } else {
          _showSnackBar('Type d\'utilisateur non géré');
        }
      } else {
        _showSnackBar('Réponse inattendue.');
      }
    } else if (response.statusCode == 401) {
      final Map<String, dynamic> responseData = json.decode(response.body);

      if (responseData.containsKey('error')) {
        if (responseData['errorpseudo'] == 'L\'adresse mail n\'existe pas.') {
          _showSnackBar('Email inexistant');
        } else if (responseData['errorpassword'] == 'Mot de passe incorrect') {
          _showSnackBar('Mot de passe incorrect');
        } else {
          _showSnackBar(responseData['error']);
        }
      } else {
        _showSnackBar('Identifiants incorrects');
      }
    }
  }

  void _showSnackBar(String message) {
    print('salut');
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(''),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  height: 150.0,
                  width: 150.0,
                  margin: const EdgeInsets.only(bottom: 20.0),
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(
                          'http://${AppConfig.chemin}pieces_jointe/ico_mobile/logconnectservices.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                TextField(
                  controller: _loginController,
                  decoration: InputDecoration(
                    labelText: 'E-mail',
                    prefixIcon: const Icon(Icons.person),
                    errorText:
                        _pseudoEmailError.isNotEmpty ? _pseudoEmailError : null,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _motDePasseController,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isObscure ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isObscure = !_isObscure;
                        });
                      },
                    ),
                    errorText:
                        _motDePasseError.isNotEmpty ? _motDePasseError : null,
                  ),
                  obscureText: _isObscure,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text('Se connecter'),
                ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PrivacyPolicyPage()),
                    );
                  },
                  child: Text("Voir la politique de confidentialité"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}