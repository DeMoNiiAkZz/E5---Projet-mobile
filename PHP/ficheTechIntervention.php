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
            $sql = "SELECT chemin FROM fiche_technique WHERE id_intervention = :intervention_id";
            $stmt = $pdo->prepare($sql);
            $stmt->execute(array(':intervention_id' => $interventionId));
            $imagePaths = $stmt->fetchAll(PDO::FETCH_COLUMN);

            $baseURL = 'http://' .$config['url'].'/applicationStage/';
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
