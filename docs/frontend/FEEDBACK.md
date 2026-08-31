# FEEDBACK — FRONTEND
> Réflexes IA à corriger côté interface — patterns de comportement observés et corrigés.
> Différent de ERRORS.md (même dossier) : pas un bug ponctuel dans le code, un réflexe à éviter chez l'IA elle-même.
> Lire avant toute tâche frontend où un réflexe connu risque de se reproduire.
> Ne jamais supprimer une entrée existante.
> La plus récente en haut — sous les entrées `Date : —` s'il y en a, voir note plus bas.
> Format d'ajout : "Ajoute dans frontend/FEEDBACK.md — [pattern]"

---

## Template
> Copier ce template pour chaque nouveau réflexe identifié.

```
### [Nom court du pattern]
- Date : JJ/MM/AAAA
- Contexte : [ce qui a été demandé]
- Réflexe observé : [ce que l'IA a fait au lieu de la bonne approche]
- Pourquoi c'est un problème : [conséquence concrète]
- Correction attendue : [ce qu'il faut faire à la place]
```

---

## Patterns identifiés
> Les entrées avec `Date : —` sont des connaissances génériques (vraies sur tout projet utilisant cette stack), pas des observations d'un projet précis — elles restent groupées en bas. Une nouvelle entrée issue d'une vraie session porte une date réelle et s'ajoute au-dessus d'elles, la plus récente en tête.

<!-- SENTINEL: nouveau pattern daté ICI, juste en dessous de cette ligne — au-dessus des entrées `Date : —`, jamais en bas du fichier -->

### Fix CSS large validé sans revérifier les états voisins
- Date : 08/07/2026
- Contexte : application d'un correctif CSS avec `!important` sur un sélecteur large pour régler un bug visuel précis (ex. fond transparent sur mobile causé par oklch — voir ERRORS.md)
- Réflexe observé : le correctif est considéré terminé dès que le bug ciblé disparaît, sans revérifier visuellement les états et pseudo-éléments voisins qui héritent de la même propriété (`::placeholder`, `:disabled`, `::selection`, `:focus-visible`, `:hover`) — le nouveau bug introduit reste invisible parce que personne ne regarde le rendu après coup
- Pourquoi c'est un problème : un override `!important` a toujours un rayon d'effet plus large que le bug visé. Sans vérification visuelle après le fix, un nouveau défaut remplace l'ancien sans être détecté — observé concrètement quand le fix oklch de STYLE.md a rendu le `::placeholder` indiscernable d'une vraie saisie. C'est le pattern qui revient le plus souvent, tous projets confondus
- Correction attendue : après tout override CSS `!important` ou tout sélecteur large, lister les pseudo-classes/pseudo-éléments qui héritent de la propriété modifiée et les vérifier un par un dans le navigateur (ou capture d'écran) avant de considérer le fix terminé — ne jamais valider un correctif CSS seulement parce que le symptôme initial a disparu

### Camouflage CSS au lieu de corriger la cause
- Date : —
- Contexte : correction d'un élément d'interface cassé visuellement (ex. bordure double, cercle, bouton qui ne se comporte pas comme prévu)
- Réflexe observé : au lieu de retirer la classe DaisyUI ou l'élément non-sémantique responsable, l'IA empile du CSS par-dessus pour masquer le symptôme (`rounded-xl`, `focus:outline-none`, overrides en cascade sur une classe qui gère déjà cette propriété)
- Pourquoi c'est un problème : le conflit sous-jacent reste présent et ressurgit à la prochaine modification ; le code accumule des overrides inutiles ; l'élément a l'air correct mais ne se comporte pas comme un vrai élément HTML (ex. `<div onClick>` au lieu de `<button>`)
- Correction attendue : voir la règle "No Camouflage" dans STYLE.md — choisir DaisyUI ou Tailwind pur, jamais les deux en conflit ; toujours utiliser l'élément HTML sémantique réel (`<button>`, `<label>`, `<a>`)

### Dérive de style entre pages au lieu de réutiliser l'existant
- Date : —
- Contexte : création d'un bouton, d'une carte ou d'un input sur une nouvelle page, alors qu'un élément du même type existe déjà ailleurs dans le projet
- Réflexe observé : l'IA invente une valeur "proche" (radius légèrement différent, bordure différente, padding différent) au lieu de relire STYLE.md > Composants UI / Boutons et de réutiliser exactement les mêmes valeurs — ou pire, sans relire STYLE.md du tout
- Pourquoi c'est un problème : chaque page introduit une micro-variation invisible au moment où elle est codée, mais l'accumulation rend le produit incohérent visuellement page après page. Plus long à corriger après coup (il faut comparer chaque page une par une) qu'à prévenir en amont
- Correction attendue : avant de styliser un élément qui a un équivalent probable ailleurs (bouton, carte, input, badge), relire STYLE.md > Composants UI et Boutons — réutiliser tel quel. Si aucun type existant ne convient, l'ajouter au tableau STYLE.md d'abord, avec sa justification, puis l'implémenter — jamais de valeur codée en dur qui n'existe nulle part dans STYLE.md

### Positionnement improvisé au lieu de suivre une convention de mise en page
- Date : —
- Contexte : positionner les blocs d'une nouvelle page (espacement entre sections, structure d'un formulaire, alignement du contenu) — pas une question de couleur ou de bouton, mais d'agencement spatial
- Réflexe observé : l'IA sait généralement produire une page "correcte" isolément (le rendu passe une validation visuelle rapide), mais sans référence à une convention documentée, chaque page adopte son propre agencement — un formulaire avec le label à côté sur une page et au-dessus sur une autre, un espacement entre sections qui varie sans raison
- Pourquoi c'est un problème : contrairement à une couleur ou un radius faux qui saute aux yeux immédiatement, un agencement "à peu près bon" passe souvent la relecture rapide — l'incohérence ne devient visible qu'en comparant plusieurs pages côte à côte, ce qui n'arrive presque jamais pendant le développement
- Correction attendue : avant de positionner un nouveau bloc, relire STYLE.md > "Mise en page" (grille, formulaires) et vérifier dans PAGES.md si une page similaire existe déjà — reproduire sa structure plutôt que d'en inventer une nouvelle. Si le cas ne rentre dans aucune convention existante, l'ajouter à STYLE.md > Mise en page d'abord

### Interface qui respecte STYLE.md mais "sent l'IA"
- Date : —
- Contexte : une interface techniquement conforme à STYLE.md (bons radius, bonnes couleurs, bons espacements) est livrée comme terminée
- Réflexe observé : l'IA considère la tâche finie dès que les règles mécaniques de STYLE.md sont respectées, sans évaluer le niveau de finition global — résultat reconnaissable au premier coup d'œil comme généré automatiquement (dégradé violet-bleu par défaut, ombres lourdes uniformes, aucune transition sur les interactions, emoji en guise d'icônes)
- Pourquoi c'est un problème : respecter des règles mécaniques ne garantit pas un jugement esthétique — les deux sont nécessaires. Un produit qui "sent l'IA" perd en crédibilité même si chaque valeur individuelle est correcte
- Correction attendue : avant de livrer une interface, passer par la checklist de `frontend/UI-QUALITY.md` (symptômes du style générique) — ne jamais considérer une interface terminée uniquement parce qu'elle respecte STYLE.md mécaniquement

### Hauteur de section en viewport (svh/vh) combinée à un contenu de taille fixe
- Date : —
- Contexte : styliser une section en hauteur plein écran (`min-h-svh`, `100vh`, `min-h-screen`) qui contient des éléments à l'intérieur
- Réflexe observé : la section est mise en `svh`/`vh`/`min-h-screen` sans vérifier si son contenu grandit avec elle (`flex-1`, `h-full` sur des enfants qui se répartissent l'espace) ou s'il a une taille intrinsèquement fixe (carte, image, bloc de texte court en `h-[Npx]`/`min-h-[Npx]`) — sur petit/moyen écran l'écart est invisible, les deux tailles restent proches
- Pourquoi c'est un problème : sur un grand écran (moniteur externe, PC portable large), la section s'étire pour remplir tout l'espace disponible alors que le contenu à hauteur fixe reste bloqué à sa taille — résultat : une impression de contenu minuscule perdu dans un grand vide, invisible tant que personne ne teste sur un grand écran
- Correction attendue : avant d'utiliser `svh`/`vh`/`min-h-screen` sur une section, vérifier si son contenu est à taille fixe ou s'il grandit avec elle. Si fixe, plafonner la hauteur avec `min()` pour qu'elle ne dépasse jamais la taille réelle du contenu (`min-h-[min(85svh,850px)]` plutôt que `min-h-[85svh]` seul) ; si le contenu grandit avec la section (`flex-1`), pas de plafond nécessaire. Détection rapide : chercher les sections en `svh`/`vh`/`min-h-screen` dont des enfants sont en `h-[Npx]`/`min-h-[Npx]` fixe sans `flex-1`
