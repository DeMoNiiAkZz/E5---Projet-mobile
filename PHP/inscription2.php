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
    // Type de requête
    $request_method = $_SERVER['REQUEST_METHOD'];


switch ($request_method) {
    case 'POST':
        $json_data = file_get_contents('php://input');
        $data = json_decode($json_data, true);

        if (!isset($data['email']) || !isset($data['password'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Tous les champs obligatoires doivent être remplis']);
            exit;
        }

        $query = $pdo->prepare("SELECT * FROM utilisateur WHERE email = :email");
        $query->execute([
            'email' => $data['email']
        ]);
        $user = $query->fetch(PDO::FETCH_ASSOC);

        if (!$user || !password_verify($data['password'], $user['password'])) {
            http_response_code(401);
            echo json_encode(['error' => 'Email ou mot de passe incorrect']);
            exit;
        }

        http_response_code(200);
        echo json_encode(['success' => 'Vous devez créer un nouveau mot de passe de connexion']);
        break;

    case 'PUT':
        $json_data = file_get_contents('php://input');
        $data = json_decode($json_data, true);

        if (!isset($data['newPassword'])) {
            http_response_code(400);
            echo json_encode(['error' => 'Données JSON invalides ou incomplètes']);
            exit;
        }

 
        $newPassword = $data['newPassword'];
        if (strlen($newPassword) < 8 ||
            !preg_match('/[A-Z]/', $newPassword) ||
            !preg_match('/[a-z]/', $newPassword) ||
            !preg_match('/[0-9]/', $newPassword) ||
            !preg_match('/[!@#$%^&*(),.?":{}|<>]/', $newPassword)) {
            http_response_code(400);
            echo json_encode(['error' => 'Le nouveau mot de passe ne respecte pas les critères de sécurité']);
            exit;
        }

        $query = $pdo->prepare("SELECT * FROM utilisateur WHERE email = :email");
        $query->execute([
            'email' => $data['email']
        ]);
        $user = $query->fetch(PDO::FETCH_ASSOC);

        if (!$user) {
            http_response_code(401);
            echo json_encode(['error' => 'Email incorrect']);
            exit;
        }

     
        $hashedPassword = password_hash($newPassword, PASSWORD_DEFAULT);
        $updateQuery = $pdo->prepare("UPDATE utilisateur SET est_active = 1, password = :password WHERE id_utilisateur = :userId");
        $updateQuery->execute([
            'password' => $hashedPassword,
            'userId' => $user['id_utilisateur']
        ]);

        http_response_code(200);
        echo json_encode(['success' => 'Mot de passe mis à jour avec succès']);
        break;

    default:
        http_response_code(405);
        echo json_encode(['error' => 'Accès non autorisé']);
        break;
}

$pdo = null;
?>

