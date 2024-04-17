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
            if (isset($_GET['id_utilisateur'])) {
                $id_utilisateur = $_GET['id_utilisateur'];

                $sql = "SELECT 
                            utilisateur.nom AS nom_utilisateur,
                            utilisateur.prenom AS prenom_utilisateur,
                            intervention.id_intervention,
                            intervention.date_intervention,
                            intervention.statut,
                            intervention.description,
                            intervention.categorie,
                            fichier.chemin AS chemin_facture
                        FROM 
                            utilisateur
                        JOIN 
                            intervention ON utilisateur.id_utilisateur = intervention.id_client
                        JOIN 
                            fichier ON intervention.id_intervention = fichier.id_intervention
                        WHERE 
                            utilisateur.id_utilisateur = :id_utilisateur";

                $stmt = $pdo->prepare($sql);
                $stmt->bindParam(':id_utilisateur', $id_utilisateur);
                $stmt->execute();

                $result = $stmt->fetchAll(PDO::FETCH_ASSOC);

                if ($result) {
                    foreach ($result as &$row) {
                        $row['chemin_facture'] = $row['chemin_facture'];
                    }

                    http_response_code(200);
                    echo json_encode($result);
                } else {
                    http_response_code(404);
                    echo json_encode(array('message' => 'Aucune facture trouvée pour cet utilisateur'));
                }
            } else {
                http_response_code(400);
                echo json_encode(array('error' => 'id_utilisateur manquant'));
            }
            break;
        default:
            http_response_code(405);
            echo json_encode(array('error' => 'Méthode non autorisée'));
            break;
    }

    $pdo = null;
?>
