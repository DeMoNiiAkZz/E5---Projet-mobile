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

    // Type de requête
    $request_method = $_SERVER['REQUEST_METHOD'];

    switch ($request_method) {
        case 'GET':
            if (isset($_GET['id_client'])) {
                $id_utilisateur = $_GET['id_client'];
                $sql = "SELECT 
                    intervention.id_intervention,
                    intervention.date_intervention,
                    intervention.statut,
                    intervention.duree_intervention,
                    intervention.description,
                    intervention.categorie,
                    utilisateur.nom AS nom_technicien,
                    utilisateur.prenom AS prenom_technicien
                FROM 
                    intervention
                JOIN 
                    intervention_technicien ON intervention.id_intervention = intervention_technicien.id_intervention
                JOIN 
                    utilisateur ON intervention_technicien.id_technicien = utilisateur.id_utilisateur
                WHERE 
                    intervention.statut  IN ('Terminée', 'Validée' , 'Refusée') AND intervention.id_client = :id_utilisateur;";
    
                $stmt = $pdo->prepare($sql);
                $stmt->execute(['id_utilisateur' => $id_utilisateur]);
                $interventions = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
                if ($interventions) {
                    http_response_code(200);
                    echo json_encode($interventions);
                } else {
                    http_response_code(404);
                    echo json_encode(array('error' => 'Aucune intervention trouvée pour cet utilisateur'));
                }
            } else {
                http_response_code(400);
                echo json_encode(array('error' => 'ID du client manquant'));
            }
            break;
        case 'POST':
            // 
            break;
        case 'PUT':
            // 
            break;
        case 'DELETE':
            //
            break;
        default:
            http_response_code(405);
            echo json_encode(array('error' => 'Méthode non autorisée'));
            break;
    }

    $pdo = null;
?>
