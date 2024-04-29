


# Guide de l'installation du projet mobile


## Ce projet est réalise avec la technologie Flutter qui permet à partir d'un seul code de faire une application mobile Android et iOS qui communique avec un API PHP

- Projet mobile : https://github.com/DeMoNiiAkZz/E5---Projet-mobile
- Projet WEB (en lien à l'appli mobile obligatoire) : https://github.com/DeMoNiiAkZz/E5---Projet-web

---

**Pré-requis :** 

 - Installer les DEUX projets ci-dessus on en aura besoin pour le fonctionnement de l'appli mobile
 - avoir WAMP ou XAMPP d'installer (de préférence utiliser WAMP comme j'ai adapté le projet pour ce service)
 - avoir Visual Studio Code
 - installer l'extension "Flutter" sur Visual Studio Code 
 - Avoir une machine ANDROID
---

 **Une fois les projets installer**

- les dézippers
 -  renommer "E5---Projet-mobile-main" par "LCS_mobile" (l'appli mobile) 	-> renommer "E5---Projet-web-main" par "LCS_Dash" (dash web)
 - Placer les projets dans "wamp64\www\" (l'appli mobile communique    avec une base de donnée via API PHP) 	-> Il faut surtout s'assurer    que tous les codes du projet se trouve dans    "C:\wamp64\www\LCS_mobile" et pas    "C:\wamp64\www\LCS_mobile\LCS_mobile", chose qui peut arriver à cause    du dézippage (c'est pareil pour LCS_Dash)
   <img width="584" alt="repert" src="https://github.com/DeMoNiiAkZz/E5---Projet-mobile/assets/116117908/a3e9f07f-aa27-400f-93ed-b664b83c5ce5">

 - Vérifier si le service de **WAMP** est demarrer puis se connecter à    **PhpMyAdmin** avec comme identifiant root sans mot de passe 	-> créer    une base nommée **"lcs_mobile"** (cette base de donnée sera la même pour    le dashboard et appli mobile)
 - Insérer le code **SQL** qui se situe dans le projet mobile dans le    répertoire **"SQL"** ce qui donne comme chemin    **"C:\wamp64\www\LCS_mobile\SQL\lcs_mobile.sql"**
 ---
 - Lancer VScode en ouvrant ce répertoire **"C:\wamp64\www\LCS_mobile"** (Attendez un peu que sa charge)
 - Le SDK de flutter est directement dans le projet (ne pas s'inquiéter des erreurs rouges rien n'empêche à l'application de fonctionner) 
 -  Il faut impérativement changer les ip dans les fichiers suivant :
      - **"lib\config.dart"** remplacer toutes les ip **"192.168.56.1"** par la vôtre en saisissant "ipconfig" dans l'invite de commande
      - **"PHP\config.ini"** remplacer aussi toutes les ip **"192.168.56.1"** par le votre à nouveau
-  dans le terminal du projet il faut saisir la commande "flutter pub get" (pour réorganiser toutes les dépendances)
  
<img width="368" alt="tuto" src="https://github.com/DeMoNiiAkZz/E5---Projet-mobile/assets/116117908/c0a56dc2-3270-456f-be30-46733eea3135">
<img width="347" alt="configini" src="https://github.com/DeMoNiiAkZz/E5---Projet-mobile/assets/116117908/c8033ee2-84f6-4684-b10e-667e38df7d6e">


**POUR LANCER LE PROJET** 

- Ouvrer sur VSCode le fichier **"lib\main.dart"** 
- Dans ce fichier si vous voyez au dessus du main() écrit **"RUN | DEBUG | PROFILE"** c'est bon signe
  <img width="308" alt="voidmain" src="https://github.com/DeMoNiiAkZz/E5---Projet-mobile/assets/116117908/fd89cc77-14b2-46ac-b3b4-4329a50ea1b1">

- Cliquer en **bas à droite** pour lancer l'appareil anddroid que vous souhaitez lancer le projet
 <img width="603" alt="appli" src="https://github.com/DeMoNiiAkZz/E5---Projet-mobile/assets/116117908/c84cf791-526a-45b0-876f-e244e4277498">

- Une fois l'android bien séléctionné cliquer sur **"Run"** au dessus du **void main()**

- Une fois l'application lancé vous accéderez à la page de connexion (le logo de l'entreprise est censé s'afficher en haut, elle provient du répertoire "LCS_Dash")
- Si WAMP est bien lancé, vous pouvez vous connecter avec ces identifiant 
	- e-mail : jesuistechnicien@gmail.com
	- Mot de passe : Jesuistechnicien55@

- Pour afficher des interventions, il y a deux solutions : 
  - rendez-vous dans la base de donnée dans la table "intervention" et remplacer les date_interventions par la date actuelle
  - ou via le calendrier de l'application mobile saisissez le 15 avril 2024
    
<img width="958" alt="date_interv" src="https://github.com/DeMoNiiAkZz/E5---Projet-mobile/assets/116117908/f4c9e29f-bd88-4b69-80dd-e53257df11c0">

- Chaque couleur représente une activité de l'entreprise
	- Bleu = Fibre optique
	- Rouge = Electricité
	- Vert = Borne de recharge véhicule
	- Orange = Energie solaire
	- Violet = Domotique

- Les différents statut :
	- A Faire
	- En cours (une intervention ou le technicien est dessus)
	- Terminée (Intervention fini mais le compte rendu n'est ni validé ni refusé par l'admin)
	- Reportée (Intervention reportée pour X raisons)
	- Validée (Compte rendu validé par l'admin)
	- Refusée (Compte rendu refusé par l'admin)

- Pour en savoir plus sur le fonctionnement de l'application regardez la vidéo ici : https://zoworld.fr/video_app_flutter.html


Bonne découverte de l'application 😉
En cas de problème, veuillez me contacter via mon adresse e-mail : cailac.enzo@gmail.com


	
