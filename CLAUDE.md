# CLAUDE — claude-dev-workflow (le template lui-même)
> Ce fichier sert à travailler SUR ce repo — développer, corriger, faire évoluer le template.
> Différent de `docs/CLAUDE.md` : celui-là est le contenu distribué, copié tel quel chez qui installe le template. Celui-ci n'est jamais copié par `install.sh` (qui ne touche qu'à `docs/`, `.claude/` et `.github/`) — donc rien ici ne peut jamais atterrir chez un utilisateur.
> Pourquoi séparé : si on utilisait `docs/` pour suivre le développement réel de ce repo (vraies sessions, vrai historique), un install ferait hériter cette mémoire à l'utilisateur au lieu d'un `docs/` vierge. Deux dossiers = `docs/` reste toujours un template propre, celui-ci porte la mémoire réelle du projet.

---

## Pour situer le projet

- Vision et pourquoi ce template existe → `README.md`
- Pourquoi chaque choix d'architecture a été fait (et les alternatives refusées) → `CONTRIBUTING.md`
- Historique humain, version par version → `CHANGELOG.md`
- Où on en est, session par session → `PROGRESS.md` (racine, ce dossier — pas `docs/PROGRESS.md`, qui est un fichier généré du template lui-même, sans rapport)

---

## Règles

- Toute décision d'architecture du template (pas d'un projet qui l'utilise) → `CONTRIBUTING.md`, même format que `docs/DECISIONS.md`
- Changement notable côté template → entrée dans `CHANGELOG.md`, langage humain
- Fin de session de travail sur ce repo → `PROGRESS.md` (racine)
- Ne jamais confondre les deux CLAUDE.md : modifier `docs/CLAUDE.md` change ce que les utilisateurs reçoivent : à faire seulement quand c'est délibérément une évolution du template, jamais par réflexe
- Avant de livrer une nouvelle version : vérifier que rien de spécifique à ce repo (vraies décisions, vraies sessions) n'a fui dans `docs/` — `docs/` doit toujours pouvoir être copié tel quel chez un inconnu sans lui donner notre historique
