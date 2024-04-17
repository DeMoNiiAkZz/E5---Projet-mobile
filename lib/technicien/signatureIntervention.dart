import 'dart:convert';
import 'dart:typed_data';
import '/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:signature/signature.dart';

class SignaturePage extends StatefulWidget {
  final Map<String, dynamic> intervention;
  final void Function() refreshInterventionData;

  SignaturePage({
    required this.intervention,
    required this.refreshInterventionData,
  });

  @override
  _SignaturePageState createState() => _SignaturePageState();
}

class _SignaturePageState extends State<SignaturePage> {
  final SignatureController _technicianController = SignatureController();
  final SignatureController _clientController = SignatureController();

  String? technicianImageBase64;
  String? clientImageBase64;

  Future<void> _sendSignatures() async {
    Uint8List? technicianBytes = await _technicianController.toPngBytes();
    Uint8List? clientBytes = await _clientController.toPngBytes();

    if (clientBytes == null) {
      _errorMess(
          context, 'Il faut la signature du client pour valider. 🙁');
      return;
    }

    Map<String, dynamic> data = {
      'technicien_image':
          technicianBytes != null ? base64Encode(technicianBytes) : null,
      'client_image': base64Encode(clientBytes),
      'id_intervention': widget.intervention['id_intervention'].toString(),
      'id_technicien': widget.intervention['id_technicien'].toString(),
      'id_utilisateur': widget.intervention['id_utilisateur'].toString(),
    };
    String jsonData = jsonEncode(data);
    var response = await http.post(
      Uri.parse('http://${AppConfig.ipAddress}/PHP/signature.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonData,
    );
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    if (response.statusCode == 200) {
      String message = jsonResponse['message'];
      _successMess(context, message);
    } else {
      String erreur = jsonResponse['error'];
      _errorMess(context, erreur);
    }
    widget.refreshInterventionData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Signatures'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Signature Client',
                style: TextStyle(fontSize: 20),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: Signature(
                  controller: _clientController,
                  height: 200,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _clientController.clear();
                    },
                    child: const Text('Effacer'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              const Text(
                'Signature Technicien (facultatif)',
                style: TextStyle(fontSize: 20),
              ),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                ),
                child: Signature(
                  controller: _technicianController,
                  height: 200,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _technicianController.clear();
                    },
                    child: Text('Effacer'),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _sendSignatures,
                child: Text('Valider et Envoyer'),
              ),
            ],
          ),
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
