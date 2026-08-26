# PROGRESS — claude-dev-workflow (le template lui-même)
> Suivi de session à session du développement de ce repo. Jamais copié par `install.sh`, jamais confondu avec `docs/PROGRESS.md` (fichier généré appartenant au template distribué).
> La plus récente en haut.

---

## Sessions

<!-- SENTINEL: nouvelle session ICI, juste en dessous de cette ligne — jamais en bas du fichier -->

### Session 003 — 24/08/2026
- Fait : passe de supervision à 9 agents (3 QA sur le pipeline apply-update.sh/merge-progress.sh non commité — revue adversariale, tests bout-en-bout, cohérence doc ; puis 6 sur le système de mémoire `docs/` — index/routage, duplication inter-fichiers, passage à l'échelle, terminologie, coût token de session-start.sh, format de stockage), tous en parallèle, findings vérifiés à la main avant application. Corrigé sur leur base : SECURITY.md absent de la table Aiguillage (bug de routage réel), note grep-avant-lecture-complète pour ERRORS/FEEDBACK/DECISIONS volumineux ; `session-start.sh` n'injecte plus la section "Mise à jour du template" (~24% du fichier) sauf si une mise à jour est réellement disponible — testé dans les deux cas, ~800 mots économisés par session normale sans rien perdre
- Corrigé : 4 bugs réels trouvés par la revue adversariale, tous reproduits puis vérifiés corrigés — `merge-progress.sh` fragmentait une session dont le corps contenait un bloc de code commençant par `### Session` (manque de conscience des fences) ; `merge-progress.sh` inversait l'ordre de deux sessions à la même date ; `apply-update.sh` avalait silencieusement un échec `curl` (pipe `curl | tar` masquait le code de sortie, `tar` sur flux vide sort à 0) et rapportait "rien à ajouter" au lieu d'échouer ; `changelog.sh` affichait le texte de migration "1.x → 2.x" pour n'importe quel saut de version future, même au-delà de 3.x
- Bloqué sur : rien
- Prochaine étape : décider si les recommandations non appliquées valent le coup — renommage FEEDBACK.md/PROGRESS.md racine (audit terminologie), dédoublonnage STYLE.md ↔ presets (touch targets + No Camouflage dupliqués dans les 3 presets), tags de recherche dans ERRORS/FEEDBACK/DECISIONS, convention d'archive façon PROGRESS-archive.md pour ERRORS/DECISIONS devenus volumineux — aucune n'est urgente, toutes documentées dans les rapports d'agents de cette session
- Fichier à lire en priorité : CHANGELOG.md (racine) — section Fixed de `[Unreleased]` pour le détail des 4 bugs

### Session 002 — 24/08/2026
- Fait : version 2.0.0 réellement publiée (README + `docs/CLAUDE.md` alignés, `CHANGELOG.md` `[Unreleased]` transformé en entrée `[2.0.0]` datée) — vérifié en direct sur le repo GitHub publié après coup ; le workflow `merge-progress.yml` a tourné tout seul en production sur le vrai push et régénéré `docs/PROGRESS.md` correctement, première validation en conditions réelles ; nouveau `.claude/scripts/apply-update.sh` qui automatise la partie mécanique d'une mise à jour (copie des fichiers entièrement absents dans `.claude/hooks/`, `.claude/scripts/`, `.claude/SKILLS/`, `.github/workflows/`, `docs/`), `docs/CLAUDE.md` > "Mise à jour du template" mis à jour pour l'utiliser à l'étape 2 — ne laisse plus que `docs/CLAUDE.md` et `settings.json` à comparer à la main au lieu de six emplacements
- Corrigé : bug de versioning trouvé avant publication — le README affichait "1.2.0 (WIP, do not use)" pendant le développement, et le hook `SessionStart` (qui ne comprend pas le texte d'avertissement, juste le numéro) proposait quand même la mise à jour ; reproduit en tout début de session 001. Fix : le README ne bouge plus jamais de numéro pendant un WIP, seul `CHANGELOG.md` > `[Unreleased]` accumule le travail en cours
- Bloqué sur : le premier `git push` a été refusé par GitHub (token sans scope `workflow`, requis pour modifier `.github/workflows/`) — résolu via `gh auth login` + `gh auth refresh -s workflow` + `gh auth setup-git` (le cache `osxkeychain` gardait l'ancien token, `setup-git` a forcé la priorité sur le nouveau)
- Prochaine étape : rien d'identifié pour l'instant
- Fichier à lire en priorité : CHANGELOG.md (racine) — entrée `[Unreleased]` pour `apply-update.sh`, à transformer en version datée quand ce sera republié

### Session 001 — 23/08/2026
- Fait : `docs/PROGRESS.md` scindé en `docs/frontend/PROGRESS.md` + `docs/backend/PROGRESS.md` (conflits git entre dev frontend/backend sur le fichier de suivi partagé) ; `docs/PROGRESS.md` devient un fichier généré, reconstruit par `.claude/scripts/merge-progress.sh` ; `.github/workflows/merge-progress.yml` déclenche la fusion automatiquement à chaque push sur `main` ; migration 1.x → 2.x documentée dans `.claude/scripts/changelog.sh` (archive de l'ancien PROGRESS.md, jamais de split automatique de l'historique)
- Corrigé : procédure de mise à jour du template (`docs/CLAUDE.md` > "Mise à jour du template") ne comparait que `docs/CLAUDE.md` — étendue à `.claude/hooks/`, `.claude/scripts/`, `.claude/SKILLS/`, `.claude/settings.json` et `.github/workflows/`, sinon un projet existant qui met à jour n'aurait jamais reçu automatiquement `session-start.sh`, les skills, ou ce nouveau workflow ; `install.sh` ne copiait pas non plus `.claude/SKILLS/` (bum-dev/minmax/unslop jamais distribués) ; entrée `## [1.0.0]` du CHANGELOG avait une date placeholder jamais remplie
- Bloqué sur : rien
- Prochaine étape : version cible republiée en 2.0.0 (breaking change, pas 1.2.0) dans README.md — commit/push laissés à l'utilisateur, pas faits par Claude
- Fichier à lire en priorité : CONTRIBUTING.md (nouvelle entrée de décision détaillée sur le split PROGRESS.md)
