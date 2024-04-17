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

// type de requête
$request_method = $_SERVER['REQUEST_METHOD'];

switch ($request_method) {
    case 'POST':
        $json_data = file_get_contents('php://input');

        // décode le JSON
        $data = json_decode($json_data, true);

        // vérifier si tous les champs sont remplis
        if (empty($data['login']) || empty($data['password'])) {
            http_response_code(400); // Bad Request
            echo json_encode(array('error' => 'Veuillez remplir tous les champs'));
            exit;
        }

        $sql = "SELECT * FROM utilisateur WHERE email = :login";
        $stmt = $pdo->prepare($sql);
        $stmt->bindParam(':login', $data['login']);
        $stmt->execute();

        $user = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$user) {
            http_response_code(401);
            echo json_encode(array('error' => 'L\'adresse mail n\'existe pas.'));
            exit;
        }

        // vérifier le mot de passe
        $sqlPasswordCheck = "SELECT password FROM utilisateur WHERE email = :login";
        $stmtPasswordCheck = $pdo->prepare($sqlPasswordCheck);
        $stmtPasswordCheck->bindParam(':login', $data['login']);
        $stmtPasswordCheck->execute();

        $hashedPassword = $stmtPasswordCheck->fetchColumn();
        $id_utilisateur = $user['id_utilisateur'];
        if (password_verify($data['password'], $hashedPassword)) {

            // Connexion réussie, on log
            $sqlLog = "INSERT INTO log (message,dateheure,id_utilisateur) VALUES ('Connexion réussie', NOW(), $id_utilisateur)";
            $stmtLog = $pdo->prepare($sqlLog);
            $stmtLog->execute();

            http_response_code(200);

            $id_type = $user['id_type'];
            echo json_encode(array(
                'message' => 'Connexion réussie',
                'id_type' => $id_type,
                'id_utilisateur' => $id_utilisateur
            ));
        } else {
            $sqlLog = "INSERT INTO log (message,dateheure,id_utilisateur) VALUES ('Connexion échoué', NOW(), $id_utilisateur)";
            $stmtLog = $pdo->prepare($sqlLog);
            $stmtLog->execute();
            http_response_code(401);
            echo json_encode(array('error' => 'Identifiants incorrects'));
            exit;
        }
        break;

    case 'GET':
        if (isset($_GET['id_utilisateur'])) {
            $id_utilisateur = $_GET['id_utilisateur'];

            $sql = "SELECT utilisateur.*, fichier.chemin 
            FROM utilisateur 
            LEFT JOIN fichier ON utilisateur.id_fichier = fichier.id_fichiers 
            WHERE utilisateur.id_utilisateur = :id_utilisateur
            ";

            $stmt = $pdo->prepare($sql);
            $stmt->bindParam(':id_utilisateur', $id_utilisateur);
            $stmt->execute();

            $userInfo = $stmt->fetch(PDO::FETCH_ASSOC);

            if ($userInfo) {
                http_response_code(200);
                echo json_encode($userInfo);
            } else {
                http_response_code(404);
                echo json_encode(array('error' => 'Utilisateur non trouvé'));
            }
        } else {
            http_response_code(400);
            echo json_encode(array('error' => 'ID utilisateur manquant dans la requête'));
        }
        break;
    default:
        http_response_code(405);
        break;
}

$pdo = null;
