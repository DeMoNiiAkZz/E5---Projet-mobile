import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '/config.dart';

class CRI extends StatefulWidget {
  final Map<String, dynamic> intervention;
  final void Function() refreshInterventionData;

  CRI({
    required this.intervention,
    required this.refreshInterventionData,
  });

  @override
  _CRIState createState() => _CRIState();
}

class _CRIState extends State<CRI> {
  TextEditingController actionsEffectueesController = TextEditingController();
  TextEditingController equipementsUtilisesController = TextEditingController();
  TextEditingController problemesRencontresController = TextEditingController();
  TextEditingController observationsController = TextEditingController();

  @override
  void dispose() {
    actionsEffectueesController.dispose();
    equipementsUtilisesController.dispose();
    problemesRencontresController.dispose();
    observationsController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _getInfosCri();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compte Rendu'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Toutes les saisies doivent être justifiées et détaillées :',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              SizedBox(height: 20),
              _buildTextFieldWithTitle(
                  'Actions Effectuées',
                  'Description des actions effectuées',
                  actionsEffectueesController),
              SizedBox(height: 20),
              _buildTextFieldWithTitle(
                  'Equipements Utilisés',
                  'Liste des équipements utilisés',
                  equipementsUtilisesController),
              SizedBox(height: 20),
              _buildTextFieldWithTitle(
                  'Problèmes Rencontrés',
                  'Description des problèmes rencontrés',
                  problemesRencontresController),
              SizedBox(height: 20),
              _buildTextFieldWithTitle('Observations',
                  'Observations et recommandations', observationsController),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _compteRendu,
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Center(
                    child: const Text('Enregistrer',
                        style: TextStyle(fontSize: 18)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextFieldWithTitle(
      String title, String hintText, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        SizedBox(height: 10),
        TextField(
          controller: controller,
          maxLines: 5,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(),
            filled: true,
            fillColor: Colors.grey[200],
          ),
        ),
      ],
    );
  }

  void _getInfosCri() async {
    final response = await http.get(
      Uri.parse(
          'http://${AppConfig.ipAddress}/PHP/CRI.php?id_intervention=${widget.intervention['id_intervention']}'),
    );
    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData.containsKey('actions')) {
        setState(() {
          actionsEffectueesController.text = responseData['actions'];
        });
      }
      if (responseData.containsKey('equipements')) {
        setState(() {
          equipementsUtilisesController.text = responseData['equipements'];
        });
      }
      if (responseData.containsKey('problemes')) {
        setState(() {
          problemesRencontresController.text = responseData['problemes'];
        });
      }
      if (responseData.containsKey('observations')) {
        setState(() {
          observationsController.text = responseData['observations'];
        });
      }
    } else {
      print(
          'Erreur de serveur (${response.statusCode}) lors de la récupération des informations du compte rendu.');
    }
  }

  void _compteRendu() async {
    if (actionsEffectueesController.text.isEmpty ||
        equipementsUtilisesController.text.isEmpty ||
        problemesRencontresController.text.isEmpty ||
        observationsController.text.isEmpty) {
      _errorMess(
          context, 'Il semblerait que tous les champs ne sont pas remplis. 🙁');
      return;
    }
    Map<String, dynamic> data = {
      'id_intervention': widget.intervention['id_intervention'],
      'id_technicien': widget.intervention['id_technicien'],
      'actions_effectuees': actionsEffectueesController.text,
      'equipements_utilises': equipementsUtilisesController.text,
      'problemes_rencontres': problemesRencontresController.text,
      'observations': observationsController.text,
    };
    print('Données envoyées depuis Flutter : $data');
    String jsonData = json.encode(data);

    final response = await http.post(
      Uri.parse('http://${AppConfig.ipAddress}/PHP/CRI.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonData,
    );
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      String message = jsonResponse['message'];
      _successMess(context, message);
    } else {
      _errorMess(context, 'Erreur de serveur (${response.statusCode})');
    }
    widget.refreshInterventionData();
  }

  void _successMess(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: const Text(
            'Succès',
            style: TextStyle(
              color: Color.fromARGB(255, 39, 165, 43),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: Text(
            message,
            style: const TextStyle(
              color: Color.fromARGB(255, 21, 21, 21),
              fontSize: 18,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.blue, fontSize: 18),
              ),
            ),
          ],
        );
      },
    );
    widget.refreshInterventionData();
  }

  void _errorMess(BuildContext context, String errorMessage) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: const Text(
            'Erreur',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: Text(
            errorMessage,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.blue, fontSize: 18),
              ),
            ),
          ],
        );
      },
    );
    widget.refreshInterventionData();
  }
}
