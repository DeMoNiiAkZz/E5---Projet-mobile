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

        break;
    case 'PUT':
        $data = json_decode(file_get_contents("php://input"), true);

        if (isset($data['id_utilisateur'])) {
            $id_utilisateur = $data['id_utilisateur'];
            $nom = $data['nom'];
            $prenom = $data['prenom'];
            $email = $data['email'];
            $avatar = $data['avatar'];
            $cp = $data['cp'];
            $ville = $data['ville'];
            $adresse = $data['adresse'];
            $telephone = $data['telephone'];


            $sql_update_data = "UPDATE utilisateur SET nom = :nom, prenom = :prenom,email = :email, cp = :cp, 
            ville = :ville, adresse = :adresse, telephone = :telephone WHERE id_utilisateur = :id_utilisateur";
            $stmt_update_data = $pdo->prepare($sql_update_data);
            $stmt_update_data->bindParam(':nom', $nom);
            $stmt_update_data->bindParam(':prenom', $prenom);
            $stmt_update_data->bindParam(':email', $email);
            $stmt_update_data->bindParam(':cp', $cp);
            $stmt_update_data->bindParam(':ville', $ville);
            $stmt_update_data->bindParam(':adresse', $adresse);
            $stmt_update_data->bindParam(':telephone', $telephone);
            $stmt_update_data->bindParam(':id_utilisateur', $id_utilisateur);
            $success_update_data = $stmt_update_data->execute();

            if ($success_update_data) {
                $sql_fichier = "SELECT id_fichier FROM utilisateur WHERE id_utilisateur = :id_utilisateur";
                $stmt_fichier = $pdo->prepare($sql_fichier);
                $stmt_fichier->bindParam(':id_utilisateur', $id_utilisateur);
                $stmt_fichier->execute();
                $row = $stmt_fichier->fetch(PDO::FETCH_ASSOC);
                $id_fichier = $row['id_fichier'];

                $sql_update_avatar = "UPDATE fichier SET chemin = :avatar WHERE id_fichiers = :id_fichier";
                $stmt_update_avatar = $pdo->prepare($sql_update_avatar);
                $stmt_update_avatar->bindParam(':avatar', $avatar);
                $stmt_update_avatar->bindParam(':id_fichier', $id_fichier);
                $success_update_avatar = $stmt_update_avatar->execute();

                if ($success_update_avatar) {
                    http_response_code(200);
                    echo json_encode(array('message' => 'Votre profil a été mis à jour avec succès !'));
                } else {
                    http_response_code(500);
                    echo json_encode(array('error' => 'Erreur lors de la mise à jour du fichier'));
                }
            } else {
                http_response_code(500);
                echo json_encode(array('error' => 'Erreur lors de la mise à jour du profil'));
            }
        } else {
            http_response_code(400);
            echo json_encode(array('error' => 'Données manquantes'));
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
