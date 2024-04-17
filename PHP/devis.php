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
        $json_data = json_decode(file_get_contents("php://input"), true);

        if (isset($json_data['id_utilisateur']) && isset($json_data['id_intervention'])) {
            $id_utilisateur = $json_data['id_utilisateur'];
            $id_intervention = $json_data['id_intervention'];

            $sql = "SELECT 
                        utilisateur.id_utilisateur,
                        intervention.id_intervention
                    FROM 
                        utilisateur
                    JOIN 
                        intervention ON utilisateur.id_utilisateur = intervention.id_client
                    WHERE 
                        utilisateur.id_utilisateur = :id_utilisateur AND
                        intervention.id_intervention = :id_intervention";

            $stmt = $pdo->prepare($sql);
            $stmt->bindParam(':id_utilisateur', $id_utilisateur);
            $stmt->bindParam(':id_intervention', $id_intervention);
            $stmt->execute();

            $result = $stmt->fetch(PDO::FETCH_ASSOC);

            if ($result) {
                $sql = "SELECT chemin FROM devis WHERE id_intervention = :id_intervention ";
                $stmt = $pdo->prepare($sql);
                $stmt->bindParam(':id_intervention', $id_intervention);
                $stmt->execute();
                $devis = $stmt->fetch(PDO::FETCH_ASSOC);

                if ($devis) {
                    $chemin_complet = "pieces_jointe/devis/" . $devis['chemin'];
                    http_response_code(200);
                    echo json_encode(array('message' => 'Devis envoyé avec succès', 'chemin' => $chemin_complet));
                } else {
                    http_response_code(404);
                    echo json_encode(array('message' => 'Aucun devis trouvé pour cette intervention'));
                }
            } else {
                http_response_code(404);
                echo json_encode(array('message' => 'Utilisateur ou intervention non trouvés'));
            }
        } else {
            http_response_code(400);
            echo json_encode(array('error' => 'Paramètres manquants'));
        }
        break;
    default:
        http_response_code(405);
        echo json_encode(array('error' => 'Méthode non autorisée'));
        break;
}

$pdo = null;
?>
