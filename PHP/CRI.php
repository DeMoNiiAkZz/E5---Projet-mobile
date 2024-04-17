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
        $sql = "SELECT actions, equipements, problemes, observations FROM cri WHERE id_intervention = :id_intervention";
        $stmt = $pdo->prepare($sql);
        $stmt->bindParam(':id_intervention', $_GET['id_intervention'], PDO::PARAM_INT);
        $stmt->execute();
        $cri = $stmt->fetch(PDO::FETCH_ASSOC);
        if ($cri) {
            http_response_code(200);
            echo json_encode($cri);
        } else {
            http_response_code(404);
            echo json_encode(array('error' => 'Aucun compte rendu trouvé pour cette intervention.'));
        }
        break;

    case 'POST':
        $data = json_decode(file_get_contents("php://input"), true);

        if (
            isset($data['id_intervention']) &&
            isset($data['id_technicien']) &&
            isset($data['actions_effectuees']) &&
            isset($data['equipements_utilises']) &&
            isset($data['problemes_rencontres']) &&
            isset($data['observations'])
        ) {
            $id_intervention = $data['id_intervention'];

            $sql_count = "SELECT COUNT(*) AS cri_count FROM cri WHERE id_intervention = :id_intervention";
            $stmt_count = $pdo->prepare($sql_count);
            $stmt_count->bindParam(':id_intervention', $id_intervention, PDO::PARAM_INT);
            $stmt_count->execute();
            $count_result = $stmt_count->fetch(PDO::FETCH_ASSOC);
            $cri_count = (int)$count_result['cri_count'];

            if ($cri_count > 0) {
                $sql = "UPDATE cri SET actions = :actions_effectuees, equipements = :equipements_utilises, problemes = :problemes_rencontres, observations = :observations, id_technicien = :id_technicien WHERE id_intervention = :id_intervention";
            } else {
                $sql = "INSERT INTO cri (actions, equipements, problemes, observations, id_technicien, id_intervention) VALUES (:actions_effectuees, :equipements_utilises, :problemes_rencontres, :observations, :id_technicien, :id_intervention)";
            }

            $actions_effectuees = htmlspecialchars($data['actions_effectuees']);
            $equipements_utilises = htmlspecialchars($data['equipements_utilises']);
            $problemes_rencontres = htmlspecialchars($data['problemes_rencontres']);
            $observations = htmlspecialchars($data['observations']);
            $id_technicien = $data['id_technicien'];

            $stmt = $pdo->prepare($sql);
            $stmt->bindParam(':id_intervention', $id_intervention, PDO::PARAM_INT);
            $stmt->bindParam(':id_technicien', $id_technicien, PDO::PARAM_INT);
            $stmt->bindParam(':actions_effectuees', $actions_effectuees, PDO::PARAM_STR);
            $stmt->bindParam(':equipements_utilises', $equipements_utilises, PDO::PARAM_STR);
            $stmt->bindParam(':problemes_rencontres', $problemes_rencontres, PDO::PARAM_STR);
            $stmt->bindParam(':observations', $observations, PDO::PARAM_STR);
            $stmt->execute();

            http_response_code(200);
            echo json_encode(array('message' => 'Votre compte rendu a bien été enregistré ! 😄'));
            $logsql = "INSERT INTO log (message, dateheure,id_utilisateur) VALUES ('Compte rendu intervention', NOW(), :id_utilisateur)";
            $logstmt = $pdo->prepare($logsql);
            $logstmt->bindParam(':id_utilisateur', $id_technicien);
            $logstmt->execute();
        } else {
            http_response_code(400);
            echo json_encode(array('error' => 'Il semblerait que tous les champs ne sont pas remplis. 🙁'));
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
