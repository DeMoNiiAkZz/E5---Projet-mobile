import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import '/config.dart';
import 'dart:convert';
import 'reporterIntervention.dart';
import 'imageIntervention.dart';
import 'documentsIntervention.dart';
import 'CompteRenduInter.dart';
import 'signatureIntervention.dart';

class InterventionDetails extends StatefulWidget {
  final Map<String, dynamic> intervention;
  final void Function() refreshInterventionData;

  const InterventionDetails({
    required this.intervention,
    required this.refreshInterventionData,
  });

  @override
  _InterventionDetailsState createState() => _InterventionDetailsState();
}

class _InterventionDetailsState extends State<InterventionDetails>
    with SingleTickerProviderStateMixin {
  bool _showClientDetails = false;
  bool _showInterventionDetails = false;
  bool _showAttachments = false;
  bool _showCompteRenduDetails = false;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de l\'intervention'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildCategoryHeader(
              'Intervention',
              _showInterventionDetails,
              Icons.build_rounded,
              () {
                setState(() {
                  _showInterventionDetails = !_showInterventionDetails;
                  if (_showInterventionDetails) {
                    _animationController.forward();
                  } else {
                    _animationController.reverse();
                  }
                });
              },
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: _showInterventionDetails
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: SizeTransition(
                axisAlignment: 1.0,
                sizeFactor: CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.fastOutSlowIn,
                ),
                child: _InterventionsDetails(),
              ),
              secondChild: const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),
            _buildCategoryHeader(
              'Client',
              _showClientDetails,
              Icons.account_circle,
              () {
                setState(() {
                  _showClientDetails = !_showClientDetails;
                  if (_showClientDetails) {
                    _animationController.forward();
                  } else {
                    _animationController.reverse();
                  }
                });
              },
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: _showClientDetails
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: SizeTransition(
                axisAlignment: 1.0,
                sizeFactor: CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.fastOutSlowIn,
                ),
                child: _ClientDetails(),
              ),
              secondChild: const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),
            _buildCategoryHeader(
              'Compte rendu',
              _showCompteRenduDetails,
              Icons.description,
              () {
                setState(() {
                  _showCompteRenduDetails = !_showCompteRenduDetails;
                  if (_showCompteRenduDetails) {
                    _animationController.forward();
                  } else {
                    _animationController.reverse();
                  }
                });
              },
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: _showCompteRenduDetails
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: SizeTransition(
                axisAlignment: 1.0,
                sizeFactor: CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.fastOutSlowIn,
                ),
                child: _CompteRenduDetails(),
              ),
              secondChild: const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),
            _buildCategoryHeader(
              'Pièces jointes',
              _showAttachments,
              Icons.attach_file,
              () {
                setState(() {
                  _showAttachments = !_showAttachments;
                  if (_showAttachments) {
                    _animationController.forward();
                  } else {
                    _animationController.reverse();
                  }
                });
              },
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: _showAttachments
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              firstChild: SizeTransition(
                axisAlignment: 1.0,
                sizeFactor: CurvedAnimation(
                  parent: _animationController,
                  curve: Curves.fastOutSlowIn,
                ),
                child: _PiecesJointes(),
              ),
              secondChild: const SizedBox.shrink(),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: (widget.intervention['statut'] == 'A faire' ||
              widget.intervention['statut'] == 'En cours')
          ? Container(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.intervention['statut'] == 'A faire')
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _startIntervention();
                        },
                        child: const Text(
                          'Démarrer mon intervention',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  if (widget.intervention['statut'] == 'En cours')
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          _endIntervention();
                        },
                        child: const Text(
                          'J\'ai fini mon intervention',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReportInterventionPage(
                              intervention: widget.intervention,
                              refreshInterventionData:
                                  widget.refreshInterventionData,
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'Reporter mon intervention',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }

  void _startIntervention() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: const Text(
            'Confirmation',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: const Text(
            'Êtes-vous sûr de vouloir démarrer votre intervention ?',
            style: TextStyle(
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
                'Annuler',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                _modifyInterventionStatus("En cours", context);
              },
              child: const Text(
                'Confirmer',
                style: TextStyle(color: Colors.blue, fontSize: 18),
              ),
            ),
          ],
        );
      },
    );
  }

  void _endIntervention() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: const Text(
            'Confirmation',
            style: TextStyle(
              color: Colors.blue,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          content: const Text(
            'Êtes-vous sûr de finaliser votre intervention ?',
            style: TextStyle(
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
                'Annuler',
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                _modifyInterventionStatus("Terminée", context);
              },
              child: const Text(
                'Confirmer',
                style: TextStyle(color: Colors.blue, fontSize: 18),
              ),
            ),
          ],
        );
      },
    );
  }

  void _modifyInterventionStatus(String statut, BuildContext context) async {
    Map<String, dynamic> data = {
      'id_intervention': widget.intervention['id_intervention'],
      'nouveau_statut': statut,
      'id_technicien': widget.intervention['id_technicien'],
    };
    String jsonData = jsonEncode(data);
    final response = await http.put(
      Uri.parse('http://${AppConfig.ipAddress}/PHP/statutIntervention.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonData,
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);
      String message = jsonResponse['message'];
      _showSuccessDialog(context, message);
    } else {
      String errorMessage = response.body;
      _showErrorDialog(context, errorMessage);
    }
    widget.refreshInterventionData();
  }

  void _showSuccessDialog(BuildContext context, String message) {
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
    widget.refreshInterventionData();
  }

  void _showErrorDialog(BuildContext context, String errorMessage) {
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

  Widget _buildCategoryHeader(
      String title, bool isExpanded, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          color: Colors.blue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: Colors.blue,
                  size: 30,
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            Icon(
              isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: Colors.blue,
              size: 30,
            ),
          ],
        ),
      ),
    );
  }

  Widget _ClientDetails() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            title: Text(
              'Informations client',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text(
              'Nom',
              style: TextStyle(fontSize: 16),
            ),
            subtitle: Text(
              '${widget.intervention['nom_utilisateur']} ${widget.intervention['prenom_utilisateur']}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            title: const Text(
              'Email',
              style: TextStyle(fontSize: 16),
            ),
            subtitle: Text(
              widget.intervention['email_utilisateur'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            title: const Text(
              'Téléphone',
              style: TextStyle(fontSize: 16),
            ),
            subtitle: Text(
              widget.intervention['telephone_utilisateur'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            title: const Text(
              'Adresse',
              style: TextStyle(fontSize: 16),
            ),
            subtitle: Text(
              '${widget.intervention['adresse_utilisateur']}, ${widget.intervention['cp_utilisateur']} ${widget.intervention['ville_utilisateur']}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            title: ElevatedButton(
              onPressed: _launchMap,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors
                    .transparent,
                shadowColor: Colors.transparent,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.red,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Voir la map',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _InterventionsDetails() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            title: Text(
              'Détails intervention',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),
          ListTile(
            title: const Text(
              'Catégorie',
              style: TextStyle(fontSize: 16),
            ),
            subtitle: Text(
              widget.intervention['categorie'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            title: const Text(
              'Heure',
              style: TextStyle(fontSize: 16),
            ),
            subtitle: Text(
              formatHeure(widget.intervention['date_intervention']),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            title: const Text(
              'Durée prévue',
              style: TextStyle(fontSize: 16),
            ),
            subtitle: Text(
              formatDuree(widget.intervention['duree_intervention']),
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            title: const Text(
              'Description',
              style: TextStyle(fontSize: 16),
            ),
            subtitle: Text(
              widget.intervention['description'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            title: const Text(
              'Statut',
              style: TextStyle(fontSize: 16),
            ),
            subtitle: Text(
              widget.intervention['statut'],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _CompteRenduDetails() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            title: Text(
              'Compte rendu intervention',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),
          ListTile(
            title: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CRI(
                      intervention: widget.intervention,
                      refreshInterventionData: widget.refreshInterventionData,
                    ),
                  ),
                );
              },
              child: const Text(
                'Détails de l\'intervention',
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ),
          ),
          ListTile(
            title: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SignaturePage(
                        intervention: widget.intervention,
                        refreshInterventionData: widget.refreshInterventionData,
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Signature technicien et client',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                )),
          ),
        ],
      ),
    );
  }

  Widget _PiecesJointes() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const ListTile(
            title: Text(
              'Pièces jointes',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const Divider(),
          ListTile(
            title: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ImagesPage(
                      intervention: widget.intervention,
                      refreshInterventionData: widget.refreshInterventionData,
                    ),
                  ),
                );
              },
              child: const Text(
                'Photos',
                style: TextStyle(
                  fontSize: 16.0,
                ),
              ),
            ),
          ),
          ListTile(
            title: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DocumentsPage(
                        intervention: widget.intervention,
                        refreshInterventionData: widget.refreshInterventionData,
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Documents',
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                )),
          ),
        ],
      ),
    );
  }

  String formatDuree(String duration) {
    List<String> parts = duration.split(':');
    int hours = int.parse(parts[0]);
    int minutes = int.parse(parts[1]);

    String formattedDuration = '';
    if (hours > 0) {
      formattedDuration += '$hours heure${hours > 1 ? 's' : ''}';
      if (minutes > 0) {
        formattedDuration += ' ';
      }
    }
    if (minutes > 0) {
      formattedDuration += '$minutes minute${minutes > 1 ? 's' : ''}';
    }
    return formattedDuration;
  }

  String formatHeure(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    String heure = dateTime.hour.toString().padLeft(2, '0');
    String minute = dateTime.minute.toString().padLeft(2, '0');
    return '$heure:$minute';
  }

  void _launchMap() async {
    String fullAddress =
        '${widget.intervention['adresse_utilisateur']} ${widget.intervention['cp_utilisateur']} ${widget.intervention['ville_utilisateur']}';

    fullAddress = fullAddress.replaceAll(' ', '%20');

    String googleMapsUrl =
        "https://www.google.com/maps/search/?api=1&query=$fullAddress";

    try {
      await launch(
        googleMapsUrl,
        forceWebView: true,
      );
    } catch (e) {
      print('Erreur lors de l\'ouverture de Google Maps : $e');
    }
  }
}
