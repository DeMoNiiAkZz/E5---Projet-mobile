import 'dart:convert';
import 'package:flutter/material.dart';

import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Politique de Confidentialité'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Politique de Confidentialité',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Dernière mise à jour : 21/02/2024'),
            SizedBox(height: 20),
            _buildSectionTitle('1. Introduction'),
            _buildSectionContent(
                'Nous attachons une grande importance à la protection de vos données personnelles. '
                'Cette politique de confidentialité explique comment nous collectons, utilisons, stockons et protégeons vos informations.'),
            _buildSectionTitle('2. Données collectées'),
            _buildSectionContent(
                'Nous collectons les données suivantes :\n\n'
                '• Informations d\'identification (nom, adresse e-mail, etc.)\n'
                '• Données de connexion (adresse IP, type de navigateur, etc.)\n'
                '• Informations financières (numéro de carte de crédit, etc.) si nécessaire'),
            _buildSectionTitle('3. Utilisation des données'),
            _buildSectionContent(
                'Nous utilisons vos données pour :\n\n'
                '• Fournir et améliorer nos services\n'
                '• Communiquer avec vous\n'
                '• Assurer la sécurité de notre plateforme\n'
                '• Se conformer à nos obligations légales'),
            _buildSectionTitle('4. Partage des données'),
            _buildSectionContent(
                'Nous ne partageons pas vos données personnelles avec des tiers, sauf dans les cas suivants :\n\n'
                '• Lorsque cela est nécessaire pour fournir nos services\n'
                '• Pour se conformer à une obligation légale\n'
                '• Avec votre consentement explicite'),
            _buildSectionTitle('5. Stockage et protection des données'),
            _buildSectionContent(
                'Nous mettons en place des mesures de sécurité appropriées pour protéger vos données contre les accès non autorisés, '
                'les modifications, les divulgations ou les destructions. Vos données sont stockées sur des serveurs sécurisés.'),
            _buildSectionTitle('6. Vos droits'),
            _buildSectionContent(
                'Vous disposez des droits suivants concernant vos données personnelles :\n\n'
                '• Accès à vos données\n'
                '• Correction de vos données\n'
                '• Suppression de vos données\n'
                '• Opposition à l\'utilisation de vos données\n'
                '• Portabilité de vos données\n\n'
                'Pour exercer ces droits, veuillez nous contacter à contact@logconnectservices.com.'),
            _buildSectionTitle('7. Modifications de la politique de confidentialité'),
            _buildSectionContent(
                'Nous nous réservons le droit de modifier cette politique de confidentialité à tout moment. '
                'Nous vous informerons de tout changement en publiant la nouvelle politique sur notre site web.'),
            _buildSectionTitle('8. Contact'),
            _buildSectionContent(
                'Si vous avez des questions ou des préoccupations concernant cette politique de confidentialité, veuillez nous contacter à :\n\n'
                'Log Connect Services\n'
                '17 bis Rue André Maginot, 55800, Revigny-sur-Ornain\n'
                'contact@logconnectservices.com'),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildSectionContent(String content) {
    return Text(
      content,
      style: TextStyle(fontSize: 16),
    );
  }
}
