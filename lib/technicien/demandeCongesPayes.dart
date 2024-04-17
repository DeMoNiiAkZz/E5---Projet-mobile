import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DemandeCongePage extends StatefulWidget {
  final Map<String, dynamic> technicienInfo;
  final Map<String, dynamic> intervention;
  final void Function() refreshInterventionData;

  const DemandeCongePage({
    required this.technicienInfo,
    required this.intervention,
    required this.refreshInterventionData,
  });

  @override
  _DemandeCongePageState createState() => _DemandeCongePageState();
}

class _DemandeCongePageState extends State<DemandeCongePage> {
  String _selectedMotif = 'Vacances';
  TextEditingController _autreMotifController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demande de congé'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Text(
                    'Motif :',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 56, 56, 56),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButton<String>(
                      value: _selectedMotif,
                      onChanged: (value) {
                        setState(() {
                          _selectedMotif = value!;
                        });
                      },
                      style: const TextStyle(color: Colors.black, fontSize: 16),
                      items: ['Vacances', 'Maladie', 'Autre']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 56, 56, 56),
                            ),
                          ),
                        );
                      }).toList(),
                      dropdownColor: Colors.white,
                      elevation: 8,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down),
                    ),
                  ),
                ],
              ),
              if (_selectedMotif == 'Autre') ...[
                const SizedBox(height: 20),
                const Text(
                  'Raison du motif :',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 56, 56, 56),
                  ),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _autreMotifController,
                  decoration: const InputDecoration(
                    hintText: 'Saisir la raison du motif',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Text(
                'Date de début : ${_startDate != null ? _formatDate(_startDate!) : 'Non sélectionnée'}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 56, 56, 56),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _selectStartDate,
                icon: Icon(Icons.calendar_today),
                label: Text('Sélectionner la date de début'),
              ),
              const SizedBox(height: 20),
              Text(
                'Date de fin : ${_endDate != null ? _formatDate(_endDate!) : 'Non sélectionnée'}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 56, 56, 56),
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: _selectEndDate,
                icon: Icon(Icons.calendar_today),
                label: Text('Sélectionner la date de fin'),
              ),
              const SizedBox(height: 60),
              ElevatedButton.icon(
                onPressed: _submitDemandeConge,
                icon: Icon(Icons.send),
                label: Text('Soumettre la demande'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectStartDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (pickedDate != null && pickedDate != _startDate) {
      setState(() {
        _startDate = pickedDate;
      });
    }
  }

  void _selectEndDate() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (pickedDate != null && pickedDate != _endDate) {
      setState(() {
        _endDate = pickedDate;
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('EEEE d MMMM y', 'fr_FR').format(date);
  }

  void _submitDemandeConge() async {
    if (_selectedMotif.isEmpty ||
        (_selectedMotif == 'Autre' && _autreMotifController.text.isEmpty) ||
        _startDate == null ||
        _endDate == null) {
      _errorMess(context, 'Tous les champs doivent être remplis. 🙁');
      return;
    }
    Map<String, dynamic> data = {
      'selectedMotif': _selectedMotif,
      'autreMotif': _selectedMotif == 'Autre' ? _autreMotifController.text : '',
      'startDate': _startDate!.toIso8601String(),
      'endDate': _endDate!.toIso8601String(),
      'id_technicien': widget.technicienInfo['id_utilisateur'].toString(),
    };
    String jsonData = jsonEncode(data);

    final response = await http.post(
      Uri.parse(
          'http://${AppConfig.ipAddress}/PHP/demandeConges.php'),
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
      String erreur = jsonResponse['erreur'];
      _errorMess(context, erreur);
    }
  }

  @override
  void dispose() {
    _autreMotifController.dispose();
    super.dispose();
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
