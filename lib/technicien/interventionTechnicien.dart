import 'package:flutter/material.dart';
import 'InterventionDetails.dart';
import 'package:intl/intl.dart';

class InterventionTab extends StatefulWidget {
  final Map<String, dynamic> technicienInfo;
  final Map<String, dynamic>? interventionInfo;
  final void Function() onMessageriePressed;
  final void Function() refreshInterventionData;

  const InterventionTab({
    required this.technicienInfo,
    this.interventionInfo,
    required this.onMessageriePressed,
    required this.refreshInterventionData,
  });

  @override
  _InterventionTabState createState() => _InterventionTabState();
}

class _InterventionTabState extends State<InterventionTab> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> interventions =
        _filterInterventions(_selectedDate);

    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    _selectDate(context);
                  },
                  child: Row(
                    children: [
                      Text(
                        '${DateFormat('dd/MM/yyyy', 'fr_FR').format(_selectedDate)}',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue),
                        textAlign: TextAlign.center,
                      ),
                      Icon(Icons.calendar_today, color: Colors.blue),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              itemBuilder: (context, index) {
                final date = DateTime.now().add(Duration(days: index));
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDate = date;
                    });
                  },
                  child: Container(
                    width: 70,
                    height: 70,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(35),
                      color: _isDateSelected(date)
                          ? Colors.blue
                          : Colors.transparent,
                    ),
                    margin: EdgeInsets.symmetric(horizontal: 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _getJourSemaine(date.weekday),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _isDateSelected(date)
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                        Text(
                          '${date.day}/${date.month}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _isDateSelected(date)
                                ? Colors.white
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: interventions.isNotEmpty
                ? ListView.builder(
                    itemCount: interventions.length,
                    itemBuilder: (context, index) {
                      final intervention = interventions[index];
                      final startTime =
                          formatHeure(intervention['date_intervention']);
                      final duration = intervention['duree_intervention'];
                      final endTime = calculateEndTime(startTime, duration);
                      return GestureDetector(
                        onTap: () {
                          _showInterventionDetails(context, intervention);
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 8),
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      startTime,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 5),
                                      child: Icon(Icons.arrow_downward,
                                          color: Colors.grey),
                                    ),
                                    Text(
                                      endTime,
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 10),
                                    _getStatutIconAndText(
                                        intervention['statut']),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 5,
                                child: Container(
                                  margin: const EdgeInsets.only(left: 10),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: _getCategorieColor(
                                        intervention['categorie']),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Center(
                                        child: Text(
                                          'Intervention : ${intervention['id_intervention']}',
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        '${intervention['nom_utilisateur']} ${intervention['prenom_utilisateur']}',
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.white),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        '${intervention['adresse_utilisateur']}',
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.white),
                                      ),
                                      Text(
                                        '${intervention['cp_utilisateur']} ${intervention['ville_utilisateur']}',
                                        style: TextStyle(
                                            fontSize: 16, color: Colors.white),
                                      ),
                                      SizedBox(height: 5),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : Center(
                    child: Text(
                      "Aucune intervention de prévu aujourd'hui",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (pickedDate != null && pickedDate != _selectedDate) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _showInterventionDetails(
      BuildContext context, Map<String, dynamic> intervention) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InterventionDetails(
          intervention: intervention,
          refreshInterventionData: widget.refreshInterventionData,
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _filterInterventions(DateTime date) {
    List<Map<String, dynamic>> filteredInterventions = [];

    if (widget.interventionInfo != null &&
        widget.interventionInfo!['interventions'] != null) {
      final List<dynamic> allInterventions =
          widget.interventionInfo!['interventions'];
      for (var intervention in allInterventions) {
        DateTime interventionDate =
            DateTime.parse(intervention['date_intervention']).toLocal();
        if (interventionDate.year == date.year &&
            interventionDate.month == date.month &&
            interventionDate.day == date.day) {
          filteredInterventions.add(intervention);
        }
      }
    }

    return filteredInterventions;
  }

  bool _isDateSelected(DateTime date) {
    return date.year == _selectedDate.year &&
        date.month == _selectedDate.month &&
        date.day == _selectedDate.day;
  }

  String _getJourSemaine(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Lun';
      case DateTime.tuesday:
        return 'Mar';
      case DateTime.wednesday:
        return 'Mer';
      case DateTime.thursday:
        return 'Jeu';
      case DateTime.friday:
        return 'Ven';
      case DateTime.saturday:
        return 'Sam';
      case DateTime.sunday:
        return 'Dim';
      default:
        return '';
    }
  }

  Color _getCategorieColor(String categorie) {
    switch (categorie) {
      case 'Fibre optique':
        return Colors.blue;
      case 'Electricité':
        return Colors.red;
      case 'Borne de recharge':
        return Colors.green;
      case 'Maison Connectée':
        return Colors.purple;
      case 'Energie solaire':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String formatHeure(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    String heure = dateTime.hour.toString().padLeft(2, '0');
    String minute = dateTime.minute.toString().padLeft(2, '0');
    return '$heure:$minute';
  }

  String calculateEndTime(String startTime, String duration) {
    final parts = startTime.split(':');
    final startHour = int.parse(parts[0]);
    final startMinute = int.parse(parts[1]);

    final durationParts = duration.split(':');
    final durationHour = int.parse(durationParts[0]);
    final durationMinute = int.parse(durationParts[1]);

    final totalMinutes =
        startHour * 60 + startMinute + durationHour * 60 + durationMinute;
    final endHour = (totalMinutes ~/ 60) % 24;
    final endMinute = totalMinutes % 60;

    return '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';
  }

  Widget _getStatutIconAndText(String statut) {
    IconData icon;
    String text;
    Color color;

    switch (statut) {
      case 'En cours':
        icon = Icons.play_arrow;
        text = 'En cours';
        color = Colors.green;
        break;
      case 'A faire':
        icon = Icons.info;
        text = 'A faire';
        color = Colors.grey;
        break;
      case 'Terminée':
        icon = Icons.check_circle;
        text = 'Terminée';
        color = Colors.blue;
        break;
      case 'Reportée':
        icon = Icons.report;
        text = 'Reportée';
        color = Colors.red;
        break;
      case 'Validée':
        icon = Icons.check;
        text = 'Validée';
        color = Colors.green;
        break;
      case 'Refusée':
        icon = Icons.cancel;
        text = 'Refusée';
        color = Colors.red;
        break;
      default:
        icon = Icons.info;
        text = 'Inconnu';
        color = Colors.grey;
    }

    return Row(
      children: [
        Icon(icon, color: color),
        SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(color: color),
        ),
      ],
    );
  }
}
