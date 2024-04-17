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
        $query = "SELECT citation FROM citations";
        $stmt = $pdo->query($query);
        $citations = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
        if ($citations) {
            $randomIndex = array_rand($citations);
            $randomCitation = $citations[$randomIndex];
            http_response_code(200);
            echo json_encode($randomCitation);
        } else {
            http_response_code(404);
            echo json_encode(array('error' => 'Aucune citation trouvée'));
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
