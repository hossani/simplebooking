-- Project brief SQL --
create database guichet;
use guichet;
-- Créer la table ville
CREATE TABLE ville (
    id_ville INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(20) NOT NULL,
    region VARCHAR(20) NOT NULL
);

-- Créer la table categorie
CREATE TABLE categorie (
    id_cat INT AUTO_INCREMENT PRIMARY KEY,
    titre VARCHAR(50) NOT NULL
);

-- Créer la table evenement
CREATE TABLE evenement (
    id_event INT AUTO_INCREMENT PRIMARY KEY,
    titre VARCHAR(50) NOT NULL,
    description TEXT,
    date_creation DATE default current_timestamp,
    id_cat INT,
    FOREIGN KEY (id_cat) REFERENCES categorie(id_cat)
);

-- Créer la table utilisateur
CREATE TABLE utilisateur (
    id_user INT AUTO_INCREMENT PRIMARY KEY,
    nom VARCHAR(20) NOT NULL,
    prenom VARCHAR(20) NOT NULL,
    email VARCHAR(20) NOT NULL UNIQUE,
    password VARCHAR(20) NOT NULL,
    role BOOLEAN NOT NULL DEFAULT FALSE,
    status BOOLEAN NOT NULL DEFAULT true,
    mode_payement varchar(20) ,
    id_admin INT,
    FOREIGN KEY (id_admin) REFERENCES utilisateur(id_user),
    CHECK (role IN (TRUE, FALSE)),
    CHECK (status IN (TRUE, FALSE)),
	CHECK (mode_payement IN ('visa', 'paypal','master card'))
);

-- Créer la table show
CREATE TABLE shows (
    id_show INT AUTO_INCREMENT PRIMARY KEY,
    image varchar(50) not null,
    prix int CHECK (prix > 0),
    ticket_count INT NOT NULL,
    ticket_disponible INT NOT NULL check (ticket_disponible <= ticket_count),
    show_date DATETIME NOT NULL,
    status VARCHAR(20) default 'disponible',
    date_creation date DEFAULT CURRENT_TIMESTAMP,
    id_ville INT,
    id_event INT,
    FOREIGN KEY (id_ville) REFERENCES ville(id_ville),
    FOREIGN KEY (id_event) REFERENCES evenement(id_event),
    check (status in ('disponible','annuler','epuiser'))
);

-- Créer la table reservation
CREATE TABLE reservation (
    id_user INT,
    id_show INT,
    quantite INT NOT NULL,
    montant INT,
    date_operation DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (id_user) REFERENCES utilisateur(id_user),
    FOREIGN KEY (id_show) REFERENCES shows(id_show),
    PRIMARY KEY (id_user, id_show)
);

-- Ajouter administrateur
INSERT INTO utilisateur (nom, prenom, email, password,role)
VALUES ('admin1', 'hassan', 'admin1.hassan@gmail.com', 'mdp123',true);

-- Ajouter les villes, les categories, les evenements, les shows
INSERT INTO ville (nom, region)
VALUES ('Rabat', 'Mohammed'),('Casablanca','Medina');

INSERT INTO categorie (titre)
VALUES ('Concert'),('Theatre');

INSERT INTO evenement (titre, description, id_cat)
VALUES ('Concert Rock', 'Un grand concert de rock', 1),
('Hassan theatre', 'Un grand theatre edition 2', 2);

INSERT INTO evenement (titre, description, id_cat)
VALUES ('Humouragi', 'humour', 2);

INSERT INTO shows (image, prix, ticket_count, ticket_disponible, show_date, id_ville, id_event)
VALUES ('images/Capture1.PNG', 200, 150, 150, '2024-05-01 20:00:00', 1, 1),
('images/Capture2.PNG', 350, 200, 200, '2024-08-01 22:00:00', 2, 2);

INSERT INTO shows (image, prix, ticket_count, ticket_disponible, show_date, id_ville, id_event)
VALUES ('images/Capture2023.PNG', 1000, 800, 800, '2023-08-01 22:00:00', 2, 2);

-- Ajouter clients et la reservation du premier client
INSERT INTO utilisateur (nom, prenom, email, password)
VALUES ('Ali', 'Smith', 'ali.smith@gmail.com', 'mdp123'),
('Hamza', 'Hossani', 'hamza.hossani@gmail.com', 'mdp123'),
('Sara', 'Smith', 'sara.smith@gmail.com', 'mdp123');

INSERT INTO reservation (id_user, id_show, quantite, montant)
VALUES (2, 1, 6, (select prix*6 from shows where id_show=1));

INSERT INTO reservation (id_user, id_show, quantite, montant)
VALUES (3, 2, 2, (select prix*2 from shows where id_show=2));

INSERT INTO reservation (id_user, id_show, quantite, montant)
VALUES (4, 2, 4, (select prix*4 from shows where id_show=2));

INSERT INTO reservation (id_user, id_show, quantite, montant)
VALUES (4, 3, 2, (select prix*2 from shows where id_show=3));

-- Modifier le status de deuxieme client
UPDATE utilisateur
SET status = false
WHERE id_user = 2;

-- Modifier le prix de deuxieme show et ticket diponible
UPDATE shows
SET prix = 500 , ticket_disponible=50
WHERE id_show = 1;

-- Supprimer le deuxieme client de la liste des reservation et liste des utilisateurs
set sql_safe_updates=0;
DELETE FROM  reservation
WHERE id_user = 2;

DELETE FROM  utilisateur
WHERE id_user = 2;

-- Supprimer des multiples lignes pour des shows d'un evenement
DELETE FROM reservation
WHERE id_show IN (SELECT id_show FROM shows WHERE id_event = 2);

DELETE FROM shows
WHERE id_event = 2;

-- le chiffre d'affaires d'une année données (ex:2024)
select sum(r.montant) as 'chiffre d\'affaires'
from reservation r
where year(date_operation)=2024;

-- le chiffre d'affaires par évenement
select s.id_event as 'Id d\'evenement', sum(r.montant)
from reservation r
join shows s
on r.id_show=s.id_show
group by s.id_event; 

-- les shows passés d'un evenement
select s.*,e.titre as 'titre d\'evenement'
from shows s
join evenement e on s.id_event=e.id_event
where (e.id_event=2 and s.show_date<now());

-- le nombre de personnes présentes à un événement
select e.titre as 'titre d\'evenemenet', sum(r.quantite) as 'nbr personne'
from reservation r
join  shows s on r.id_show=s.id_show
join evenement e on e.id_event=s.id_event
group by e.titre;

-- la liste des evenement d'une categorie
select e.titre as 'titre evenement' , c.titre as 'categorie'
from evenement e
join categorie c on e.id_cat=c.id_cat
where c.id_cat=2;
