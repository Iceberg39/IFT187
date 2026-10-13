/*
============================================================================== B
                                      Y02
                              Définir des fonctions.
--------------------------------------------------------------------------------
Choix_nb (idQ, noQ) : INTEGER ;
Retourne le nombre de choix de la question noQ du questionnaire idQ.

Choix_corrects (idQ, noQ) : BOOLEAN ;
Retourne vrai si et seulement si les choix de la question noQ du questionnaire idQ
sont numérotés de 1 à n, où n est le nombre de choix de la question
(il s’agit de vérifier les valeurs des attributs noChoix idoines).

Réponse_legitime (idQ, noQ, matR) : BOOLEAN ;
Retourner vrai si et seulement si la réponse respecte les règles suivantes :

- pas de RCM et RO simultanément;
- QCM  -> RCM seulement;
- QO   -> RO seulement;
- QCMO -> RCM ou RO;
- numéro de choix légitime pour une RCM;
- réponse présente si la question est obligatoire;
- saisie comprise entre ouverture et fermeture.
============================================================================== B
*/
DROP FUNCTION Choix_nb(val_idq idquestionnaire, val_noq noquestion);
CREATE OR REPLACE FUNCTION Choix_nb (val_idq idquestionnaire, val_noq noquestion)
    RETURNs INTEGER
    LANGUAGE sql AS
    $$
    SELECT count(nochoix) AS nombreChoix
    FROM choixqcm
    WHERE idq = val_idq AND noq = val_noq
    $$;

SELECT * FROM Choix_nb('Q000001'::idquestionnaire, 5::noquestion);

CREATE OR REPLACE FUNCTION Choix_corrects (val_idq idquestionnaire, val_noq noquestion)
    RETURNS BOOLEAN
    LANGUAGE sql AS
    $$
    SELECT CASE
    $$