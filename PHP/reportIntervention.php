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

        if (isset($data['id_intervention']) && isset($data['new_datetime'])) {
            $id_intervention = $data['id_intervention'];
            $new_datetime = $data['new_datetime'];

            try {
                $stmt_update = $pdo->prepare("UPDATE intervention SET statut = 'Reportée' WHERE id_intervention = :id_intervention");
                $stmt_update->bindParam(':id_intervention', $id_intervention);
                $stmt_update->execute();

                $stmt_select = $pdo->prepare("SELECT type,duree_intervention, description, categorie, id_client FROM intervention WHERE id_intervention = :id_intervention");
                $stmt_select->bindParam(':id_intervention', $id_intervention);
                $stmt_select->execute();
                $intervention = $stmt_select->fetch(PDO::FETCH_ASSOC);

                if ($intervention) {
                    $stmt_insert = $pdo->prepare("INSERT INTO intervention (type,date_intervention, statut, duree_intervention, description, categorie, id_client) 
                    VALUES (:type, :new_datetime, 'A faire', :duree_intervention, :description, :categorie, :id_client)");
                    $stmt_insert->bindParam(':type', $intervention['type']);
                    $stmt_insert->bindParam(':new_datetime', $new_datetime);
                    $stmt_insert->bindParam(':duree_intervention', $intervention['duree_intervention']);
                    $stmt_insert->bindParam(':description', $intervention['description']);
                    $stmt_insert->bindParam(':categorie', $intervention['categorie']);
                    $stmt_insert->bindParam(':id_client', $intervention['id_client']);
                    $stmt_insert->execute();

                    $last_insert_id = $pdo->lastInsertId();

                    $stmt_select_technician = $pdo->prepare("SELECT id_technicien FROM intervention_technicien WHERE id_intervention = :id_intervention");
                    $stmt_select_technician->bindParam(':id_intervention', $id_intervention);
                    $stmt_select_technician->execute();
                    $technician_id_row = $stmt_select_technician->fetch(PDO::FETCH_ASSOC);

                    if ($technician_id_row) {
                        $stmt_insert_intervention_technician = $pdo->prepare("INSERT INTO intervention_technicien (id_intervention, id_technicien) VALUES (:id_intervention, :id_technicien)");
                        $stmt_insert_intervention_technician->bindParam(':id_intervention', $last_insert_id);
                        $stmt_insert_intervention_technician->bindParam(':id_technicien', $technician_id_row['id_technicien']);
                        $stmt_insert_intervention_technician->execute();

                        http_response_code(200);
                        echo json_encode(array('message' => 'Intervention reportée avec succès.'));
                        $logsql = "INSERT INTO log (message, dateheure,id_utilisateur) VALUES ('Report intervention', NOW(), :id_utilisateur)";
                        $logstmt = $pdo->prepare($logsql);
                        $logstmt->bindParam(':id_utilisateur', $technician_id_row['id_technicien']);
                        $logstmt->execute();
                    } else {
                        http_response_code(404);
                        echo json_encode(array('error' => 'Erreur lors du report de votre intervention'));
                    }
                } else {
                    http_response_code(404);
                    echo json_encode(array('error' => 'Erreur lors du report de votre intervention'));
                }
            } catch (PDOException $e) {
                http_response_code(500);
                echo json_encode(array('error' => $e));
            }
        } else {
            http_response_code(400);
            echo json_encode(array('error' => 'Données manquantes.'));
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
