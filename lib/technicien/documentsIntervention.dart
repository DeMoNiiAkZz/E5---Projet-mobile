import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '/config.dart';

class DocumentsPage extends StatefulWidget {
  final Map<String, dynamic> intervention;
  final void Function() refreshInterventionData;

  const DocumentsPage({
    required this.intervention,
    required this.refreshInterventionData,
  });

  @override
  _DocumentsPageState createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  List<String>? _serverPDF;
  List<String>?
      _serverFiche; 
  bool _showPlans = true;
  bool _showFiches = true;

  @override
  void initState() {
    super.initState();
    _voirPlans();
    _voirFiche(); 
  }

  void _voirPlans() async {
    final response = await http.get(
      Uri.parse(
          'http://${AppConfig.ipAddress}/PHP/planIntervention.php?id_intervention=${widget.intervention['id_intervention'].toString()}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      setState(() {
        _serverPDF = List<String>.from(jsonResponse);
      });
    }
  }

  void _voirFiche() async {
    final response = await http.get(
      Uri.parse(
          'http://${AppConfig.ipAddress}/PHP/ficheTechIntervention.php?id_intervention=${widget.intervention['id_intervention'].toString()}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      setState(() {
        _serverFiche = List<String>.from(jsonResponse);
      });
    }
  }

  Future<void> _launchPDF(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Impossible de lancer $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> mergedDocuments = [];
    if (_showPlans && _serverPDF != null) mergedDocuments.addAll(_serverPDF!);
    if (_showFiches && _serverFiche != null)
      mergedDocuments.addAll(_serverFiche!);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Documents'),
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) => [
              CheckedPopupMenuItem(
                value: _showPlans,
                checked: _showPlans,
                child: Text('Plans'),
              ),
              CheckedPopupMenuItem(
                value: _showFiches,
                checked: _showFiches,
                child: Text('Fiches Techniques'),
              ),
            ],
            onSelected: (bool selected) {
              setState(() {
                if (selected == _showPlans) {
                  _showPlans = !selected;
                } else {
                  _showFiches = !selected;
                }
              });
            },
          ),
        ],
      ),
      body: mergedDocuments.isNotEmpty
          ? ListView.builder(
              itemCount: mergedDocuments.length,
              itemBuilder: (BuildContext context, int index) {
                String documentUrl = mergedDocuments[index];
                bool isPlan = index < _serverPDF!.length;

                return Card(
                  elevation: 2,
                  margin:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  child: ListTile(
                    leading: Container(
                      width: 48,
                      child: Icon(
                        isPlan ? Icons.home : Icons.description,
                        color: Colors.blue,
                        size: 36,
                      ),
                    ),
                    title: Text(
                      isPlan
                          ? 'Plan ${index + 1}'
                          : 'Fiche Technique ${index + 1 - _serverPDF!.length}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    onTap: () async {
                      await _launchPDF(documentUrl);
                    },
                  ),
                );
              },
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
