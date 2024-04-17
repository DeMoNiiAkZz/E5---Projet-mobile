import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/config.dart';

class Signaler extends StatelessWidget {
  final Map<String, dynamic> technicienInfo;
  final void Function() refreshInterventionData;

  const Signaler({
    required this.technicienInfo,
    required this.refreshInterventionData,
  });

  Future<void> envoyerSignalement(
      String motif, String description, BuildContext context) async {
    if (motif.isEmpty || description.isEmpty) {
     _errorMess(context, "Tous les champs doivent être remplis !");
      return;
    }

    Map<String, dynamic> requestBody = {
      'motif': motif,
      'description': description,
      'id_utilisateur': technicienInfo['id_utilisateur'],
    };
    String requestBodyJson = jsonEncode(requestBody);

    final response = await http.post(
      Uri.parse(
          'http://${AppConfig.ipAddress}/PHP/signaler.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: requestBodyJson,
    );
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    if (response.statusCode == 200) {
      String message = jsonResponse['message'];
      _successMess(context, message);
    } else {
      String erreur = jsonResponse['error'];
      _errorMess(context, erreur);
    }
  }

  @override
  Widget build(BuildContext context) {
    String? motif;
    String? description;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Signaler un problème'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Motif du problème:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              items: <String>['Client absent', 'Panne', 'Oublie']
                  .map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                motif = newValue;
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'Description du problème:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            TextFormField(
              maxLines: null,
              onChanged: (value) {
                description = value;
              },
              decoration: const InputDecoration(
                hintText: 'Entrez la description du problème...',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                envoyerSignalement(motif ?? '', description ?? '', context);
              },
              child: Text('Envoyer le signalement'),
            ),
          ],
        ),
      ),
    );
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
  }
}
