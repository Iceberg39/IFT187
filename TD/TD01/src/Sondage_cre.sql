/*
============================================================================== A
Produit : CoFELI:Exemple/Sondage
Trimestre : 2026-3
Composant : Sondage_cre.sql (ébauche)
Encodage : UTF-8, sans BOM; fin de ligne Unix (LF)
Plateforme : PostgreSQL 9.4 à 16.2
Responsables : christina.khnaisser@usherbrooke.ca ; luc.lavoie@usherbrooke.ca
Version : 0.1.1a
Statut : travail en cours
============================================================================== A
*/

/*
============================================================================== B
Référence du schéma correspondant au modèle Sondage documenté dans [epp].
============================================================================== B
*/

SET SCHEMA 'Sondage' ;

CREATE DOMAIN IdQuestionnaire
/*
Trypon Tournesol a décider le numération qu'il entendait donner à ses questionnaires.
*/
  CHAR(7)
  CONSTRAINT IdQuestionnaire_inv
        Check (VALUE SIMILAR TO 'Q[0-9]{6}') ;

CREATE DOMAIN Courriel

    VARCHAR(512)
    CONSTRAINT Courriel_inv
        CHECK (
            VALUE SIMILAR TO '[A-Za-z0-9]+(\.[A-Za-z0-9]+)*@[A-Za-z0-9]+(\.[A-Za-z0-9]+)*'
            );

CREATE DOMAIN Matricule
    CHAR(8)
    CONSTRAINT Matricule_inv
        CHECK ( VALUE SIMILAR TO '[0-9]{8}');

CREATE DOMAIN NoChoix
    SMALLINT
    CONSTRAINT NoChoix_inv
        CHECK ( VALUE >= 0 AND VALUE < 1000);

CREATE DOMAIN Nom
    VARCHAR(64)
    CONSTRAINT Nom_inv
        CHECK ( VALUE != '');

CREATE DOMAIN NoQuestion
    SMALLINT
    CONSTRAINT NoQuestion_inv
        CHECK ( VALUE >= 0 AND VALUE < 10000);

CREATE DOMAIN Titre
    VARCHAR(80)
    CONSTRAINT Titre_inv
        CHECK ( VALUE != '');

CREATE DOMAIN TypeQuestion
    VARCHAR(4)
    CONSTRAINT TypeQuestion_inv
        CHECK ( VALUE = 'QCM' OR VALUE = 'QO' OR VALUE = 'QCMO');

CREATE DOMAIN Description
    VARCHAR(250);




CREATE TABLE Questionnaire
/*
Le questionnaire "idQ" dont le titre est "titre" a été créé par l’auteur "auteur";
la période de saisie des réponses débute le "dateDebut" et se termine le
"dateFin".
*/
  (
    idQ IdQuestionnaire NOT NULL,
    titre Titre NOT NULL,
    auteur Nom NOT NULL,
    dateDebut DATE NOT NULL,
    dateFin DATE NOT NULL,
    CONSTRAINT Questionnaire_cc0 PRIMARY KEY (idQ),
    CONSTRAINT Questionnaire_date CHECK (dateDebut <= dateFin)
  );

CREATE TABLE Question
    (
        idQ IdQuestionnaire NOT NULL,
        noQ NoQuestion NOT NULL,
        typeQ TypeQuestion NOT NULL,
        obligatoire BOOLEAN NOT NULL,
        CONSTRAINT Question_cc0 PRIMARY KEY (idQ, noQ),
        CONSTRAINT Question_cc1 FOREIGN KEY (idQ) REFERENCES Questionnaire (idQ)

);

CREATE TABLE ChoixQCM
    (
        idQ IdQuestionnaire NOT NULL,
        noQ NoQuestion NOT NULL,
        noChoix NoChoix NOT NULL,
        description Description NOT NULL,
        CONSTRAINT ChoixQCM_cc0 PRIMARY KEY (idQ, noQ, noChoix),
        CONSTRAINT ChoixQCM_cc1 FOREIGN KEY (idQ, noQ) REFERENCES Question (idQ, noQ)
);

CREATE TABLE Repondant
    (
        nom Nom NOT NULL,
        prénom Nom NOT NULL,
        courriel Courriel NOT NULL,
        matricule Matricule NOT NULL,
        CONSTRAINT Repondant_cc0 PRIMARY KEY (matricule),
        CONSTRAINT Repondant_cc1 UNIQUE (courriel)
);

CREATE TABLE Formulaire
    (
        idQ IdQuestionnaire NOT NULL,
        matricule Matricule NOT NULL,
        dateReponse DATE NOT NULL,
        CONSTRAINT Formulaire_cc0 PRIMARY KEY (idQ, matricule),
        CONSTRAINT Formulaire_cc1 FOREIGN KEY (idQ) REFERENCES Questionnaire (idQ),
        CONSTRAINT Formulaire_cc2 FOREIGN KEY (matricule) REFERENCES Repondant (matricule)
);

CREATE TABLE Reponse
    (
        idQ IdQuestionnaire NOT NULL,
        matricule Matricule NOT NULL,
        noQ NoQuestion NOT NULL,
        CONSTRAINT Reponse_cc0 PRIMARY KEY (idQ, matricule, noQ),
        CONSTRAINT Reponse_cc1 FOREIGN KEY (idQ, matricule) REFERENCES Formulaire (idQ, matricule),
        CONSTRAINT Reponse_cc2 FOREIGN KEY (idQ, noQ) REFERENCES Question (idQ, noQ)
);

CREATE TABLE RCM
    (
        noChoix NoChoix NOT NULL,
        idQ IdQuestionnaire NOT NULL,
        matricule Matricule NOT NULL,
        noQ NoQuestion NOT NULL,
        CONSTRAINT RCM_cc0 PRIMARY KEY (idQ, matricule, noQ),
        CONSTRAINT RCM_cc1 FOREIGN KEY (idQ, matricule, noQ) REFERENCES Reponse (idQ, matricule, noQ),
        CONSTRAINT RCM_cc2 FOREIGN KEY (idQ, noQ, noChoix) REFERENCES ChoixQCM (idQ, noQ, noChoix)
);

CREATE TABLE RO
    (
        idQ IdQuestionnaire NOT NULL,
        matricule Matricule NOT NULL,
        noQ NoQuestion NOT NULL,
        texteReponse Description NOT NULL,
        CONSTRAINT RO_cc0 PRIMARY KEY (idQ, matricule, noQ),
        CONSTRAINT RO_cc1 FOREIGN KEY (idQ, matricule, noQ) REFERENCES Reponse (idQ, matricule, noQ)
);
--
-- À compléter par les contributeurs
--

/*
============================================================================== Z
.Contributeurs :
  (BG) Bernadette.Guérard@USherbrooke.ca,
  (AF) Anatole.France@USherbrooke.ca

.Adresse, droits d’auteur et copyright :
  Département d’informatique
  Faculté des sciences
  Université de Sherbrooke
  Sherbrooke (Québec)  J1K 2R1
  Canada

  [CC-BY-NC-4.0 (http://creativecommons.org/licenses/by-nc/4.0)]

.Tâches projetées :
  S.O.

.Tâches réalisées :
  * 2024-04-04 (LL01) : Restructuration pour intégration à CoFELI
    - Changement de noms, élimination des fichiers doublons
  * 2022-01-10 (LL01) : Diverses corrections de coquilles
    - Uniformisation des commentaires
  * 2015-09-14 (LL01) : Revue.
  * 2015-08-20 (CK01) : Création initiale.

.Références :
  * [epp] CoFELI:Exemples/Sondage/Sondage_DDV.pdf
  * [std] Akademia:Modules/BD190-STD-SQL-01_NDC.pdf

--------------------------------------------------------------------------------
-- fin de Sondage_cre.sql
============================================================================== Z
*/