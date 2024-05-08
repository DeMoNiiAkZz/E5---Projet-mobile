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
        if (isset($_GET['id_intervention'])) {
            $interventionId = $_GET['id_intervention'];
            $sql = "SELECT chemin FROM fichier WHERE id_intervention = :intervention_id";
            $stmt = $pdo->prepare($sql);
            $stmt->execute(array(':intervention_id' => $interventionId));
            $imagePaths = $stmt->fetchAll(PDO::FETCH_COLUMN);

            $baseURL = 'http://' .$config['ip'].$config['getPhotosIntervention'];
            $imageURLs = array_map(function ($path) use ($baseURL) {
                return $baseURL . $path;
            }, $imagePaths);

            header('Content-Type: application/json');
            echo json_encode($imageURLs);
        } else {
            http_response_code(400);
            echo json_encode(array('error' => 'Erreur'));
        }
        break;

    case 'POST':
        $data = json_decode(file_get_contents("php://input"));
        $interventionId = $data->intervention_id;
        $userId = $data->utilisateur_id;

        $imagePaths = [];

        foreach ($data->images as $base64Image) {
            $image = base64_decode($base64Image);
            $fileName = 'photoIntervention_' . $interventionId . '_' . uniqid() . '.jpg';
            $imagePaths[] = 'pieces_jointe/intervention/' . $fileName;

            $directory = $config['path'].$config['interventionPhotos'];
            $filePath = $directory . $fileName;
            file_put_contents($filePath, $image);
        }

        $sql = "INSERT INTO fichier (chemin, id_user, id_intervention) VALUES (:chemin, :id_user, :id_intervention)";
        $stmt = $pdo->prepare($sql);
        $insertedRows = 0;
        foreach ($imagePaths as $imagePath) {
            $stmt->execute(array(':chemin' => $imagePath, ':id_user' => $userId, ':id_intervention' => $interventionId));
            $insertedRows++;
        }

        if ($insertedRows > 0) {
            http_response_code(200);
            echo json_encode(array('message' => 'Vos images insérées ont bien été enregistrées pour cette intervention ! 😄'));  
            $logsql = "INSERT INTO log (message, dateheure,id_utilisateur) VALUES ('Photos enregistrés', NOW(), :id_utilisateur)";
            $logstmt = $pdo->prepare($logsql);
            $logstmt->bindParam(':id_utilisateur', $userId);
            $logstmt->execute();  
        } else {
            http_response_code(500);
            echo json_encode(array('error' => 'Avant d\'enregistrer, vous devez sélectionner des images ! 🙁'));
            
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
