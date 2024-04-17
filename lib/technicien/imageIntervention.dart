import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '/config.dart';

class ImagesPage extends StatefulWidget {
  final Map<String, dynamic> intervention;
  final void Function() refreshInterventionData;

  const ImagesPage({
    required this.intervention,
    required this.refreshInterventionData,
  });

  @override
  _ImagesPageState createState() => _ImagesPageState();
}

class _ImagesPageState extends State<ImagesPage> {
  List<XFile>? _imageFiles = [];
  List<String>? _serverImagePaths;
  bool _imagesSaved = false;

  @override
  void initState() {
    super.initState();
    _voirPhotos();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    setState(() {
      if (pickedFile != null) {
        _imageFiles!.add(XFile(pickedFile.path));
        print('Image ajoutée : ${pickedFile.path}');
      }
    });
  }

  void _addPhotos() async {
    List<String> base64Images = [];

    for (XFile file in _imageFiles!) {
      List<int> bytes = await file.readAsBytes();
      String base64Image = base64Encode(bytes);
      base64Images.add(base64Image);
    }
    Map<String, dynamic> data = {
      'intervention_id': widget.intervention['id_intervention'].toString(),
      'utilisateur_id': widget.intervention['id_technicien'].toString(),
      'images': base64Images,
    };

    String jsonData = jsonEncode(data);
    final response = await http.post(
      Uri.parse(
          'http://${AppConfig.ipAddress}/PHP/photosIntervention.php'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonData,
    );
    Map<String, dynamic> jsonResponse = jsonDecode(response.body);
    if (response.statusCode == 200) {
      String message = jsonResponse['message'];
      _successMess(context, message);
      setState(() {
        _imagesSaved = true;
      });
    } else {
      String errorMessage = jsonResponse['error'];
      _errorMess(context, errorMessage);
    }
    widget.refreshInterventionData();
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
    widget.refreshInterventionData();
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
    widget.refreshInterventionData();
  }

  void _voirPhotos() async {
    final response = await http.get(
      Uri.parse(
          'http://${AppConfig.ipAddress}/PHP/photosIntervention.php?id_intervention=${widget.intervention['id_intervention'].toString()}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = jsonDecode(response.body);
      setState(() {
        _serverImagePaths = List<String>.from(jsonResponse);
      });
      print('Chemins des images récupérées depuis le serveur:');
      for (String imagePath in _serverImagePaths!) {
        print(imagePath);
      }
    }
  }

  Future<void> _showImageSourceDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ajouter une photo'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.camera),
                  title: const Text('Prendre une photo'),
                  onTap: () {
                    _pickImage(ImageSource.camera);
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.image),
                  title: const Text('Sélectionner depuis la galerie'),
                  onTap: () {
                    _pickImage(ImageSource.gallery);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        print("Nombre d'images ajoutées : ${_imageFiles?.length}");
        if (_imageFiles != null && _imageFiles!.isNotEmpty && !_imagesSaved) {
          return await showDialog<bool>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Row(
                      children: [
                        Icon(
                          Icons.warning,
                          color: Colors.orange,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Attention',
                          style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    content: const Text(
                      'Voulez-vous vraiment quitter sans enregistrer les images ?',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,

                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                        child: Text('Oui'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                        child: Text('Non'),
                      ),
                    ],
                  );
                },
              ) ??
              false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Photos'),
          actions: [
            IconButton(
              onPressed: _showImageSourceDialog,
              icon: const Icon(Icons.add_a_photo, color: Colors.blue,),
            ),
            IconButton(
              onPressed: _addPhotos,
              icon: const Icon(Icons.save, color: Colors.blue,),
            ),
          ],
        ),
        body: GridView.count(
          crossAxisCount: 3,
          crossAxisSpacing: 4.0,
          mainAxisSpacing: 4.0,
          children: [
            if (_serverImagePaths != null)
              for (String serverImagePath in _serverImagePaths!)
                Image(
                  image: NetworkImage(serverImagePath),
                  fit: BoxFit.cover,
                ),
            if (_imageFiles != null)
              for (XFile localImageFile in _imageFiles!)
                Image.file(
                  File(localImageFile.path),
                  fit: BoxFit.cover,
                ),
          ],
        ),
      ),
    );
  }
}
