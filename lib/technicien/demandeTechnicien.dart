import 'package:flutter/material.dart';
import 'signaler.dart';
import 'demandeCongesPayes.dart';
import 'entretienVehicule.dart';

class DemandeTab extends StatelessWidget {
  final Map<String, dynamic> technicienInfo;
  final Map<String, dynamic> intervention;
  final List<Map<String, dynamic>> vehicules;
  final void Function() refreshInterventionData;

  const DemandeTab({
    required this.technicienInfo,
    required this.intervention,
    required this.vehicules,
    required this.refreshInterventionData,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildCard(
            context,
            title: 'Demander un congé',
            icon: Icons.calendar_today,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DemandeCongePage(
                    technicienInfo: technicienInfo,
                    intervention: intervention,
                    refreshInterventionData: refreshInterventionData,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 16),
          _buildCard(
            context,
            title: 'Entretien véhicule',
            icon: Icons.directions_car,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EntretienVehicule(
                    technicienInfo: technicienInfo,
                    intervention: intervention,
                    vehicules: vehicules,
                    refreshInterventionData: refreshInterventionData,
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 16),
          _buildCard(
            context,
            title: 'Signaler un problème',
            icon: Icons.error_outline,
            onPressed: () {
              _showProblemeIntervention(context);
            },
          ),
        ],
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
                style: TextStyle(
                    fontSize: 18, color: Colors.grey[800]), 
              ),
              const Spacer(),
              Icon(Icons.arrow_forward),
            ],
          ),
        ),
      ),
    );
  }

  void _showProblemeIntervention(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Signaler(
          technicienInfo: technicienInfo, 
          refreshInterventionData: refreshInterventionData,
        ),
      ),
    );
  }
}
