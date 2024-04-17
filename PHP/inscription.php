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

// type de requete
$request_method = $_SERVER['REQUEST_METHOD'];

switch ($request_method) {
    case 'POST':
        // recup les données envoyé à l'api
        $json_data = file_get_contents('php://input');

        // décode le json
        $data = json_decode($json_data, true);

        // verif si les données sont décodées
        if ($data === null) {
            http_response_code(400);
            echo json_encode(array('error' => 'Données JSON invalides'));
            exit;
        }

        // Verification des champs obligatoires
        if (
            !isset($data['nom'])   || !isset($data['prenom']) ||
            !isset($data['email']) || !isset($data['password'])
        ) {
            http_response_code(400);
            echo json_encode(array('error' => 'Données manquantes'));
            exit;
        }

        // Vérification si l'email est déjà utilisé
        $requeteVerificationEmail = "SELECT COUNT(*) as count FROM utilisateur WHERE email = :email";
        $statementVerificationEmail = $pdo->prepare($requeteVerificationEmail);
        $statementVerificationEmail->bindParam(':email', $data['email']);
        $statementVerificationEmail->execute();
        $resultatVerificationEmail = $statementVerificationEmail->fetch(PDO::FETCH_ASSOC);

        if ($resultatVerificationEmail['count'] > 0) {
            http_response_code(401);
            echo json_encode(array('error' => 'Cette adresse email est déjà utilisée'));
            exit;
        }

        

        if ($data['password'] != $data['password_confirm']) {
            http_response_code(400);
            echo json_encode(array('error' => 'Les mots de passe ne correspondent pas.'));
            exit;
        }


        $password = $data["password"];

        if (
            strlen($password) < 8 ||
            !preg_match("/[A-Z]/", $password) ||
            !preg_match("/[a-z]/", $password) ||
            !preg_match("/[!@#$%^&*(),.?\":{}|<>]/", $password)
        ) {
            http_response_code(401);
            echo json_encode(array('error' => 'Le mot de passe ne respecte pas les critères de complexité'));
            exit;
        }

        //Générer un token
        $token = bin2hex(random_bytes(32));

        // prépare la requete sql
        $sql = "INSERT INTO utilisateur (nom, prenom, email, password, id_type, token, est_active) 
        VALUES (:nom, :prenom,  :email, :password, 3, :token, 0)";
        $stmt = $pdo->prepare($sql);
        $hash_password = password_hash($data["password"], PASSWORD_BCRYPT);

        $stmt->bindParam(':nom', $data['nom']);
        $stmt->bindParam(':prenom', $data['prenom']);
        $stmt->bindParam(':email', $data['email']);
        $stmt->bindParam(':password', $hash_password);
        $stmt->bindParam(":token", $token, PDO::PARAM_STR);
        $stmt->execute();
        if ($stmt->rowCount() > 0) {
            http_response_code(200);
            echo json_encode(array('success' => true, 'message' => 'Inscription réussie. Un e-mail de confirmation a été envoyé.'));

            try {
                $to = $data['email'];
                $subject = 'Confirmation d\'inscription';
                $message = 'Bienvenue sur notre site! Veuillez confirmer votre compte en cliquant sur le lien suivant: ';
                $message .= 'http://localhost/lcs_mobile/inscription.php?confirmation_token=' . $token;

                $headers = 'From: alpha.lcservices@gmail.com' . "\r\n" .
                    'Reply-To: alpha.lcservices@gmail.com' . "\r\n" .
                    'X-Mailer: PHP/' . phpversion();

                mail($to, $subject, $message, $headers);
            } catch (PDOException $e) {
                http_response_code(401);
                echo json_encode(array('success' => false, 'error' => 'Erreur lors de l\'envoie du mail.'));
            }
        } else {
            http_response_code(400);
            echo json_encode(array('success' => false, 'error' => 'Erreur lors de la création du compte.'));
        }

        break;
    case 'GET':
        //confirmation
        if (isset($_GET['confirmation_token'])) {
            $confirmation_token = $_GET['confirmation_token'];


            $verificationTokenQuery = "SELECT * FROM utilisateur WHERE token = :token";
            $verificationTokenStmt = $pdo->prepare($verificationTokenQuery);
            $verificationTokenStmt->bindParam(':token', $confirmation_token);
            $verificationTokenStmt->execute();
            $userData = $verificationTokenStmt->fetch(PDO::FETCH_ASSOC);

            if ($userData) {
                $updateStatusQuery = "UPDATE utilisateur SET est_active = 1 WHERE id_utilisateur = :id_utilisateur";
                $updateStatusStmt = $pdo->prepare($updateStatusQuery);
                $updateStatusStmt->bindParam(':id_utilisateur', $userData['id_utilisateur']);

                try {
                    $updateStatusStmt->execute();
                    http_response_code(200);
                    echo json_encode(array('success' => true, 'message' => 'Félicitations, votre compte a été confirmé avec succès!'));
                } catch (PDOException $e) {
                    echo json_encode(array('success' => false, 'error' => 'Erreur lors de la confirmation du compte: ' . $e->getMessage()));
                }
            } else {
                echo json_encode(array('success' => false, 'error' => 'Token invalide ou expiré.'));
            }
        }

        break;
    default:
        http_response_code(405);
        echo json_encode(array('success' => false, 'error' => 'Accès non autorisé'));
        break;
}

$pdo = null;
