# PROGRESS — claude-dev-workflow (le template lui-même)
> Suivi de session à session du développement de ce repo. Jamais copié par `install.sh`, jamais confondu avec `docs/PROGRESS.md` (fichier généré appartenant au template distribué).
> La plus récente en haut.

---

## Sessions

<!-- SENTINEL: nouvelle session ICI, juste en dessous de cette ligne — jamais en bas du fichier -->

### Session 001 — 23/08/2026
- Fait : `docs/PROGRESS.md` scindé en `docs/frontend/PROGRESS.md` + `docs/backend/PROGRESS.md` (conflits git entre dev frontend/backend sur le fichier de suivi partagé) ; `docs/PROGRESS.md` devient un fichier généré, reconstruit par `.claude/scripts/merge-progress.sh` ; `.github/workflows/merge-progress.yml` déclenche la fusion automatiquement à chaque push sur `main` ; migration 1.x → 2.x documentée dans `.claude/scripts/changelog.sh` (archive de l'ancien PROGRESS.md, jamais de split automatique de l'historique)
- Corrigé : procédure de mise à jour du template (`docs/CLAUDE.md` > "Mise à jour du template") ne comparait que `docs/CLAUDE.md` — étendue à `.claude/hooks/`, `.claude/scripts/`, `.claude/SKILLS/`, `.claude/settings.json` et `.github/workflows/`, sinon un projet existant qui met à jour n'aurait jamais reçu automatiquement `session-start.sh`, les skills, ou ce nouveau workflow ; `install.sh` ne copiait pas non plus `.claude/SKILLS/` (bum-dev/minmax/unslop jamais distribués) ; entrée `## [1.0.0]` du CHANGELOG avait une date placeholder jamais remplie
- Bloqué sur : rien
- Prochaine étape : version cible republiée en 2.0.0 (breaking change, pas 1.2.0) dans README.md — commit/push laissés à l'utilisateur, pas faits par Claude
- Fichier à lire en priorité : CONTRIBUTING.md (nouvelle entrée de décision détaillée sur le split PROGRESS.md)
