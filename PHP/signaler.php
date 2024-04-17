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

        if (isset($data['motif']) && isset($data['description'])) {
            $motif = htmlspecialchars($data['motif']);
            $description = htmlspecialchars($data['description']);
            $id_user = $data['id_utilisateur'];

            $sql = "INSERT INTO signalement (motif, description, id_technicien) VALUES (:motif, :description, :id_technicien)";
            $stmt = $pdo->prepare($sql);
            $stmt->bindParam(':motif', $motif);
            $stmt->bindParam(':description', $description);
            $stmt->bindParam(':id_technicien', $id_user);

            if ($stmt->execute()) {
                http_response_code(200);
                echo json_encode(array('message' => 'Votre signalement a bien été pris en compte !'));
                $logsql = "INSERT INTO log (message, dateheure,id_utilisateur) VALUES ('Signalement', NOW(), :id_utilisateur)";
                $logstmt = $pdo->prepare($logsql);
                $logstmt->bindParam(':id_utilisateur', $id_user);
                $logstmt->execute();
            } else {
                http_response_code(500);
                echo json_encode(array('error' => 'Erreur lors du signalement du problème'));
            }
        } else {
            http_response_code(400);
            echo json_encode(array('error' => 'Tous les champs doivent être remplis'));
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
