import 'package:flutter/material.dart';
import 'miseAjourVehicule.dart';
import 'panneVehicule.dart';

class EntretienVehicule extends StatelessWidget {
  final Map<String, dynamic> technicienInfo;
  final Map<String, dynamic> intervention;
  final List<Map<String, dynamic>> vehicules;
  final void Function() refreshInterventionData;

  const EntretienVehicule({
    required this.technicienInfo,
    required this.intervention,
    required this.vehicules,
    required this.refreshInterventionData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entretien du Véhicule'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCard(
              context,
              title: 'Mettre à jour le kilométrage',
              icon: Icons.directions_car,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MiseAjourKilometragePage(
                      technicienInfo: technicienInfo,
                      vehicules: vehicules,
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildCard(
              context,
              title: 'Panne et entretien',
              icon: Icons.build,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PanneEntretienPage(
                      technicienInfo: technicienInfo,
                      vehicules: vehicules,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context,
      {required String title,
      required IconData icon,
      required VoidCallback onPressed}) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 36, color: Colors.blue),
              const SizedBox(width: 16),
              Text(
                title,
                style: TextStyle(fontSize: 18, color: Colors.grey[800]),
              ),
              const Spacer(),
              const Icon(Icons.arrow_forward),
            ],
          ),
        ),
      ),
    );
  }
}
