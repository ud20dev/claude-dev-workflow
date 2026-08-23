# TODO — BACKEND
> Ce que le frontend a déjà besoin de brancher, mais qui n'existe pas encore côté backend.
> Alimenté par Claude au fil des sessions frontend, dès qu'une page/fonctionnalité est construite en mock faute d'endpoint — le développeur backend part d'ici pour savoir quoi construire, avec la forme de données déjà attendue par le frontend.
> Une entrée se retire (ou se réduit à une ligne dans `PROGRESS.md`) une fois l'endpoint construit et branché côté frontend.

---

## Comment utiliser ce fichier
1. Une page/fonctionnalité frontend est construite en mock, faute d'endpoint → ajouter une entrée ici immédiatement (règle absolue, voir `CLAUDE.md`)
2. Début d'une tâche backend → lire ce fichier pour savoir quoi construire en priorité
3. Une fois l'endpoint construit et branché côté frontend → retirer l'entrée (ou la réduire à une ligne dans `backend/PROGRESS.md`)

---

## Template
> Copier ce template pour chaque nouvelle entrée.

```
## [Nom de la page/fonctionnalité]

[Contexte — quelle page/fonctionnalité frontend attend cet endpoint, ce qui existe en mock aujourd'hui, forme de données déjà utilisée côté frontend]

Endpoint(s) attendu(s) :
- `MÉTHODE /api/v1/chemin` (rôle si besoin) — ce qu'il doit faire
```

---

## Entrées

*(vide pour l'instant — la première page/fonctionnalité construite en mock ajoutera sa première entrée ici)*
