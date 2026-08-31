# claude-dev-workflow
> Version 2.2.0

Un système de documentation structuré pour travailler efficacement avec Claude sur des projets web.

---

## Le problème

Chaque nouvelle session Claude repart de zéro.
Aucune mémoire. Aucun contexte. Aucun historique du projet.

La plupart des devs créent un seul fichier CLAUDE.md qui regroupe tout —
le design, les pages, la base de données, les composants, tout.

Le problème : à chaque session Claude lit tout le fichier
pour trouver l'information dont il a besoin.

Plus le fichier est grand, plus les tokens partent
avant même que le vrai travail commence.

---

## La solution

Un ensemble de fichiers markdown structurés qui donnent à Claude exactement
ce dont il a besoin, au moment où il en a besoin.

Un fichier par sujet. Pas de bruit. Pas de gaspillage.
Et une séparation nette entre ce qui appartient au projet entier et ce qui appartient à une seule couche.

---

## Commande de démarrage

Copier cette ligne et la coller à Claude au début de chaque session :

```
Lis docs/CLAUDE.md, puis lis docs/frontend/PROGRESS.md et/ou docs/backend/PROGRESS.md selon la couche, et dis-moi où on en est en 5 lignes maximum
```

---

## Structure

```
docs/
├── CLAUDE.md      — orchestrateur, lu en premier toujours
├── CONTEXT.md     — partagés : vision et suivi du projet
├── PROGRESS.md    —   ⚠️ GÉNÉRÉ automatiquement, ne jamais éditer (voir plus bas)
├── DECISIONS.md   —   entier, jamais dupliqués par couche
├── CHANGELOG.md   — journal humain, pas lu automatiquement par Claude
├── STACK.md
├── SECURITY.md
├── frontend/
│   ├── PROGRESS.md       — snapshot frontend : phases, avancement, sessions
│   ├── STYLE.md          — design system, neutre vis-à-vis de la stack
│   ├── style-picker.html — outil local pour calibrer visuellement le style avant de remplir STYLE.md
│   ├── UI-QUALITY.md     — direction artistique, vérifiée avant de livrer une interface
│   ├── preset-actif.md   — LE preset installé pour ce projet (copié depuis presets/)
│   ├── presets/          — catalogue : tailwind-daisyui, tailwind-only, css-pur…
│   ├── PAGES.md, COMPONENTS.md
│   ├── ERRORS.md    — bugs frontend résolus
│   └── FEEDBACK.md  — réflexes IA à corriger côté frontend
└── backend/
    ├── PROGRESS.md  — snapshot backend : phases, avancement, sessions
    ├── DATABASE.md
    ├── TODO.md      — ce que le backend doit encore construire, déduit du frontend déjà fait en mock
    ├── ERRORS.md    — bugs backend résolus
    └── FEEDBACK.md  — réflexes IA à corriger côté backend
```

`CLAUDE.md` est le cerveau : c'est lui qui détermine, pour chaque tâche, s'il faut lire dans `frontend/`, `backend/`, ou les fichiers partagés à la racine — jamais tout `docs/` en bloc.

**Pourquoi `PROGRESS.md` fait exception** : un dev frontend et un dev backend sur des branches séparées qui éditent le même fichier de suivi finissent en conflit git. Chacun a désormais son propre `PROGRESS.md`, jamais touché par l'autre couche ; celui à la racine de `docs/` est une reconstruction automatique des deux (`.claude/scripts/merge-progress.sh`), déclenchée sur GitHub dès qu'un push sur `main` touche l'un des deux fichiers (`.github/workflows/merge-progress.yml`) — ou à la main sur un projet sans GitHub Actions. Détails dans `docs/CLAUDE.md` > "Fusion des PROGRESS.md".

---

## Pourquoi tout est séparé

Chaque fichier a un rôle unique et précis.
Claude ne lit que ce qui est utile pour la tâche en cours...

| Fichier | Rôle | Pourquoi séparé |
|---------|------|-----------------|
| CLAUDE.md | Point d'entrée, orchestrateur | Lu une seule fois au démarrage |
| CONTEXT.md | Vision du produit | Lu uniquement en première session |
| frontend/PROGRESS.md, backend/PROGRESS.md | Suivi des sessions, par couche | Lu et modifié à chaque début/fin de session — jamais l'autre couche |
| PROGRESS.md (racine) | Vue fusionnée des deux ci-dessus | Généré automatiquement, jamais lu ni édité en session |
| DECISIONS.md | Choix techniques | Lu avant toute nouvelle solution |
| CHANGELOG.md | Journal humain du projet, en langage clair | Jamais lu automatiquement par Claude — pour un nouveau développeur qui découvre le projet |
| STACK.md | Technologies | Lu avant toute installation |
| frontend/STYLE.md | Design system, neutre vis-à-vis de la stack | Lu avant toute interface, avec preset-actif.md |
| frontend/UI-QUALITY.md | Direction artistique — pourquoi une interface "correcte" peut quand même sentir l'IA | Vérifié avant de livrer une interface, pas avant de la commencer |
| frontend/preset-actif.md | Le preset installé pour ce projet | Lu à chaque tâche frontend, en même temps que STYLE.md |
| frontend/presets/ | Catalogue des presets disponibles | Consulté une seule fois, pour installer ou changer de preset |
| backend/DATABASE.md | Base de données | Lu avant toute modification de table |
| backend/TODO.md | Ce que le backend doit encore construire, déduit du frontend déjà fait en mock | Lu au début d'une tâche backend ; alimenté dès qu'une page frontend est construite en mock faute d'endpoint |
| frontend/PAGES.md | Pages du projet | Lu section par section selon la page |
| frontend/COMPONENTS.md | Composants | Lu avant tout nouveau composant |
| frontend/ERRORS.md | Bugs résolus côté interface | Lu quand un bug frontend apparaît |
| backend/ERRORS.md | Bugs résolus côté serveur/API | Lu quand un bug backend apparaît |
| frontend/FEEDBACK.md | Réflexes IA à corriger côté interface | Lu avant une tâche frontend à risque de pattern connu |
| backend/FEEDBACK.md | Réflexes IA à corriger côté serveur | Lu avant une tâche backend à risque de pattern connu |
| SECURITY.md | Failles de sécurité | Lu avant/après tout travail de sécurité |

Si tout était dans un seul fichier — Claude lirait tout
pour trouver une seule information. Tokens gaspillés. Temps perdu.
Et un réflexe CSS n'a rien à faire dans le contexte d'une tâche sur l'API.

---

## Comment ça fonctionne

| Action | Commande |
|--------|----------|
| Début de session | "Lis docs/CLAUDE.md puis docs/frontend/PROGRESS.md et/ou docs/backend/PROGRESS.md" |
| Travailler sur une page | "Lis docs/frontend/PAGES.md section [nom] et docs/frontend/STYLE.md" |
| Créer un composant | "Lis docs/frontend/COMPONENTS.md et docs/frontend/STYLE.md" |
| Savoir quoi construire côté backend | "Lis docs/backend/TODO.md" |
| Bug frontend rencontré | "Lis docs/frontend/ERRORS.md — j'ai ce bug : [description]" |
| Bug backend rencontré | "Lis docs/backend/ERRORS.md — j'ai ce bug : [description]" |
| Nouvelle décision | "Ajoute dans docs/DECISIONS.md — [sujet]" |
| Nouveau dev qui rejoint le projet | "Lis docs/CHANGELOG.md et résume-moi le projet" |
| Réflexe IA à corriger (frontend) | "Ajoute dans docs/frontend/FEEDBACK.md — [pattern]" |
| Réflexe IA à corriger (backend) | "Ajoute dans docs/backend/FEEDBACK.md — [pattern]" |
| Installer un preset de style | "Installe le preset [nom]" — copie docs/frontend/presets/[nom].md vers docs/frontend/preset-actif.md |
| Fin de session | "Mets à jour docs/frontend/PROGRESS.md (ou backend) session [numéro]" |
| Fusionner PROGRESS.md à la main (sans GitHub Actions) | "Fusionne PROGRESS.md" |
| Vérifier une mise à jour du template | "Vérifie si le template a une mise à jour" (fait aussi automatiquement à chaque début de session) |

---

## Rester à jour

Chaque projet garde son propre `docs/` — rempli au fil des sessions, jamais écrasé automatiquement.
`docs/CLAUDE.md` porte un numéro de version et vérifie tout seul, à chaque début de session, si une version plus récente du template existe.
En cas de mise à jour disponible, Claude te préviens et attend ton accord — puis n'ajoute que ce qui manque (nouveaux fichiers dans `docs/`, `.claude/` ou `.github/`, nouvelles règles). **Rien de ce que tu as déjà rempli n'est jamais modifié ou supprimé.**
Détail de la procédure dans `docs/CLAUDE.md` > "Mise à jour du template".

---

## Pourquoi ça marche

| Sans ce système | Avec ce système |
|-----------------|-----------------|
| 10 min à réexpliquer le contexte | 30 secondes pour reprendre |
| Tokens gaspillés sur le contexte | Tokens utilisés sur le vrai travail |
| Design incohérent entre les pages | Un seul STYLE.md appliqué partout |
| Progression perdue entre sessions | Sessions numérotées dans PROGRESS.md |
| Conflit git entre dev frontend et backend sur le suivi | Chacun son PROGRESS.md, fusion automatique sur main |
| Projet abandonné quand on se perd | Prochaine étape claire à chaque session |

---

## Installation

**Option 1 — one-liner (recommandé) :**

```bash
cd ton-projet
curl -fsSL https://raw.githubusercontent.com/ud20-dev/claude-dev-workflow/main/install.sh | bash
```

Installe `docs/`, `.claude/` (hook `SessionStart` qui charge `docs/CLAUDE.md` et les sessions récentes automatiquement, scripts `changelog.sh`/`merge-progress.sh`/`apply-update.sh`, skills `bum-dev`/`minmax`/`unslop`) et `.github/workflows/merge-progress.yml` directement à la racine de `ton-projet`. N'écrase jamais un fichier existant — s'arrête sans rien toucher si `docs/`, `.claude/settings.json`/`hooks`/`scripts`/`SKILLS` ou le workflow existent déjà.

**Option 2 — clone local, sans réseau au moment de l'installation :**

```bash
git clone https://github.com/ud20-dev/claude-dev-workflow ~/claude-dev-workflow
cd ton-projet
~/claude-dev-workflow/install.sh
```

Même résultat que l'option 1 — `install.sh` détecte le clone local et copie `docs/`/`.claude/`/`.github/` depuis celui-ci plutôt que de les télécharger.

---

## Contribuer

Tu as trouvé une façon d'améliorer le système ?
Ouvre une issue ou soumets une pull request.
Toutes les contributions sont les bienvenues.

Le pourquoi des choix d'architecture du template (pas ceux d'un projet qui l'utilise) est documenté dans [CONTRIBUTING.md](CONTRIBUTING.md).

---

## Licence

[MIT](LICENSE) — libre d'utilisation, modification et redistribution, y compris commerciale.

---

## Créé par

[UD20-dev](https://github.com/ud20-dev) — Nous créons des produits numériques.