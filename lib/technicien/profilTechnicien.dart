import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config.dart';

class ProfilTechnicien extends StatefulWidget {
  final Map<String, dynamic> technicienInfo;

  ProfilTechnicien({required this.technicienInfo});

  @override
  _ProfilTechnicienState createState() => _ProfilTechnicienState();
}

class _ProfilTechnicienState extends State<ProfilTechnicien> {
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;
  late TextEditingController _cpController;
  late TextEditingController _villeController;
  late TextEditingController _adresseController;
  late TextEditingController _telephoneController;
  late List<String> _avatarList;
  String _selectedAvatarPath = '';

  @override
  void initState() {
    super.initState();
    _nomController = TextEditingController(text: widget.technicienInfo['nom']);
    _prenomController =
        TextEditingController(text: widget.technicienInfo['prenom']);
    _emailController =
        TextEditingController(text: widget.technicienInfo['email']);
    _cpController =
        TextEditingController(text: widget.technicienInfo['cp'] ?? '');
    _villeController =
        TextEditingController(text: widget.technicienInfo['ville'] ?? '');
    _adresseController =
        TextEditingController(text: widget.technicienInfo['adresse'] ?? '');
    _telephoneController =
        TextEditingController(text: widget.technicienInfo['telephone'] ?? '');
    _avatarList = [];
    _getAvatarList();
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _cpController.dispose();
    _villeController.dispose();
    _adresseController.dispose();
    _telephoneController.dispose();
    super.dispose();
  }

  Future<void> _getAvatarList() async {
    try {
      setState(() {
        _avatarList = [
          'http://${AppConfig.chemin}pieces_jointe/avatars/avatar1.jpg',
          'http://${AppConfig.chemin}pieces_jointe/avatars/avatar2.jpg',
          'http://${AppConfig.chemin}pieces_jointe/avatars/avatar3.jpg',
          'http://${AppConfig.chemin}pieces_jointe/avatars/avatar5.jpg',
          'http://${AppConfig.chemin}pieces_jointe/avatars/avatar6.jpg',
          'http://${AppConfig.chemin}pieces_jointe/avatars/avatar7.jpg',
          'http://${AppConfig.chemin}pieces_jointe/avatars/avatar8.jpg',
        ];
      });
    } catch (e) {
      print('Error fetching avatar list: $e');
    }
  }

  void _updateNomTextToUpperCase() {
    final text = _nomController.text.toUpperCase();
    if (_nomController.text != text) {
      _nomController.value = _nomController.value.copyWith(
        text: text,
        selection: TextSelection(
          baseOffset: text.length,
          extentOffset: text.length,
        ),
        composing: TextRange.empty,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    _showAvatarBubble();
                  },
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _selectedAvatarPath.isNotEmpty
                        ? NetworkImage(_selectedAvatarPath)
                        : widget.technicienInfo['chemin'] != null &&
                                widget.technicienInfo['chemin'] != ''
                            ? NetworkImage('http://${AppConfig.chemin}/' +
                                widget.technicienInfo['chemin'])
                            : AssetImage(
                                    'pieces_jointe/avatars/placeholder.jpg')
                                as ImageProvider<Object>,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _nomController,
                        decoration: const InputDecoration(
                          labelText: 'Nom',
                          prefixIcon: Icon(Icons.person),
                        ),
                        onChanged: (_) {
                          _updateNomTextToUpperCase();
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _prenomController,
                        decoration: const InputDecoration(
                          labelText: 'Prénom',
                          prefixIcon: Icon(Icons.person),
                        ),
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _cpController,
                        decoration: InputDecoration(
                          labelText: 'Code postal',
                          prefixIcon: Icon(Icons.location_on),
                        ),
                      ),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _villeController,
                        decoration: InputDecoration(
                          labelText: 'Ville',
                          prefixIcon: Icon(Icons.location_city),
                        ),
                      ),
                    ),
                  ],
                ),
                TextFormField(
                  controller: _adresseController,
                  decoration: InputDecoration(
                    labelText: 'Adresse',
                    prefixIcon: Icon(Icons.home),
                  ),
                ),
                TextFormField(
                  controller: _telephoneController,
                  decoration: InputDecoration(
                    labelText: 'Téléphone',
                    prefixIcon: Icon(Icons.phone),
                  ),
                ),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: Text('Enregistrer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAvatarBubble() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Sélectionner un Avatar'),
          children: <Widget>[
            Container(
              height: 100,
              width: double.maxFinite,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: <Widget>[
                    SizedBox(width: 8.0),
                    ..._avatarList.map((avatarUrl) {
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedAvatarPath = avatarUrl;
                          });
                          Navigator.pop(context);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CircleAvatar(
                            radius: 30,
                            backgroundImage: NetworkImage(avatarUrl),
                          ),
                        ),
                      );
                    }).toList(),
                    SizedBox(width: 8.0),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _submitForm() async {
    String idUtilisateur = widget.technicienInfo['id_utilisateur'].toString();
    String nom = _nomController.text;
    String prenom = _prenomController.text;
    String email = _emailController.text;
    String cp = _cpController.text;
    String ville = _villeController.text;
    String adresse = _adresseController.text;
    String telephone = _telephoneController.text;
    String selectedAvatarPath = _selectedAvatarPath.replaceAll('http://${AppConfig.chemin}', '');


    Map<String, dynamic> data = {
      'id_utilisateur': idUtilisateur,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'avatar': selectedAvatarPath,
      'cp': cp,
      'ville': ville,
      'adresse': adresse,
      'telephone': telephone,
    };

    String jsonData = jsonEncode(data);

    final response = await http.put(
      Uri.parse('http://${AppConfig.ipAddress}/PHP/profilTechnicien.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonData,
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      String message = jsonResponse['message'];
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Mise à jour'),
            content: Text(message),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Erreur'),
            content: Text('Erreur lors de la mise à jour du profil'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
