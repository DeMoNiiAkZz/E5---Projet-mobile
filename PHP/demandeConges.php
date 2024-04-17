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
        $data = json_decode(file_get_contents("php://input"), true);

        if (
            !isset($data['selectedMotif']) || empty($data['selectedMotif']) ||
            (!empty($data['selectedMotif']) && $data['selectedMotif'] == 'Autre' && !isset($data['autreMotif'])) ||
            !isset($data['startDate']) || empty($data['startDate']) ||
            !isset($data['endDate']) || empty($data['endDate'])
        ) {
            http_response_code(400);
            echo json_encode(array('error' => 'Tous les champs doivent être remplis.'));
            break;
        }

        $stmt = $pdo->prepare("INSERT INTO conges_payes (motif, commentaire, date_debut, date_fin, id_technicien) VALUES (:motif, :raison, :date_debut, :date_fin, :id_technicien)");
        $selectedMotif = $data['selectedMotif'];
        $autreMotif = isset($data['autreMotif']) ? $data['autreMotif'] : null;
        $startDate = $data['startDate'];
        $endDate = $data['endDate'];
        $id_technicien = $data['id_technicien'];
        $stmt->bindParam(':motif', $selectedMotif);
        $stmt->bindParam(':raison', $autreMotif);
        $stmt->bindParam(':date_debut', $startDate);
        $stmt->bindParam(':date_fin', $endDate);
        $stmt->bindParam(':id_technicien', $id_technicien);
        if ($stmt->execute()) {
            http_response_code(200);
            echo json_encode(array('message' => "Demande de congé soumise avec succès !\nVous recevrez un rappel quand l'admin aura donné réponse. 😄"));
            $logsql = "INSERT INTO log (message, dateheure,id_utilisateur) VALUES ('Demande de congé', NOW(), :id_utilisateur)";
            $logstmt = $pdo->prepare($logsql);
            $logstmt->bindParam(':id_utilisateur', $id_technicien);
            $logstmt->execute();
        } else {
            http_response_code(500);
            echo json_encode(array('error' => 'Échec de la soumission de la demande de congé. 🙁'));
        }
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
