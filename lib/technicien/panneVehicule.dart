import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/config.dart';

class PanneEntretienPage extends StatefulWidget {
  final Map<String, dynamic> technicienInfo;
  final List<Map<String, dynamic>> vehicules;

  const PanneEntretienPage({
    required this.technicienInfo,
    required this.vehicules,
  });

  @override
  _PanneEntretienPageState createState() => _PanneEntretienPageState();
}

class _PanneEntretienPageState extends State<PanneEntretienPage> {
  late Map<String, dynamic> selectedVehicle;
  final TextEditingController descriptionController = TextEditingController();
  String? selectedType;

  @override
  void initState() {
    super.initState();
    selectedVehicle = widget.vehicules.isNotEmpty ? widget.vehicules.first : {};
  }

  Future<void> envoyerPanne(BuildContext context) async {
    final String description = descriptionController.text.trim();
    final String type = selectedType ?? '';

    if (description.isEmpty) {
      _showErrorMess(context, "Veuillez entrer une description !");
      return;
    }

    print('Type: $type');
    print('Description: $description');
    print('ID Véhicule: ${selectedVehicle['id_vehicule']}');
    print('ID Utilisateur: ${widget.technicienInfo['id_utilisateur']}');

    final Map<String, dynamic> requestBody = {
      'type': type,
      'description': description,
      'id_vehicule': selectedVehicle['id_vehicule'],
      'id_utilisateur': widget.technicienInfo['id_utilisateur'],
    };

    final String requestBodyJson = jsonEncode(requestBody);

    final response = await http.post(
      Uri.parse('http://${AppConfig.ipAddress}/PHP/entretienVehicule.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: requestBodyJson,
    );

    final jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final String message = jsonResponse['message'];
      _showSuccessMess(context, message);
    } else {
      final String erreur = jsonResponse['error'];
      _showErrorMess(context, erreur);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Panne et Entretien'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButton<Map<String, dynamic>>(
              value: selectedVehicle,
              items: widget.vehicules.map((vehicle) {
                return DropdownMenuItem<Map<String, dynamic>>(
                  value: vehicle,
                  child: Text(
                    '${vehicle['immatriculation']} - ${vehicle['marque']} - ${vehicle['modele']}',
                  ),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedVehicle = newValue!;
                });
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedType,
              items: ['Panne', 'Entretien'].map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  selectedType = newValue;
                });
              },
              decoration: InputDecoration(
                labelText: 'Type de panne/entretien',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description de la panne/entretien',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                envoyerPanne(context);
              },
              child: Text('Envoyer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSuccessMess(BuildContext context, String message) {
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

  void _showErrorMess(BuildContext context, String errorMessage) {
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
