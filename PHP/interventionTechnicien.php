<?php

$config = parse_ini_file('config.ini');

$dsn = "mysql:host=" . $config['host'] . ";dbname=" . $config['dbname'] . ";charset=utf8mb4";
$username = $config['username'];
$password = $config['password'];

try {
    $pdo = new PDO($dsn, $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    $pdo->exec("set names utf8mb4");
} catch (PDOException $e) {
    http_response_code(500);
    die("Connection failed: " . $e->getMessage());
}



$request_method = $_SERVER['REQUEST_METHOD'];

switch ($request_method) {
    case 'GET':
        if (isset($_GET['id_utilisateur'])) {
            $id_technicien = $_GET['id_utilisateur'];

            $date_aujourdhui = date('Y-m-d');
            $date_aujourdhui_like = $date_aujourdhui . "%";

            $sql_interventions_technicien_jour = "SELECT intervention.*,
                                                utilisateur.id_utilisateur as id_utilisateur, 
                                                utilisateur.nom as nom_utilisateur, 
                                                utilisateur.prenom as prenom_utilisateur,
                                                utilisateur.email as email_utilisateur, 
                                                utilisateur.cp as cp_utilisateur, 
                                                utilisateur.ville as ville_utilisateur, 
                                                utilisateur.adresse as adresse_utilisateur,
                                                utilisateur.telephone as telephone_utilisateur,
                                                intervention_technicien.id_technicien as id_technicien
                                         FROM intervention_technicien 
                                         INNER JOIN intervention ON intervention_technicien.id_intervention = intervention.id_intervention
                                         INNER JOIN utilisateur ON intervention.id_client = utilisateur.id_utilisateur
                                         WHERE intervention_technicien.id_technicien = :id_technicien 
                                         ORDER BY intervention.date_intervention ASC";

            $stmt_interventions_technicien_jour = $pdo->prepare($sql_interventions_technicien_jour);
            $stmt_interventions_technicien_jour->bindParam(':id_technicien', $id_technicien, PDO::PARAM_INT);
            $stmt_interventions_technicien_jour->execute();
            $result_interventions_technicien_jour = $stmt_interventions_technicien_jour->fetchAll(PDO::FETCH_ASSOC);
            http_response_code(200);
            echo json_encode(array(
                'interventions' => $result_interventions_technicien_jour
            ));
            
        } else {
            http_response_code(400);
            echo json_encode(array('error' => 'ID technicien manquant dans la requête'));
        }
        break;
    case 'POST':

        break;
    case 'PUT':

        break;
    case 'DELETE':

        break;
    default:

        http_response_code(405);
        echo json_encode(array('error' => 'Méthode non autorisée'));
        break;
}

$pdo = null;
