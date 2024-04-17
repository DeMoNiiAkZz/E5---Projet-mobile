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

        break;
    case 'POST':

        break;
    case 'PUT':
        $data = json_decode(file_get_contents("php://input"), true);

        if (isset($data['id_intervention'])) {
            $id_intervention = $data['id_intervention'];
            $nouveau_statut = $data['nouveau_statut'];
            $id_technicien = $data['id_technicien'];
            $sql = "UPDATE intervention SET statut = :nouveau_statut WHERE id_intervention = :id_intervention";
            $stmt = $pdo->prepare($sql);
            $stmt->bindParam(':nouveau_statut', $nouveau_statut);
            $stmt->bindParam(':id_intervention', $id_intervention);

            if ($stmt->execute()) {
                http_response_code(200);
                if ($nouveau_statut == "En cours") {
                    echo json_encode(array('message' => 'Votre intervention peut commencer !'));
                    $logsql = "INSERT INTO log (message, dateheure,id_utilisateur) VALUES ('Démarrage intervention', NOW(), :id_utilisateur)";
                    $logstmt = $pdo->prepare($logsql);
                    $logstmt->bindParam(':id_utilisateur', $id_technicien);
                    $logstmt->execute(); 
                } else if ($nouveau_statut == "Terminée") {
                    echo json_encode(array('message' => 'Votre intervention est terminée !'));
                    $logsql = "INSERT INTO log (message, dateheure,id_utilisateur) VALUES ('Intervention terminée', NOW(), :id_utilisateur)";
                    $logstmt = $pdo->prepare($logsql);
                    $logstmt->bindParam(':id_utilisateur', $id_technicien);
                    $logstmt->execute(); 
                }
            } else {
                http_response_code(500);
                echo json_encode(array('error' => 'Erreur lors de la mise à jour du statut de l\'intervention'));
            }
        } else {
            http_response_code(400);
            echo json_encode(array('error' => 'Paramètres manquants'));
        }
        break;
    case 'DELETE':

        break;
    default:
        http_response_code(405);
        echo json_encode(array('error' => 'Méthode non autorisée'));
        break;
}

$pdo = null;
