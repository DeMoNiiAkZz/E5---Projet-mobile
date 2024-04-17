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
        $query = "SELECT * FROM vehicule";
        $stmt = $pdo->query($query);
        $vehicules = $stmt->fetchAll(PDO::FETCH_ASSOC);

        $response = array();
        $response['vehicules'] = array_values($vehicules);

        http_response_code(200);
        header('Content-Type: application/json');
        echo json_encode($response);

        break;
    case 'POST':
        $data = json_decode(file_get_contents("php://input"), true);

        

        if (isset($data['type']) && isset($data['description']) && isset($data['id_vehicule']) && isset($data['id_utilisateur'])) {
            $type = $data['type'];
            $description = $data['description'];
            $id_vehicule = $data['id_vehicule'];
            $id_utilisateur = $data['id_utilisateur'];

            $sql_insert = "INSERT INTO entretien_panne_vehicule (type, texte, date_heure, id_vehicule, id_technicien) VALUES (:type, :texte, NOW(), :id_vehicule, :id_utilisateur)";

            $stmt = $pdo->prepare($sql_insert);
            $stmt->bindParam(':type', $type);
            $stmt->bindParam(':texte', $description);
            $stmt->bindParam(':id_vehicule', $id_vehicule);
            $stmt->bindParam(':id_utilisateur', $id_utilisateur);

            if ($stmt->execute()) {
                http_response_code(200);
                echo json_encode(array("message" => "Votre demande a été envoyé avec succès. L'administrateur n'a pu qu'à la traiter ! 😄"));
                $logsql = "INSERT INTO log (message, dateheure,id_utilisateur) VALUES ('Panne/Entretien envoyé', NOW(), :id_utilisateur)";
                $logstmt = $pdo->prepare($logsql);
                $logstmt->bindParam(':id_utilisateur', $id_utilisateur);
                $logstmt->execute();
            } else {
                http_response_code(500);
                echo json_encode(array("error" => "Une erreur est survenu. 🙁"));
            }
        } else {
            http_response_code(400);
            echo json_encode(array("error" => "Tous les champs ne sont pas remplis."));
        }
        break;
    case 'PUT':
        $data = json_decode(file_get_contents("php://input"), true);

        if (isset($data['id_vehicule'])) {
            $kilometrage = $data['kilometrage'];
            $id_vehicule = $data['id_vehicule'];

            $sql_update_data = "UPDATE vehicule SET kilometrage = :kilometrage WHERE id_vehicule = :id_vehicule";
            $stmt = $pdo->prepare($sql_update_data);
            $stmt->bindParam(':kilometrage', $kilometrage, PDO::PARAM_INT);
            $stmt->bindParam(':id_vehicule', $id_vehicule, PDO::PARAM_INT);

            if ($stmt->execute()) {
                http_response_code(200);
                echo json_encode(array("message" => "Le kilométrage du véhicule a été mis à jour avec succès."));
                $logsql = "INSERT INTO log (message, dateheure,id_utilisateur) VALUES ('Kilometrage du véhicule mis à jour', NOW(), :id_utilisateur)";
                $logstmt = $pdo->prepare($logsql);
                $logstmt->bindParam(':id_utilisateur', $id_utilisateur);
                $logstmt->execute();
            } else {
                http_response_code(500);
                echo json_encode(array("error" => "Une erreur s'est produite lors de la mise à jour du kilométrage du véhicule."));
            }
        } else {
            http_response_code(400);
            echo json_encode(array("error" => "Les données nécessaires pour mettre à jour le kilométrage du véhicule ne sont pas fournies."));
        }
        break;
    case 'DELETE':
        break;
    default:
        http_response_code(405);
        echo json_encode(array('error' => 'Méthode non autorisée'));
        break;
}

$pdo = null;
