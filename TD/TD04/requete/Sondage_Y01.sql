
/*
============================================================================== B
                                      Y01
                              Modifier le schéma
--------------------------------------------------------------------------------
. Ajouter un type (DOMAIN) pour représenter un point dans le temps (TIMESTAMP)
   à la seconde près.

. Modifier le l’identifiant et le type des attributs dateDebut (-> ouverture) et
   dateFin (-> fermeture) de la table Questionnaire.

. Retirer l’attribut dateReponse de Formulaire et ajouter l’attribut saisie à
   la table Reponse afin que désormais soit consigné non pas la date de saisie
   de la réponse au formulaire, mais le moment de la saisie (à la seconde près)
   de la réponse.

. Pour les données existantes, lors de leur migration, assumer que le moment
   de la saisie de la réponse est midi à la dateReponse du formulaire associé
   à la réponse.
============================================================================== B
*/
CREATE DOMAIN EstampilleM AS
    TIMESTAMP WITHOUT TIME ZONE;

ALTER TABLE questionnaire
ALTER COLUMN datedebut TYPE EstampilleM;
ALTER TABLE questionnaire
RENAME COLUMN datedebut TO ouverture;
ALTER TABLE questionnaire
ALTER COLUMN datefin TYPE EstampilleM;
ALTER TABLE questionnaire
RENAME COLUMN datefin TO fermeture;

ALTER TABLE reponse
ADD COLUMN saisie EstampilleM;

WITH dateReponse AS (
    SELECT datereponse
    FROM reponse
    JOIN formulaire USING (idq, matricule)
)
UPDATE reponse
SET saisie = to_timestamp(extract(EPOCH FROM dateReponse.datereponse) + 43200)
WHERE saisie IS NULL;

ALTER TABLE formulaire
DROP COLUMN datereponse CASCADE;