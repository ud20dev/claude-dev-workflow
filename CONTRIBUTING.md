# Décisions d'architecture du template

> Ce fichier documente pourquoi `docs/` est construit comme il est — pas les décisions d'un projet qui utilise le template (ça, c'est `docs/DECISIONS.md`, qui reste vide et se copie tel quel).
> Format identique à `docs/DECISIONS.md` pour rester cohérent.

---

### Séparation frontend/backend en sous-dossiers
- Décision : `docs/frontend/` et `docs/backend/` séparés, avec un socle partagé à la racine de `docs/` (CONTEXT, PROGRESS, DECISIONS, STACK, SECURITY)
- Pourquoi : un fichier `ERRORS.md`/`FEEDBACK.md` unique mélangeait des bugs/réflexes 100% frontend (CSS, DaisyUI) avec des bugs 100% backend (SQLAlchemy async) — une tâche backend chargeait du contexte frontend inutile, et inversement
- Alternative refusée : sous-sections `## Frontend` / `## Backend` à l'intérieur des mêmes fichiers
- Pourquoi refusée : n'évite pas de charger le contenu inutile en mémoire de lecture, juste visuellement séparé — l'objectif était de ne littéralement pas lire l'autre couche

### Preset installé via copie (`preset-actif.md`), pas un champ texte dans STACK.md
- Décision : `frontend/presets/` = catalogue en lecture seule, un preset choisi est copié vers `frontend/preset-actif.md`, seul fichier réellement lu avec STYLE.md
- Pourquoi : une première version utilisait un champ `STACK.md > Preset de style` avec le nom du preset, obligeant à recharger le mapping nom→fichier à chaque tâche. La copie directe élimine cette indirection — un seul fichier à lire, toujours au même endroit
- Alternative refusée : garder le nom dans STACK.md et charger `presets/[nom].md` dynamiquement
- Pourquoi refusée : fonctionne, mais une étape de résolution en plus à chaque tâche pour un gain nul — le principe "un seul fichier fait foi" est plus simple à appliquer sans exception

### Tous les presets du catalogue doivent avoir les mêmes titres de section
- Décision : `Boutons > Désactivé`, `Règles mobile — Touch targets`, `Règle CSS — No Camouflage`, `Fix inputs transparents / placeholder` — identiques mot pour mot dans chaque preset
- Pourquoi : sans cette contrainte, changer de preset changerait aussi la structure que STYLE.md pointe vers — un lien du type "voir preset-actif.md, section X" casserait selon le preset installé
- Alternative refusée : laisser chaque preset libre dans sa structure
- Pourquoi refusée : rendrait le système fragile au changement de stack en cours de projet, alors que c'est justement le cas d'usage que le mécanisme de preset est censé bien gérer

### `UI-QUALITY.md` séparé de `STYLE.md`
- Décision : fichier dédié à la direction artistique (checklist "ça sent l'IA ou pas"), distinct des valeurs exactes de STYLE.md
- Pourquoi : respecter STYLE.md mécaniquement (bons radius, bonnes couleurs) ne garantit pas un résultat qui a l'air conçu plutôt que généré — deux problèmes différents (valeurs correctes vs. jugement esthétique) qui ont besoin de deux fichiers différents, lus à deux moments différents (avant de commencer vs. avant de livrer)
- Alternative refusée : une section de plus dans STYLE.md
- Pourquoi refusée : STYLE.md est lu à chaque tâche, UI-QUALITY.md seulement avant de livrer — les fusionner aurait fait relire la checklist qualité à chaque petite modification, pas seulement en fin de tâche

### `style-picker.html` en fichier local plutôt qu'en artifact généré à la demande
- Décision : fichier statique livré dans `frontend/`, ouvert par double-clic, jamais régénéré
- Pourquoi : un artifact généré à chaque demande n'est pas réutilisable d'une session à l'autre ni partageable avec un autre développeur du même projet (ex. le dev backend qui voudrait voir ce qui a été choisi)
- Alternative refusée : artifact à la demande
- Pourquoi refusée : recrée l'outil à chaque fois au lieu de le posséder — contraire au principe même du template (mémoire persistante, pas régénération)

### CHANGELOG.md séparé de PROGRESS.md
- Décision : fichier dédié en langage humain, jamais lu automatiquement par Claude, pour qu'un nouveau développeur comprenne l'histoire du projet en le lisant
- Pourquoi : PROGRESS.md est optimisé pour que Claude le lise vite (pointeurs, champs terses) — un humain qui découvre le projet a besoin d'une narration, pas d'un format conçu pour une IA. Les deux publics ont des besoins de lecture incompatibles avec un seul fichier
- Alternative refusée : enrichir PROGRESS.md pour qu'il serve aux deux publics
- Pourquoi refusée : un format qui sert bien Claude (terse, structuré) sert mal un humain (illisible en narration), et inversement — mieux vaut deux fichiers avec un rôle clair qu'un compromis qui ne sert bien personne

### `backend/TODO.md` ajouté après usage réel sur un projet
- Décision : nouveau fichier `backend/TODO.md`, alimenté côté frontend dès qu'une page/fonctionnalité est construite en mock faute d'endpoint (règle absolue dans CLAUDE.md), lu en priorité au début d'une tâche backend
- Pourquoi : sur un projet frontend-first (fréquent avec Claude — l'interface avance plus vite que l'API), le mock fait à un instant T finit oublié une fois la session suivante commencée ; sans un endroit dédié, soit ce contexte se perd, soit `PROGRESS.md` s'alourdit d'un inventaire d'endpoints manquants qui n'a rien à faire dans un journal de sessions. Retenu après avoir constaté l'utilité du fichier sur un projet réel utilisant ce template (quasi une entrée par session frontend)
- Alternative refusée : consigner les endpoints manquants directement dans `PROGRESS.md`
- Pourquoi refusée : `PROGRESS.md` répond à "qu'est-ce qui s'est passé", pas à "qu'est-ce qu'il reste à construire" — mélanger les deux aurait fait grossir chaque session d'un rappel de tout ce qui manque encore côté backend, déjà couvert une fois pour toutes dans un fichier dédié

### Mise à jour du template additive uniquement, jamais silencieuse
- Décision : `docs/CLAUDE.md` porte un numéro de version, vérifié automatiquement à chaque début de session (et sur demande) contre le README publié sur GitHub. Si une version plus récente existe, Claude informe l'utilisateur et attend son accord avant de toucher quoi que ce soit. Avant d'appliquer, vérification que le dépôt du projet est propre (`git status`) — sinon on demande de commiter/stasher d'abord, pour que la mise à jour reste annulable d'un simple `git restore` en cas de souci. Une fois accepté, seuls les éléments absents (nouveaux fichiers, nouvelles lignes de règles/tables) sont ajoutés — aucune ligne déjà présente n'est jamais modifiée ni supprimée, même si sa formulation diffère de celle du template
- Pourquoi : un projet qui utilise ce template pendant des mois finit par diverger volontairement de la version d'origine (une règle reformulée, assouplie, adaptée à un cas particulier — voir par exemple les "Règles absolues" d'un vrai projet, souvent moins strictes que le template de base). Un mécanisme de mise à jour qui écraserait le fichier avec la dernière version du template détruirait ces adaptations sans prévenir. Additive-only + confirmation explicite est la seule version de ce mécanisme qui ne peut pas perdre de travail
- Alternative refusée : remplacer purement et simplement les fichiers partagés par la dernière version du template à chaque mise à jour, silencieusement
- Pourquoi refusée : plus simple à implémenter, mais suppose que rien n'a jamais été personnalisé dans le projet — faux dès la première vraie session. Le risque (perdre une règle affinée au fil de mois de travail, sans même être prévenu) dépasse largement le gain (ne pas avoir à confirmer une poignée d'ajouts)

### 4 axes (Mémoire / Skill / Garde-fou / Onboarding) comme grille de lecture, pas comme arborescence
- Décision : classification ajoutée dans CLAUDE.md, sans créer de dossiers `memoire/`, `skills/`, `garde-fous/`, `onboarding/`
- Pourquoi : le découpage frontend/backend organise déjà l'espace physique et fonctionne (validé par test) ; les 4 axes répondent à une question différente ("quel type d'information, pour qui ?"), pas "où est-ce rangé physiquement ?" — les deux grilles se croisent sans se remplacer
- Alternative refusée : réorganiser `docs/` en dossiers par axe
- Pourquoi refusée : casserait le découpage frontend/backend déjà éprouvé pour un gain seulement cosmétique

### `docs/PROGRESS.md` scindé en `frontend/PROGRESS.md` + `backend/PROGRESS.md`, la racine devient un fichier généré
- Décision : `docs/PROGRESS.md` n'est plus édité à la main — chaque couche a son propre fichier de suivi (`frontend/PROGRESS.md`, `backend/PROGRESS.md`, numérotation de session indépendante), et `docs/PROGRESS.md` (racine) est reconstruit mécaniquement à partir des deux par `.claude/scripts/merge-progress.sh`, déclenché automatiquement par `.github/workflows/merge-progress.yml` à chaque push sur `main` (donc aussi un merge de PR) sur un projet GitHub avec Actions activé, ou à la main sinon
- Pourquoi : `PROGRESS.md` était le seul fichier partagé de `docs/` édité à *chaque* session, par les deux couches. Un dev frontend et un dev backend sur des branches séparées finissaient systématiquement en conflit git dessus. Contrairement à `CONTEXT.md`/`DECISIONS.md`/`STACK.md` (édités rarement), la fréquence d'édition rendait ce fichier-là seul responsable de la quasi-totalité des conflits sur `docs/` en usage réel à deux devs
- Pourquoi une GitHub Action plutôt qu'un hook git local (`pre-push`) : `docs/CLAUDE.md` interdit déjà de toucher `main` directement (garde-fou contre Claude qui pousserait seul, pas une règle de process). En pratique le merge sur `main` se fait donc via une PR mergée sur l'interface GitHub — un événement serveur qu'aucun hook git local ne peut observer. Un hook `post-merge` qui se déclencherait localement au `git pull` de chaque dev poserait en plus un autre problème : plusieurs machines régénéreraient chacune le fichier fusionné de leur côté et se marcheraient dessus au push suivant — exactement le conflit qu'on essaie d'éliminer, déplacé sur un autre fichier. Une Action tourne une seule fois, côté serveur, jamais en double
- Alternative refusée : garder `PROGRESS.md` unique à la racine, sensibiliser les devs à bien se coordonner
- Pourquoi refusée : repose sur la discipline humaine pour un problème que la structure des fichiers peut éliminer à la source ; le reste du template évite déjà ce genre de pari (voir `presets/` en lecture seule, `backend/TODO.md`, etc.)
- Alternative refusée : fusionner par un hook git local (`pre-push` ou `post-merge`) plutôt qu'une GitHub Action
- Pourquoi refusée : ne se déclenche jamais si le merge passe par l'interface GitHub (cas réel testé), et risque de collision multi-machines si on le fait tourner sur `post-merge` — voir ci-dessus
- Champs qui ne sont ni frontend ni backend (Phases du projet, Phase actuelle, Progression globale) : dupliqués dans les deux fichiers plutôt que sortis dans un troisième fichier partagé — à la fusion, la version du fichier modifié le plus récemment (comparaison par historique git) est retenue. Choisi pour éviter un troisième point d'édition à synchroniser en plus des deux fichiers de couche
- Migration d'un projet déjà installé (1.x → 2.x) : l'ancien `docs/PROGRESS.md` est renommé `docs/PROGRESS-archive.md` (jamais supprimé, jamais lu automatiquement) plutôt que d'essayer de deviner automatiquement quelle session passée était frontend ou backend — une session peut couvrir les deux, deviner risquerait de mal classer ou de couper une entrée en deux. Voir `.claude/scripts/changelog.sh`
- Constat annexe en construisant cette fonctionnalité : la procédure de mise à jour du template ne comparait jusque-là que `docs/CLAUDE.md`, jamais `.claude/hooks/`, `.claude/scripts/`, `.claude/SKILLS/`, `.claude/settings.json` ni `.github/workflows/` — un projet mis à jour depuis une ancienne version n'aurait donc jamais reçu automatiquement `session-start.sh`, les skills, ou ce nouveau workflow. Corrigé en même temps (voir `docs/CLAUDE.md` > "Mise à jour du template", étape 3) : indépendant du split PROGRESS.md dans le principe, mais devenu bloquant pour lui puisque le mécanisme de fusion en dépend
