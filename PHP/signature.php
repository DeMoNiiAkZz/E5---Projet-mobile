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
    case 'POST':
        $data = json_decode(file_get_contents("php://input"), true);

        $img_client_base64 = $data['client_image'];
        $id_intervention = $data['id_intervention'];
        $id_technicien = $data['id_technicien'];
        $id_utilisateur = $data['id_utilisateur'];

        $decode_client = base64_decode($img_client_base64);

        $file_name_client = 'pieces_jointe/signature/client_' . uniqid() . '.png';
        $chemin_client = $config['path'] . $file_name_client;

        file_put_contents($chemin_client, $decode_client);

        $stmt_select = $pdo->prepare("SELECT id_cri FROM cri WHERE id_intervention = :id_intervention");
        $stmt_select->bindParam(':id_intervention', $id_intervention, PDO::PARAM_INT);
        $stmt_select->execute();
        $id_cri = $stmt_select->fetchColumn();

        if (!$id_cri) {
            http_response_code(400);
            echo json_encode(array('error' => 'Vous devez d\'abord faire votre compte rendu avant de pouvoir signer !'));
            exit();
        }

        $stmt = $pdo->prepare("INSERT INTO signature (signature_client, id_client, id_technicien, id_cri) VALUES (:img_client, :id_client, :id_technicien, :id_cri)");
        $stmt->bindParam(':img_client', $file_name_client);
        $stmt->bindParam(':id_client', $id_utilisateur);
        $stmt->bindParam(':id_technicien', $id_technicien);
        $stmt->bindParam(':id_cri', $id_cri);

        if ($stmt->execute()) {
            http_response_code(200);
            echo json_encode(array('message' => 'La signature du client a été enregistrée avec succès ! 😄'));
            $logsql = "INSERT INTO log (message, dateheure,id_utilisateur) VALUES ('Signature du client enregistrée', NOW(), :id_utilisateur)";
            $logstmt = $pdo->prepare($logsql);
            $logstmt->bindParam(':id_utilisateur', $id_utilisateur);
            $logstmt->execute();
        } else {
            http_response_code(500);
            echo json_encode(array('error' => 'Erreur lors de l\'enregistrement de la signature du client'));
        }
        break;

    default:
        http_response_code(405);
        echo json_encode(array('error' => 'Méthode non autorisée'));
        break;
}

$pdo = null;

