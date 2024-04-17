import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';

class MiseAjourKilometragePage extends StatefulWidget {
  final Map<String, dynamic> technicienInfo;
  final List<Map<String, dynamic>> vehicules;

  const MiseAjourKilometragePage({
    required this.technicienInfo,
    required this.vehicules,
  });

  @override
  _MiseAjourKilometragePageState createState() =>
      _MiseAjourKilometragePageState();
}

class _MiseAjourKilometragePageState extends State<MiseAjourKilometragePage> {
  late Map<String, dynamic> selectedVehicle;
  late TextEditingController kilometrageController;

  @override
  void initState() {
    super.initState();
    if (widget.vehicules.isNotEmpty) {
      selectedVehicle = widget.vehicules.first;
      kilometrageController = TextEditingController(
          text: selectedVehicle['kilometrage'].toString());
    } else {
      selectedVehicle = {};
      kilometrageController = TextEditingController();
    }
  }

  Future<void> mettreAjour(BuildContext context) async {
    final String kilometrage = kilometrageController.text;
    final int idVehicule = selectedVehicle['id_vehicule'];

    if (kilometrage.isEmpty) {
      _errorMess(context, "Veuillez entrer le kilométrage !");
      return;
    }

    final Map<String, dynamic> requestBody = {
      'kilometrage': kilometrage,
      'id_vehicule': idVehicule,
      'id_utilisateur': widget.technicienInfo['id_utilisateur'],
    };

    final String requestBodyJson = jsonEncode(requestBody);

    final response = await http.put(
      Uri.parse('http://${AppConfig.ipAddress}/PHP/entretienVehicule.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: requestBodyJson,
    );

    final jsonResponse = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final String message = jsonResponse['message'];
      _successMess(context, message);
    } else {
      final String erreur = jsonResponse['error'];
      _errorMess(context, erreur);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mise à jour du Kilométrage'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: DropdownButton<Map<String, dynamic>>(
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
                    kilometrageController.text =
                        selectedVehicle['kilometrage'].toString();
                    print(
                        'ID du véhicule sélectionné : ${selectedVehicle['id_vehicule']}');
                  });
                },
              ),
            ),
            SizedBox(height: 32),
            TextField(
              controller: kilometrageController,
              decoration: InputDecoration(
                labelText: 'Kilométrage',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                mettreAjour(context);
              },
              child: Text('Mettre à jour'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
