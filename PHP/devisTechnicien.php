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
        $data = json_decode(file_get_contents("php://input"));

        $id_utilisateur = $data['id_utilisateur'];
        $sql = "INSERT INTO utilisateur (nom, prenom, email, password, id_type, token, est_active) 
        VALUES (:nom, :prenom, :email, :password, 3, :token, 0)";
        $stmt = $pdo->prepare($sql);        
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
