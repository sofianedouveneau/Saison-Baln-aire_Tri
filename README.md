Ce projet portait sur la conception et le peuplement d'une base de données dédiée aux rapportages de la saison balnéaire 2024.
L’objectif n’était pas seulement de créer la structure relationnelle, mais aussi de comparer deux approches : l’écriture manuelle du script SQL et la génération automatique via un AGL qui était, en l'occurence, Looping.

J'ai d'abord rédigé entièrement le script SQL à la main. Cela impliquait de supprimer les tables existantes afin de m'assurer que le script ne rencontre pas d'erreurs, définir préciément les clés primaires et étrangères, d'ajouter les contraintes ON DELETE CASCADE, et de choisir les types de données adaptés (par exemple DOUBLE PRECISION pour les coordonnées et DATE pour les dates) pour garantir ultérieurement, une utiliation fiable et simple des données.
Ensuite, j’ai étudié la modélisation et la génération automatique réalisées avec l’AGL Looping. À partir du modèle conceptuel de données (MCD), l’outil produit automatiquement le modèle physique (MPD) et le script SQL correspondant. Les associations maillées sont transformées en tables intermédiaires intégrant les clés primaires comme clés étrangères, tandis que les associations fonctionnelles sont traduites selon la cardinalité dite 'portante'.
*Portante est un terme que j’utilise personnellement pour décrire la cardinalité de la table participantesituée du côté de la cardinalité max de 1 car elle “porte” la clé étrangère de l’autre table.*

L’approche AGL présente plusieurs avantages :
Gain de temps important.
Réduction des erreurs syntaxiques.
Génération rapide d’un schéma cohérent.

Cependant, comme toute abstraction, elle a ses limites. Le code généré est souvent plus générique, parfois moins optimisé et moins lisible. Incluant des options qui ne sont pas toujours les plus pertinents selon le contexte. À l’inverse, l’écriture manuelle est plus longue mais offre un contrôle total sur la structure et les optimisations.

La phase de peuplement des tables a également été déterminante. J’ai d’abord importé les fichiers CSV dans des tables temporaires afin de centraliser et nettoyer les données. Cette étape intermédiaire m’a permis d’utiliser des transformations comme SELECT DISTINCT, LPAD, TO_DATE ou encore le remplacement des virgules dans les coordonnées pour garantir la cohérence des types.
Pour les tables analyses et evenements, les fichiers sources ne contenaient pas d’identifiants uniques. J’ai donc modifié le script en ajoutant GENERATED ALWAYS AS IDENTITY afin de générer automatiquement une clé primaire pour chaque enregistrement. J’ai aussi ajusté certains types (coordonnées, dates) afin de rendre les données exploitables dans d’autres contextes (requêtes, analyses, visualisations).
