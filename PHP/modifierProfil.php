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
        case 'GET':
            if (isset($_GET['id_utilisateur'])) {
                $id_utilisateur_connecte = $_GET['id_utilisateur'];
                $query = "SELECT nom, prenom, email, cp, ville, adresse, telephone FROM utilisateur WHERE id_utilisateur = ?";
                $stmt = $pdo->prepare($query);
                $stmt->execute([$id_utilisateur_connecte]);
                $client_info = $stmt->fetch(PDO::FETCH_ASSOC);
                if ($client_info) {
                    http_response_code(200);
                    echo json_encode($client_info);
                } else {
                    http_response_code(404);
                    echo json_encode(array("message" => "Client non trouvé."));
                }
            } else {
                http_response_code(400);
                echo json_encode(array("error" => "ID de l'utilisateur non fourni dans la requête GET."));
            }
            break;
            case 'PUT':
                $data = json_decode(file_get_contents("php://input"), true);
    
                if (isset($data['id_utilisateur'])) {
                    $id_utilisateur = $data['id_utilisateur'];
                    $nom = $data['nom'];
                    $prenom = $data['prenom'];
                    $email = $data['email'];
                    $cp = $data['cp'];
                    $ville = $data['ville'];
                    $adresse = $data['adresse'];
                    $telephone = $data['telephone'];
                    $ancien_mot_de_passe = $data['ancien_mot_de_passe'];
                    $nouveau_mot_de_passe = $data['nouveau_mot_de_passe'];
    
                    $sql_get_password = "SELECT password FROM utilisateur WHERE id_utilisateur = :id_utilisateur";
                    $stmt_get_password = $pdo->prepare($sql_get_password);
                    $stmt_get_password->bindParam(':id_utilisateur', $id_utilisateur);
                    $stmt_get_password->execute();
                    $result = $stmt_get_password->fetch(PDO::FETCH_ASSOC);
    
                    if (password_verify($ancien_mot_de_passe, $result['password'])) {
    
                        $sql_update_data = "UPDATE utilisateur SET nom = :nom, prenom = :prenom, email = :email, cp = :cp, 
                                            ville = :ville, adresse = :adresse, telephone = :telephone";
    
                        if (!empty($nouveau_mot_de_passe)) {
                            if (strlen($nouveau_mot_de_passe) >= 8) {
                                $password_hash = password_hash($nouveau_mot_de_passe, PASSWORD_BCRYPT);
                                $sql_update_data .= ", password = :nouveau_mot_de_passe";
                            } else {
                                http_response_code(400);
                                echo json_encode(array('error' => 'Le nouveau mot de passe doit avoir au moins 8 caractères.'));
                                exit;
                            }
                        }
    
                        $sql_update_data .= " WHERE id_utilisateur = :id_utilisateur";
    
                        $stmt_update_data = $pdo->prepare($sql_update_data);
                        $stmt_update_data->bindParam(':nom', $nom);
                        $stmt_update_data->bindParam(':prenom', $prenom);
                        $stmt_update_data->bindParam(':email', $email);
                        $stmt_update_data->bindParam(':cp', $cp);
                        $stmt_update_data->bindParam(':ville', $ville);
                        $stmt_update_data->bindParam(':adresse', $adresse);
                        $stmt_update_data->bindParam(':telephone', $telephone);
    
                        if (!empty($nouveau_mot_de_passe)) {
                            $stmt_update_data->bindParam(':nouveau_mot_de_passe', $password_hash);
                        }
    
                        $stmt_update_data->bindParam(':id_utilisateur', $id_utilisateur);
                        $success_update_data = $stmt_update_data->execute();
    
                        if ($success_update_data) {
                            http_response_code(200);
                            echo json_encode(array('message' => 'Votre profil a été mis à jour avec succès !'));
                        } else {
                            http_response_code(500);
                            echo json_encode(array('error' => 'Erreur lors de la mise à jour du profil'));
                        }
                    } else {
                        http_response_code(400);
                        echo json_encode(array('error' => 'Ancien mot de passe incorrect'));
                    }
                } else {
                    http_response_code(400);
                    echo json_encode(array('error' => 'Données manquantes'));
                }
                break;
        default:
            http_response_code(405);
            echo json_encode(["error" => "Méthode non autorisée"]);
            break;
    }
    $pdo = null;
?>

