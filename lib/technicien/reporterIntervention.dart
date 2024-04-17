import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/config.dart';
import 'package:intl/intl.dart';

class ReportInterventionPage extends StatefulWidget {
  final Map<String, dynamic> intervention;
  final void Function() refreshInterventionData;

  const ReportInterventionPage({
    required this.intervention,
    required this.refreshInterventionData,
  });

  @override
  _ReportInterventionPageState createState() => _ReportInterventionPageState();
}

class _ReportInterventionPageState extends State<ReportInterventionPage> {
  late DateTime _selectedDateTime;

  @override
  void initState() {
    super.initState();
    _selectedDateTime = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reporter l\'intervention',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 100.0,
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 20.0),
            ElevatedButton.icon(
              onPressed: () {
                _selectDateTime(context);
              },
              icon:const Icon(Icons.event),
              label: const Text(
                'Sélectionner la date et l\'heure',
                style: TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 20.0),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'Intervention reportée pour ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  DateFormat('EEEE dd MMMM yyyy à HH:mm', 'fr_FR')
                      .format(_selectedDateTime),
                  style: const TextStyle(fontSize: 20),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const SizedBox(height: 20.0),
            ElevatedButton.icon(
              onPressed: _reportIntervention,
              icon: const Icon(Icons.send),
              label: const Text(
                'Reporter',
                style: TextStyle(fontSize: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      locale: Locale('fr'),
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      TimeOfDay? timePicked = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );

      if (timePicked != null) {
        setState(() {
          _selectedDateTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            timePicked.hour,
            timePicked.minute,
          );
        });
        String formattedDateTime =
            '${_selectedDateTime.year}-${_selectedDateTime.month.toString().padLeft(2, '0')}-${_selectedDateTime.day.toString().padLeft(2, '0')} ${_selectedDateTime.hour.toString().padLeft(2, '0')}:${_selectedDateTime.minute.toString().padLeft(2, '0')}:${_selectedDateTime.second.toString().padLeft(2, '0')}';
        print(formattedDateTime);
      }
    }
  }

  void _reportIntervention() async {
    String formattedDateTime =
        '${_selectedDateTime.year}-${_selectedDateTime.month.toString().padLeft(2, '0')}-${_selectedDateTime.day.toString().padLeft(2, '0')} ${_selectedDateTime.hour.toString().padLeft(2, '0')}:${_selectedDateTime.minute.toString().padLeft(2, '0')}:${_selectedDateTime.second.toString().padLeft(2, '0')}';

    Map<String, dynamic> data = {
      'id_intervention': widget.intervention['id_intervention'],
      'new_datetime': formattedDateTime,
    };
    String jsonData = jsonEncode(data);

    final response = await http.put(
      Uri.parse(
          'http://${AppConfig.ipAddress}/PHP/reportIntervention.php'),
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
            title: Text(
              'Succès',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10),
                Text(
                  message,
                  style: TextStyle(fontSize: 18),
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  widget.refreshInterventionData();
                },
                child: Text('OK',
                    style: TextStyle(
                        color: Color.fromARGB(255, 38, 98, 183), fontSize: 18)),
              ),
            ],
          );
        },
      );
    } else {
      String errorMessage = response.body;
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Erreur',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            content: Text(
              errorMessage,
              style: TextStyle(fontSize: 18),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                  widget.refreshInterventionData();
                },
                child: Text('OK', style: TextStyle(fontSize: 18)),
              ),
            ],
          );
        },
      );
    }
    widget.refreshInterventionData();
  }
}
