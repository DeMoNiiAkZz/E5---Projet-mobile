-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Hôte : 127.0.0.1:3306
-- Généré le : mer. 17 avr. 2024 à 11:00
-- Version du serveur : 11.2.2-MariaDB
-- Version de PHP : 8.2.13

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de données : `lcs_mobile`
--

DELIMITER $$
--
-- Procédures
--
DROP PROCEDURE IF EXISTS `UpdateStock`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `UpdateStock` (IN `productId` INT, IN `quantity` INT)   BEGIN
    UPDATE stock SET quantite = quantite - quantity WHERE id_stock = productId;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `avis`
--

DROP TABLE IF EXISTS `avis`;
CREATE TABLE IF NOT EXISTS `avis` (
  `id_avis` int(11) NOT NULL AUTO_INCREMENT,
  `note` int(11) DEFAULT NULL,
  `commentaire` varchar(500) DEFAULT NULL,
  `id_intervention` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_avis`),
  KEY `fk_avis_intervention` (`id_intervention`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `citations`
--

DROP TABLE IF EXISTS `citations`;
CREATE TABLE IF NOT EXISTS `citations` (
  `id_citation` int(11) NOT NULL AUTO_INCREMENT,
  `citation` text NOT NULL,
  PRIMARY KEY (`id_citation`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `citations`
--

INSERT INTO `citations` (`id_citation`, `citation`) VALUES
(1, 'La vie est un voyage, pas une destination.'),
(2, 'Le bonheur n\'est pas quelque chose que l\'on trouve, c\'est quelque chose que l\'on crée.'),
(3, 'Chaque jour est une nouvelle chance de changer votre vie.'),
(4, 'Soyez le changement que vous voulez voir dans le monde.');

-- --------------------------------------------------------

--
-- Structure de la table `communication`
--

DROP TABLE IF EXISTS `communication`;
CREATE TABLE IF NOT EXISTS `communication` (
  `id_communication` int(11) NOT NULL AUTO_INCREMENT,
  `id_envoyeur` int(11) DEFAULT NULL,
  `type_message` varchar(255) NOT NULL,
  `message` varchar(2000) NOT NULL,
  `datetime` datetime DEFAULT NULL,
  `id_conversation` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_communication`),
  KEY `fk_communication_conversation` (`id_conversation`)
) ENGINE=InnoDB AUTO_INCREMENT=13 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `communication`
--

INSERT INTO `communication` (`id_communication`, `id_envoyeur`, `type_message`, `message`, `datetime`, `id_conversation`) VALUES
(9, 25, 'Fichier', 'pieces_jointe/conversation/invoice_65e098d23ec07.pdf', '2024-02-29 15:46:42', 2),
(10, 25, 'Message', 'Salut', '2024-04-17 12:44:44', 2),
(12, 25, 'Fichier', 'pieces_jointe/conversation/cc-d6-41-7e-ea-f0-f0-2c-e1-58-22-e2-61-45-ba-d4-12-dc-62-70_661fab1bf186a.jpg', '2024-04-17 12:57:31', 2);

-- --------------------------------------------------------

--
-- Structure de la table `conges_payes`
--

DROP TABLE IF EXISTS `conges_payes`;
CREATE TABLE IF NOT EXISTS `conges_payes` (
  `id_conges_payes` int(11) NOT NULL AUTO_INCREMENT,
  `motif` varchar(255) NOT NULL,
  `commentaire` text DEFAULT NULL,
  `date_debut` date NOT NULL,
  `date_fin` date NOT NULL,
  `id_technicien` int(11) NOT NULL,
  `traiter` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id_conges_payes`),
  KEY `id_technicien` (`id_technicien`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `conges_payes`
--

INSERT INTO `conges_payes` (`id_conges_payes`, `motif`, `commentaire`, `date_debut`, `date_fin`, `id_technicien`, `traiter`) VALUES
(1, 'Vacances', '', '2024-03-04', '2024-03-08', 9, 1),
(2, 'Vacances', '', '2024-03-11', '2024-03-15', 9, 1),
(3, 'Vacances', '', '2024-03-18', '2024-03-22', 9, 1),
(4, 'Vacances', '', '2024-03-04', '2024-03-08', 9, 1),
(5, 'Vacances', '', '2024-03-11', '2024-03-15', 9, 1),
(6, 'Maladie', '', '2024-03-18', '2024-03-22', 9, 1),
(7, 'Vacances', '', '2024-03-04', '2024-03-08', 9, 1),
(8, 'Vacances', '', '2024-03-11', '2024-03-15', 9, 1),
(9, 'Maladie', '', '2024-03-18', '2024-03-22', 9, 1);

-- --------------------------------------------------------

--
-- Structure de la table `conversation`
--

DROP TABLE IF EXISTS `conversation`;
CREATE TABLE IF NOT EXISTS `conversation` (
  `id_conversation` int(11) NOT NULL AUTO_INCREMENT,
  `id_utilisateur1` int(11) DEFAULT NULL,
  `id_utilisateur2` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_conversation`),
  KEY `fk_conversation_utilisateur1` (`id_utilisateur1`),
  KEY `fk_conversation_utilisateur2` (`id_utilisateur2`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `conversation`
--

INSERT INTO `conversation` (`id_conversation`, `id_utilisateur1`, `id_utilisateur2`) VALUES
(2, 25, 9);

-- --------------------------------------------------------

--
-- Structure de la table `cri`
--

DROP TABLE IF EXISTS `cri`;
CREATE TABLE IF NOT EXISTS `cri` (
  `id_cri` int(11) NOT NULL AUTO_INCREMENT,
  `actions` text DEFAULT NULL,
  `equipements` text DEFAULT NULL,
  `problemes` text DEFAULT NULL,
  `observations` text DEFAULT NULL,
  `id_technicien` int(11) DEFAULT NULL,
  `id_intervention` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_cri`),
  KEY `fk_cri_utilisateur` (`id_technicien`),
  KEY `id_intervention` (`id_intervention`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `cri_validation`
--

DROP TABLE IF EXISTS `cri_validation`;
CREATE TABLE IF NOT EXISTS `cri_validation` (
  `id_validation_cri` int(11) NOT NULL AUTO_INCREMENT,
  `validation` varchar(255) NOT NULL,
  `commentaire` text DEFAULT NULL,
  `id_cri` int(11) NOT NULL,
  PRIMARY KEY (`id_validation_cri`),
  KEY `id_cri` (`id_cri`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `devis`
--

DROP TABLE IF EXISTS `devis`;
CREATE TABLE IF NOT EXISTS `devis` (
  `id_devis` int(11) NOT NULL AUTO_INCREMENT,
  `nom` varchar(255) DEFAULT NULL,
  `chemin` varchar(255) DEFAULT NULL,
  `id_utilisateur` int(11) DEFAULT NULL,
  `id_intervention` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_devis`),
  KEY `fk_devis_utilisateur` (`id_utilisateur`),
  KEY `id_intervention` (`id_intervention`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `devis`
--

INSERT INTO `devis` (`id_devis`, `nom`, `chemin`, `id_utilisateur`, `id_intervention`) VALUES
(6, 'devis', 'pieces_jointe/devis/Capture d\'écran 2024-04-17 125427_661faab46d6ff.pdf', 25, 55);

-- --------------------------------------------------------

--
-- Structure de la table `entretien_panne_vehicule`
--

DROP TABLE IF EXISTS `entretien_panne_vehicule`;
CREATE TABLE IF NOT EXISTS `entretien_panne_vehicule` (
  `id_entretien` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(255) DEFAULT NULL,
  `texte` text DEFAULT NULL,
  `date_heure` datetime DEFAULT NULL,
  `id_vehicule` int(11) DEFAULT NULL,
  `id_technicien` int(11) DEFAULT NULL,
  `traiter` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id_entretien`),
  KEY `id_vehicule` (`id_vehicule`),
  KEY `id_technicien` (`id_technicien`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `entretien_panne_vehicule`
--

INSERT INTO `entretien_panne_vehicule` (`id_entretien`, `type`, `texte`, `date_heure`, `id_vehicule`, `id_technicien`, `traiter`) VALUES
(1, 'Panne', 'okok', '2024-02-29 11:24:49', 1, 9, 1),
(2, 'Entretien', 'Manque de liquide de refroidissement', '2024-02-29 15:15:54', 1, 9, 1),
(3, 'Panne', 'Moteur HS', '2024-02-29 15:16:08', 2, 9, 1);

-- --------------------------------------------------------

--
-- Structure de la table `facture`
--

DROP TABLE IF EXISTS `facture`;
CREATE TABLE IF NOT EXISTS `facture` (
  `id_facture` int(11) NOT NULL AUTO_INCREMENT,
  `nom` varchar(255) DEFAULT NULL,
  `chemin` varchar(255) DEFAULT NULL,
  `id_utilisateur` int(11) DEFAULT NULL,
  `id_intervention` int(11) NOT NULL,
  PRIMARY KEY (`id_facture`),
  KEY `fk_facture_utilisateur` (`id_utilisateur`),
  KEY `id_intervention` (`id_intervention`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `facture`
--

INSERT INTO `facture` (`id_facture`, `nom`, `chemin`, `id_utilisateur`, `id_intervention`) VALUES
(5, 'Facture', 'pieces_jointe/facture/Capture d\'écran 2024-04-17 125427_661faaab60d45.pdf', 25, 55);

-- --------------------------------------------------------

--
-- Structure de la table `fiche_technique`
--

DROP TABLE IF EXISTS `fiche_technique`;
CREATE TABLE IF NOT EXISTS `fiche_technique` (
  `id_fiche_technique` int(11) NOT NULL AUTO_INCREMENT,
  `chemin` text NOT NULL,
  `id_utilisateur` int(11) NOT NULL,
  `id_intervention` int(11) NOT NULL,
  PRIMARY KEY (`id_fiche_technique`),
  KEY `id_utilisateur` (`id_utilisateur`),
  KEY `id_intervention` (`id_intervention`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `fichier`
--

DROP TABLE IF EXISTS `fichier`;
CREATE TABLE IF NOT EXISTS `fichier` (
  `id_fichiers` int(11) NOT NULL AUTO_INCREMENT,
  `chemin` text NOT NULL,
  `nom_affichage` varchar(255) DEFAULT NULL,
  `id_user` int(11) DEFAULT NULL,
  `id_intervention` int(11) DEFAULT NULL,
  `id_stock` int(11) DEFAULT NULL,
  `id_maintenance` int(11) DEFAULT NULL,
  `id_vehicule` int(11) DEFAULT NULL,
  `id_sav` int(11) DEFAULT NULL,
  `id_cri` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_fichiers`),
  KEY `fk_fichier_intervention` (`id_intervention`),
  KEY `fk_fichier_maintenance` (`id_maintenance`),
  KEY `fk_fichier_vehicule` (`id_vehicule`),
  KEY `fk_fichier_sav` (`id_sav`),
  KEY `fk_fichier_cri` (`id_cri`),
  KEY `fk_fichier_user` (`id_user`),
  KEY `id_stock` (`id_stock`)
) ENGINE=InnoDB AUTO_INCREMENT=61 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `fichier`
--

INSERT INTO `fichier` (`id_fichiers`, `chemin`, `nom_affichage`, `id_user`, `id_intervention`, `id_stock`, `id_maintenance`, `id_vehicule`, `id_sav`, `id_cri`) VALUES
(1, 'pieces_jointe/technicien/pierre.jpg', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(10, 'pieces_jointe/technicien/paul.jpg', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(11, 'pieces_jointe/technicien/detection-563805_640.jpg', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(12, 'pieces_jointe/technicien/sofie.jpg', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(13, 'pieces_jointe/technicien/pierre.jpg', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(14, 'pieces_jointe/technicien/paul.jpg', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(16, 'pieces_jointe/admin/admin.jpg', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
(60, 'pieces_jointe/stock/cc-d6-41-7e-ea-f0-f0-2c-e1-58-22-e2-61-45-ba-d4-12-dc-62-70_661faae5e47b8.jpg', NULL, NULL, NULL, 25, NULL, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Structure de la table `intervention`
--

DROP TABLE IF EXISTS `intervention`;
CREATE TABLE IF NOT EXISTS `intervention` (
  `id_intervention` int(11) NOT NULL AUTO_INCREMENT,
  `type` text DEFAULT NULL,
  `date_intervention` datetime DEFAULT NULL,
  `statut` varchar(255) DEFAULT NULL,
  `duree_intervention` time DEFAULT NULL,
  `description` text DEFAULT NULL,
  `categorie` varchar(255) DEFAULT NULL,
  `id_client` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_intervention`),
  KEY `fk_intervention_utilisateur` (`id_client`)
) ENGINE=InnoDB AUTO_INCREMENT=60 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `intervention`
--

INSERT INTO `intervention` (`id_intervention`, `type`, `date_intervention`, `statut`, `duree_intervention`, `description`, `categorie`, `id_client`) VALUES
(53, 'intervention', '2024-04-15 08:00:00', 'Validée', '01:30:00', 'Intervention de maintenance préventive', 'Fibre optique', 12),
(54, 'intervention', '2024-04-15 10:00:00', 'En cours', '02:00:00', 'Installation de nouveaux équipements', 'Electricité', 15),
(55, 'intervention', '2024-04-15 13:00:00', 'A faire', '01:00:00', 'Vérification de la borne de recharge existante', 'Borne de recharge', 12),
(56, 'intervention', '2024-04-15 16:00:00', 'Reportée', '00:30:00', 'Maintenance corrective sur le système solaire', 'Energie solaire', 15);

--
-- Déclencheurs `intervention`
--
DROP TRIGGER IF EXISTS `validation_ajout_intervention`;
DELIMITER $$
CREATE TRIGGER `validation_ajout_intervention` BEFORE INSERT ON `intervention` FOR EACH ROW BEGIN
    IF DAYOFWEEK(NEW.date_intervention) = 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La date d''intervention ne peut pas être un dimanche.';
    END IF;

    IF HOUR(NEW.date_intervention) < 8 OR HOUR(NEW.date_intervention) >= 17 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'L''heure de l''intervention doit être comprise entre 8h et 17h.';
    END IF;

    IF MINUTE(NEW.date_intervention) != 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'L''heure de l''intervention doit être une heure pile.';
    END IF;

    IF MINUTE(NEW.duree_intervention) != 0 AND MINUTE(NEW.duree_intervention) != 30 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La durée de l''intervention doit être une demi-heure.';
    END IF;

    SET @end_datetime = ADDTIME(NEW.date_intervention, NEW.duree_intervention);

    IF (@end_datetime > ADDTIME(CAST(NEW.date_intervention AS DATETIME), '17:30:00')) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'L''intervention dépasse les horaires autorisés (après 17h30).';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `intervention_stock`
--

DROP TABLE IF EXISTS `intervention_stock`;
CREATE TABLE IF NOT EXISTS `intervention_stock` (
  `id_interventionstock` int(11) NOT NULL AUTO_INCREMENT,
  `quantite` int(11) DEFAULT NULL,
  `id_intervention` int(11) DEFAULT NULL,
  `id_stock` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_interventionstock`),
  KEY `fk_intervention_stock_intervention` (`id_intervention`),
  KEY `fk_intervention_stock_stock` (`id_stock`)
) ENGINE=InnoDB AUTO_INCREMENT=9 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déclencheurs `intervention_stock`
--
DROP TRIGGER IF EXISTS `verif_insert_stock`;
DELIMITER $$
CREATE TRIGGER `verif_insert_stock` BEFORE INSERT ON `intervention_stock` FOR EACH ROW BEGIN
    DECLARE total_quantity INT;

    -- Obtenir la quantité totale disponible pour le produit
    SELECT quantite INTO total_quantity FROM stock WHERE id_stock = NEW.id_stock;

    -- Vérifier si la quantité saisie est supérieure à la quantité totale
    IF NEW.quantite > total_quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'La quantité saisie est supérieure à la quantité totale disponible.';
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Structure de la table `intervention_technicien`
--

DROP TABLE IF EXISTS `intervention_technicien`;
CREATE TABLE IF NOT EXISTS `intervention_technicien` (
  `id_intervention_technicien` int(11) NOT NULL AUTO_INCREMENT,
  `id_intervention` int(11) NOT NULL,
  `id_technicien` int(11) NOT NULL,
  PRIMARY KEY (`id_intervention_technicien`),
  KEY `fk_intervention_technicien_intervention` (`id_intervention`),
  KEY `fk_intervention_technicien_technicien` (`id_technicien`)
) ENGINE=InnoDB AUTO_INCREMENT=60 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `intervention_technicien`
--

INSERT INTO `intervention_technicien` (`id_intervention_technicien`, `id_intervention`, `id_technicien`) VALUES
(53, 53, 9),
(54, 54, 9),
(55, 55, 9),
(56, 56, 9),
(59, 59, 9);

-- --------------------------------------------------------

--
-- Structure de la table `log`
--

DROP TABLE IF EXISTS `log`;
CREATE TABLE IF NOT EXISTS `log` (
  `id_log` int(11) NOT NULL AUTO_INCREMENT,
  `message` text DEFAULT NULL,
  `dateheure` datetime DEFAULT NULL,
  `id_utilisateur` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_log`),
  KEY `fk_log_utilisateur` (`id_utilisateur`)
) ENGINE=InnoDB AUTO_INCREMENT=76 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `log`
--

INSERT INTO `log` (`id_log`, `message`, `dateheure`, `id_utilisateur`) VALUES
(1, 'Connexion échoué', '2024-02-15 11:16:38', 9),
(2, 'Connexion réussie', '2024-02-15 11:16:46', 9),
(3, 'Connexion réussie', '2024-02-15 13:49:02', 9),
(4, 'Connexion réussie', '2024-02-15 14:05:47', 9),
(5, 'Connexion réussie', '2024-02-15 15:57:01', 9),
(6, 'Connexion échoué', '2024-02-15 16:25:09', 9),
(7, 'Connexion réussie', '2024-02-15 16:25:14', 9),
(8, 'Demande de congé', '2024-02-29 08:26:18', 9),
(9, 'Demande de congé', '2024-02-29 08:28:19', 9),
(10, 'Signalement', '2024-02-29 08:29:54', 9),
(11, 'Connexion réussie', '2024-02-29 08:35:36', 9),
(12, 'Demande de congé', '2024-02-29 08:36:00', 9),
(13, 'Connexion réussie', '2024-02-29 09:17:09', 9),
(14, 'Connexion réussie', '2024-02-29 09:19:14', 9),
(15, 'Connexion réussie', '2024-02-29 09:35:04', 9),
(16, 'Connexion réussie', '2024-02-29 09:48:05', 9),
(17, 'Connexion réussie', '2024-02-29 09:50:06', 9),
(18, 'Connexion réussie', '2024-02-29 09:53:28', 9),
(19, 'Connexion réussie', '2024-02-29 09:54:51', 9),
(20, 'Connexion réussie', '2024-02-29 10:00:54', 9),
(21, 'Connexion réussie', '2024-02-29 10:18:31', 9),
(22, 'Kilometrage du véhicule mis à jour', '2024-02-29 10:21:42', NULL),
(23, 'Connexion réussie', '2024-02-29 10:36:39', 9),
(24, 'Connexion réussie', '2024-02-29 11:46:05', 9),
(25, 'Demande de congé', '2024-02-29 14:08:24', 9),
(26, 'Demande de congé', '2024-02-29 14:08:42', 9),
(27, 'Demande de congé', '2024-02-29 14:08:53', 9),
(28, 'Connexion réussie', '2024-02-29 15:14:41', 9),
(29, 'Panne/Entretien envoyé', '2024-02-29 15:15:54', 9),
(30, 'Panne/Entretien envoyé', '2024-02-29 15:16:08', 9),
(31, 'Demande de congé', '2024-02-29 15:16:22', 9),
(32, 'Demande de congé', '2024-02-29 15:16:31', 9),
(33, 'Demande de congé', '2024-02-29 15:16:45', 9),
(34, 'Signalement', '2024-02-29 15:16:55', 9),
(35, 'Signalement', '2024-02-29 15:17:09', 9),
(36, 'Connexion réussie', '2024-03-01 09:43:02', 9),
(37, 'Connexion échoué', '2024-03-01 09:44:00', 12),
(38, 'Connexion réussie', '2024-03-01 09:44:06', 15),
(39, 'Connexion réussie', '2024-03-01 09:45:16', 15),
(40, 'Connexion réussie', '2024-03-01 09:47:30', 15),
(41, 'Connexion réussie', '2024-03-01 09:59:28', 15),
(42, 'Connexion réussie', '2024-03-01 10:02:21', 15),
(43, 'Connexion réussie', '2024-03-01 10:14:43', 9),
(44, 'Connexion réussie', '2024-03-01 10:21:55', 9),
(45, 'Connexion réussie', '2024-03-01 10:39:20', 15),
(46, 'Connexion réussie', '2024-03-01 10:40:23', 15),
(47, 'Connexion réussie', '2024-03-01 10:41:10', 15),
(48, 'Connexion réussie', '2024-03-01 10:51:28', 15),
(49, 'Connexion réussie', '2024-03-01 10:52:51', 15),
(50, 'Connexion réussie', '2024-03-01 11:00:24', 15);

-- --------------------------------------------------------

--
-- Structure de la table `maintenance`
--

DROP TABLE IF EXISTS `maintenance`;
CREATE TABLE IF NOT EXISTS `maintenance` (
  `id_maintenance` int(11) NOT NULL AUTO_INCREMENT,
  `id_vehicule` int(11) DEFAULT NULL,
  `probleme` varchar(255) DEFAULT NULL,
  `description` varchar(2000) DEFAULT NULL,
  `dateheure` datetime DEFAULT NULL,
  `id_utilisateur` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_maintenance`),
  KEY `fk_maintenance_vehicule` (`id_vehicule`),
  KEY `fk_maintenance_utilisateur` (`id_utilisateur`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `plan`
--

DROP TABLE IF EXISTS `plan`;
CREATE TABLE IF NOT EXISTS `plan` (
  `id_plan` int(11) NOT NULL AUTO_INCREMENT,
  `nom` varchar(255) DEFAULT NULL,
  `chemin` varchar(255) DEFAULT NULL,
  `id_utilisateur` int(11) DEFAULT NULL,
  `id_intervention` int(11) NOT NULL,
  PRIMARY KEY (`id_plan`),
  KEY `fk_plan_utilisateur` (`id_utilisateur`),
  KEY `id_intervention` (`id_intervention`)
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `plan`
--

INSERT INTO `plan` (`id_plan`, `nom`, `chemin`, `id_utilisateur`, `id_intervention`) VALUES
(13, 'documentation tech', 'pieces_jointe/plan/Capture d\'écran 2024-04-17 125427_661faabeebd9a.pdf', 25, 55);

-- --------------------------------------------------------

--
-- Structure de la table `qualification`
--

DROP TABLE IF EXISTS `qualification`;
CREATE TABLE IF NOT EXISTS `qualification` (
  `id_qualification` int(11) NOT NULL AUTO_INCREMENT,
  `competence` varchar(500) DEFAULT NULL,
  `id_technicien` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_qualification`),
  KEY `fk_qualification_utilisateur` (`id_technicien`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `rappel`
--

DROP TABLE IF EXISTS `rappel`;
CREATE TABLE IF NOT EXISTS `rappel` (
  `id_rappel` int(11) NOT NULL,
  `contenu` text DEFAULT NULL,
  `dateheure` datetime DEFAULT NULL,
  `id_utilisateur` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_rappel`),
  KEY `fk_rappel_utilisateur` (`id_utilisateur`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `sav`
--

DROP TABLE IF EXISTS `sav`;
CREATE TABLE IF NOT EXISTS `sav` (
  `id_sav` int(11) NOT NULL AUTO_INCREMENT,
  `message` text DEFAULT NULL,
  `id_intervention` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_sav`),
  KEY `fk_sav_intervention` (`id_intervention`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `signalement`
--

DROP TABLE IF EXISTS `signalement`;
CREATE TABLE IF NOT EXISTS `signalement` (
  `id_signalement` int(11) NOT NULL AUTO_INCREMENT,
  `motif` text NOT NULL,
  `description` text NOT NULL,
  `id_technicien` int(11) NOT NULL,
  `traiter` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id_signalement`),
  KEY `id_technicien` (`id_technicien`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `signature`
--

DROP TABLE IF EXISTS `signature`;
CREATE TABLE IF NOT EXISTS `signature` (
  `id_signature` int(11) NOT NULL AUTO_INCREMENT,
  `signature_client` text DEFAULT NULL,
  `signature_technicien` text DEFAULT NULL,
  `id_client` int(11) DEFAULT NULL,
  `id_technicien` int(11) DEFAULT NULL,
  `id_cri` int(11) NOT NULL,
  PRIMARY KEY (`id_signature`),
  KEY `id_technicien` (`id_technicien`),
  KEY `id_cri` (`id_cri`),
  KEY `id_client` (`id_client`)
) ENGINE=InnoDB AUTO_INCREMENT=51 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Structure de la table `stock`
--

DROP TABLE IF EXISTS `stock`;
CREATE TABLE IF NOT EXISTS `stock` (
  `id_stock` int(11) NOT NULL AUTO_INCREMENT,
  `reference` varchar(255) DEFAULT NULL,
  `nom` varchar(255) DEFAULT NULL,
  `description` text NOT NULL,
  `quantite` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_stock`)
) ENGINE=InnoDB AUTO_INCREMENT=26 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `stock`
--

INSERT INTO `stock` (`id_stock`, `reference`, `nom`, `description`, `quantite`) VALUES
(25, 'REF093895', 'Prise', 'Ceci est une prise de luxe', 100);

-- --------------------------------------------------------

--
-- Structure de la table `type`
--

DROP TABLE IF EXISTS `type`;
CREATE TABLE IF NOT EXISTS `type` (
  `id_type` int(11) NOT NULL AUTO_INCREMENT,
  `type` varchar(255) DEFAULT NULL,
  PRIMARY KEY (`id_type`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `type`
--

INSERT INTO `type` (`id_type`, `type`) VALUES
(1, 'admin'),
(2, 'technicien'),
(3, 'client');

-- --------------------------------------------------------

--
-- Structure de la table `utilisateur`
--

DROP TABLE IF EXISTS `utilisateur`;
CREATE TABLE IF NOT EXISTS `utilisateur` (
  `id_utilisateur` int(11) NOT NULL AUTO_INCREMENT,
  `nom` varchar(255) DEFAULT NULL,
  `prenom` varchar(255) DEFAULT NULL,
  `email` varchar(255) DEFAULT NULL,
  `password` varchar(255) DEFAULT NULL,
  `cp` varchar(255) DEFAULT NULL,
  `ville` varchar(255) DEFAULT NULL,
  `adresse` varchar(255) DEFAULT NULL,
  `telephone` varchar(255) DEFAULT NULL,
  `id_type` int(11) DEFAULT NULL,
  `id_fichier` int(11) DEFAULT NULL,
  `est_active` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_utilisateur`),
  KEY `fk_utilisateur_type` (`id_type`)
) ENGINE=InnoDB AUTO_INCREMENT=27 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `utilisateur`
--

INSERT INTO `utilisateur` (`id_utilisateur`, `nom`, `prenom`, `email`, `password`, `cp`, `ville`, `adresse`, `telephone`, `id_type`, `id_fichier`, `est_active`) VALUES
(9, 'TECHNICIEN', 'Pierre', 'jesuistechnicien@gmail.com', '$2y$10$siwu2njAD0UZ0Ty4Tzkf4.D0tiQxL1.OkMm9wUlVFLK0xwr/GLo66', '55800', 'RSO', 'Ici dans ma rue', '0606060606', 2, 1, 0),
(12, 'Berger', 'Nathalie', 'jesuisclient2@gmail.com', '$2y$10$F5Iv34B2PXYCwR0I5zEJLeoMZ.FqpK3dolo12rp76YRhGjwL18qqW', '78000', 'Paris', '19 rue des rats', '0612345678', 3, NULL, 0),
(15, 'LAFOUR', 'Elodie', 'jesuisclient@gmail.com', '$2y$10$AkD56zPBRlAxNkU7.aUzT.7cfUCO5r2o8EVIwK7Ci4JdAU/Bi.J1K', '54000', 'Nancy', '90 rue du fourrier', '0678901234', 3, NULL, 0),
(25, 'nom', 'prenom', 'jesuisadmin@gmail.com', '$2y$10$BzO88hLt5XOgv6aWz3/XjuyWvgd2OMoW8mP3uEwqm598xGnOlPSwK', 'cp', 'ville', 'adresse', '0612345678', 1, 16, 0);

-- --------------------------------------------------------

--
-- Structure de la table `vehicule`
--

DROP TABLE IF EXISTS `vehicule`;
CREATE TABLE IF NOT EXISTS `vehicule` (
  `id_vehicule` int(11) NOT NULL AUTO_INCREMENT,
  `immatriculation` varchar(20) DEFAULT NULL,
  `marque` varchar(50) DEFAULT NULL,
  `modele` varchar(50) DEFAULT NULL,
  `kilometrage` int(11) DEFAULT NULL,
  PRIMARY KEY (`id_vehicule`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Déchargement des données de la table `vehicule`
--

INSERT INTO `vehicule` (`id_vehicule`, `immatriculation`, `marque`, `modele`, `kilometrage`) VALUES
(1, 'AB-123-CD', 'Fiat', '500', 120000),
(2, 'AZ-000-ZA', 'Porsche', 'GT4', 80000);

--
-- Contraintes pour les tables déchargées
--

--
-- Contraintes pour la table `avis`
--
ALTER TABLE `avis`
  ADD CONSTRAINT `fk_avis_intervention` FOREIGN KEY (`id_intervention`) REFERENCES `intervention` (`id_intervention`);

--
-- Contraintes pour la table `communication`
--
ALTER TABLE `communication`
  ADD CONSTRAINT `fk_communication_conversation` FOREIGN KEY (`id_conversation`) REFERENCES `conversation` (`id_conversation`);

--
-- Contraintes pour la table `conges_payes`
--
ALTER TABLE `conges_payes`
  ADD CONSTRAINT `conges_payes_ibfk_1` FOREIGN KEY (`id_technicien`) REFERENCES `utilisateur` (`id_utilisateur`);

--
-- Contraintes pour la table `conversation`
--
ALTER TABLE `conversation`
  ADD CONSTRAINT `fk_conversation_utilisateur1` FOREIGN KEY (`id_utilisateur1`) REFERENCES `utilisateur` (`id_utilisateur`),
  ADD CONSTRAINT `fk_conversation_utilisateur2` FOREIGN KEY (`id_utilisateur2`) REFERENCES `utilisateur` (`id_utilisateur`);

--
-- Contraintes pour la table `cri`
--
ALTER TABLE `cri`
  ADD CONSTRAINT `cri_ibfk_1` FOREIGN KEY (`id_intervention`) REFERENCES `intervention` (`id_intervention`),
  ADD CONSTRAINT `fk_cri_utilisateur` FOREIGN KEY (`id_technicien`) REFERENCES `utilisateur` (`id_utilisateur`),
  ADD CONSTRAINT `fk_id_intervention` FOREIGN KEY (`id_intervention`) REFERENCES `intervention` (`id_intervention`);

--
-- Contraintes pour la table `cri_validation`
--
ALTER TABLE `cri_validation`
  ADD CONSTRAINT `cri_validation_ibfk_1` FOREIGN KEY (`id_cri`) REFERENCES `cri` (`id_cri`);

--
-- Contraintes pour la table `devis`
--
ALTER TABLE `devis`
  ADD CONSTRAINT `devis_ibfk_1` FOREIGN KEY (`id_intervention`) REFERENCES `intervention` (`id_intervention`),
  ADD CONSTRAINT `fk_devis_utilisateur` FOREIGN KEY (`id_utilisateur`) REFERENCES `utilisateur` (`id_utilisateur`);

--
-- Contraintes pour la table `entretien_panne_vehicule`
--
ALTER TABLE `entretien_panne_vehicule`
  ADD CONSTRAINT `entretien_panne_vehicule_ibfk_1` FOREIGN KEY (`id_vehicule`) REFERENCES `vehicule` (`id_vehicule`),
  ADD CONSTRAINT `entretien_panne_vehicule_ibfk_2` FOREIGN KEY (`id_technicien`) REFERENCES `utilisateur` (`id_utilisateur`);

--
-- Contraintes pour la table `facture`
--
ALTER TABLE `facture`
  ADD CONSTRAINT `facture_ibfk_1` FOREIGN KEY (`id_intervention`) REFERENCES `intervention` (`id_intervention`),
  ADD CONSTRAINT `fk_facture_utilisateur` FOREIGN KEY (`id_utilisateur`) REFERENCES `utilisateur` (`id_utilisateur`);

--
-- Contraintes pour la table `fiche_technique`
--
ALTER TABLE `fiche_technique`
  ADD CONSTRAINT `fiche_technique_ibfk_1` FOREIGN KEY (`id_utilisateur`) REFERENCES `utilisateur` (`id_utilisateur`),
  ADD CONSTRAINT `fiche_technique_ibfk_2` FOREIGN KEY (`id_intervention`) REFERENCES `intervention` (`id_intervention`);

--
-- Contraintes pour la table `fichier`
--
ALTER TABLE `fichier`
  ADD CONSTRAINT `fichier_ibfk_1` FOREIGN KEY (`id_stock`) REFERENCES `stock` (`id_stock`),
  ADD CONSTRAINT `fk_fichier_cri` FOREIGN KEY (`id_cri`) REFERENCES `cri` (`id_cri`),
  ADD CONSTRAINT `fk_fichier_intervention` FOREIGN KEY (`id_intervention`) REFERENCES `intervention` (`id_intervention`),
  ADD CONSTRAINT `fk_fichier_maintenance` FOREIGN KEY (`id_maintenance`) REFERENCES `maintenance` (`id_maintenance`),
  ADD CONSTRAINT `fk_fichier_sav` FOREIGN KEY (`id_sav`) REFERENCES `sav` (`id_sav`),
  ADD CONSTRAINT `fk_fichier_user` FOREIGN KEY (`id_user`) REFERENCES `utilisateur` (`id_utilisateur`),
  ADD CONSTRAINT `fk_fichier_vehicule` FOREIGN KEY (`id_vehicule`) REFERENCES `vehicule` (`id_vehicule`);

--
-- Contraintes pour la table `intervention`
--
ALTER TABLE `intervention`
  ADD CONSTRAINT `fk_intervention_utilisateur` FOREIGN KEY (`id_client`) REFERENCES `utilisateur` (`id_utilisateur`);

--
-- Contraintes pour la table `intervention_stock`
--
ALTER TABLE `intervention_stock`
  ADD CONSTRAINT `fk_intervention_stock_intervention` FOREIGN KEY (`id_intervention`) REFERENCES `intervention` (`id_intervention`),
  ADD CONSTRAINT `fk_intervention_stock_stock` FOREIGN KEY (`id_stock`) REFERENCES `stock` (`id_stock`);

--
-- Contraintes pour la table `signalement`
--
ALTER TABLE `signalement`
  ADD CONSTRAINT `signalement_ibfk_1` FOREIGN KEY (`id_technicien`) REFERENCES `utilisateur` (`id_utilisateur`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
