import 'dart:async';
import 'dart:convert';
import 'profilTechnicien.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config.dart';
import 'interventionTechnicien.dart';
import 'demandeTechnicien.dart';
import 'rappelTechnicien.dart';
import 'conversationTechnicien.dart';
import 'package:intl/intl.dart';

class AccueilTechnicien extends StatefulWidget {
  final int userId;

  AccueilTechnicien({required this.userId});

  @override
  _AccueilTechnicienState createState() => _AccueilTechnicienState();
}

class _AccueilTechnicienState extends State<AccueilTechnicien>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  Map<String, dynamic> _technicienInfo = {};
  Map<String, dynamic> _interventionInfo = {};
  List<Map<String, dynamic>> _vehicules = [];
  String _citation = '';
  late List<Widget> _tabs = [];
  bool _showWelcomeBubble = true;

  @override
  void initState() {
    super.initState();
    _getData();
  }

  void refreshInterventionData() {
    _getInterventionInfo();
  }

  Future<void> _getData() async {
    await Future.wait([
      _getTechnicienInfo(),
      _getInterventionInfo(),
      _getCitations(),
      _getVehicules(),
    ]);
  }

  Future<void> _getTechnicienInfo() async {
    final response = await http.get(
      Uri.parse(
          'http://${AppConfig.ipAddress}/PHP/connexion.php?id_utilisateur=${widget.userId}'),
    );

    if (response.statusCode == 200) {
      setState(() {
        _technicienInfo = json.decode(response.body);
        _updateTabs();
      });
    }
  }

  Future<void> _getVehicules() async {
    final response = await http.get(
      Uri.parse('http://${AppConfig.ipAddress}/PHP/entretienVehicule.php'),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = json.decode(response.body);
      final List<dynamic> vehiculesData = responseData['vehicules'];
      final List<Map<String, dynamic>> vehicules =
          List<Map<String, dynamic>>.from(vehiculesData);

      setState(() {
        _vehicules = vehicules;
        _updateTabs();
      });
    } else {
    }
  }

  Future<void> _getInterventionInfo() async {
    final response = await http.get(
      Uri.parse(
          'http://${AppConfig.ipAddress}/PHP/interventionTechnicien.php?id_utilisateur=${widget.userId}'),
    );

    if (response.statusCode == 200) {
      setState(() {
        _interventionInfo = json.decode(response.body);
        _updateTabs();

      });
    } else {
    }
  }

  Future<void> _getCitations() async {
    final response = await http.get(
      Uri.parse('http://${AppConfig.ipAddress}/PHP/citations.php'),
    );

    if (response.statusCode == 200) {
      setState(() {
        _citation = json.decode(response.body)['citation'];
        _updateTabs();
      });
    }
  }

  void _updateTabs() {
    _tabs = [
      AccueilTab(
        technicienInfo: _technicienInfo,
        interventionInfo: _interventionInfo,
        citation: _citation,
      ),
      InterventionTab(
        technicienInfo: _technicienInfo,
        interventionInfo: _interventionInfo,
        onMessageriePressed: _gotoMessagerieTab,
        refreshInterventionData: _refreshInterventionData,
      ),
      RappelTab(),
      DemandeTab(
        technicienInfo: _technicienInfo,
        intervention: _interventionInfo,
        vehicules: _vehicules,
        refreshInterventionData: refreshInterventionData,
      ),
      ConversationTab(),
    ];
  }

  void _gotoMessagerieTab() {
    setState(() {
      _currentIndex = 4;
    });
  }

  String _getCurrentTime() {
    return DateFormat.Hm().format(DateTime.now());
  }

  String _getCurrentDate() {
    return DateFormat.yMMMMd('fr_FR').format(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 100.0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: _gotoProfilePage,
                  child: CircleAvatar(
                    radius: 30,
                    backgroundImage: _technicienInfo['chemin'] != null &&
                            _technicienInfo['chemin'] != ''
                        ? NetworkImage('http://${AppConfig.chemin}/' +
                            _technicienInfo['chemin'])
                        : NetworkImage('http://${AppConfig.chemin}' +'pieces_jointe/avatars/placeholder.jpg')
                            as ImageProvider<Object>,
                  ),
                ),
                SizedBox(width: 10),
                Padding(
                  padding: EdgeInsets.only(right: 45.0),
                  child: Container(
                    height: 80,
                    child: Image.network(
                      'http://${AppConfig.chemin}/pieces_jointe/ico_mobile/logconnectservices.png',
                    ),
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (BuildContext context) {
                    return [
                      PopupMenuItem(
                        onTap: () {
                          Navigator.of(context).pushNamed('/');
                        },
                        child: Text('Déconnexion'),
                      ),
                    ];
                  },
                ),
              ],
            ),
            SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(width: 20),
                Text(
                  _getCurrentDate(),
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(width: 10),
                Text(
                  _getCurrentTime(),
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: _tabs.isNotEmpty
                    ? _tabs[_currentIndex]
                    : const CircularProgressIndicator(),
              ),
            ],
          ),
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _showWelcomeBubble
                  ? SlideInUpBubble(
                      key: const Key('welcome_bubble'),
                      technicienInfo: _technicienInfo,
                    )
                  : const SizedBox(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            _getTechnicienInfo();
            _getInterventionInfo();
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Accueil',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Intervention',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notification_important),
            label: 'Rappel',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'LCS',
          ),
        ],
      ),
    );
  }

  void _refreshInterventionData() {
    _getInterventionInfo();
  }

  void _gotoProfilePage() {
    _getTechnicienInfo();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilTechnicien(technicienInfo: _technicienInfo),
      ),
    );
  }

  void directVersConversation() {
    setState(() {
      _currentIndex = 4;
    });
  }
}

class SlideInUpBubble extends StatefulWidget {
  final Map<String, dynamic> technicienInfo;

  SlideInUpBubble({required Key key, required this.technicienInfo})
      : super(key: key);

  @override
  _SlideInUpBubbleState createState() => _SlideInUpBubbleState();
}

class _SlideInUpBubbleState extends State<SlideInUpBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
    _offsetAnimation = Tween<Offset>(
      begin: Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.fastOutSlowIn,
    ));
    _controller.forward();
    Timer(Duration(seconds: 3), () {
      _controller.reverse();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: Container(
        width: double.infinity,
        color: Colors.orange,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Center(
          child: Text(
            'Bienvenue ${widget.technicienInfo['prenom']} !',
            style: const TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}

class AccueilTab extends StatelessWidget {
  final Map<String, dynamic> technicienInfo;
  final Map<String, dynamic>? interventionInfo;
  final String citation;

  const AccueilTab(
      {required this.technicienInfo,
      this.interventionInfo,
      required this.citation});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10),
                  Text(
                    '"$citation"',
                    style: TextStyle(
                      fontSize: 16,
                      fontStyle: FontStyle.italic,
                      color: Colors.black87,
                      fontFamily: 'Arial',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class ClockAndDate extends StatefulWidget {
  @override
  _ClockAndDateState createState() => _ClockAndDateState();
}

class _ClockAndDateState extends State<ClockAndDate> {
  late String _timeString;
  late String _dateString;

  @override
  void initState() {
    _timeString = _formatDateTime(DateTime.now(), 'HH:mm');
    _dateString = _formatDateTime(DateTime.now(), 'EEEE d MMMM y');
    Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
    super.initState();
  }

  void _getTime() {
    final now = DateTime.now();
    final formattedTime = _formatDateTime(now, 'HH:mm');
    final formattedDate = _formatDateTime(now, 'EEEE d MMMM y');
    setState(() {
      _timeString = formattedTime;
      _dateString = formattedDate;
    });
  }

  String _formatDateTime(DateTime dateTime, String format) {
    return DateFormat(format, 'fr_FR').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          _dateString,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 10),
        Text(
          _timeString,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
