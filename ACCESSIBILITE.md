# Accessibilité et adoption utilisateur — HealthAI Coach

**Projet** : MSPR TPRE502  
**Application** : `healthai_coach_mobile`  
**Date** : Avril 2026

---

## Table des matières

1. [Positionnement et public cible](#1-positionnement-et-public-cible)
2. [Choix structurels pour l'accessibilité](#2-choix-structurels-pour-laccessibilité)
3. [Accessibilité visuelle](#3-accessibilité-visuelle)
4. [Accessibilité motrice](#4-accessibilité-motrice)
5. [Accessibilité cognitive](#5-accessibilité-cognitive)
6. [Accessibilité des features spécifiques](#6-accessibilité-des-features-spécifiques)
7. [Accompagnement à l'adoption](#7-accompagnement-à-ladoption)
8. [Limites identifiées et axes d'amélioration](#8-limites-identifiées-et-axes-damélioration)

---

## 1. Positionnement et public cible

HealthAI Coach s'adresse à un public large : personnes souhaitant suivre leur alimentation, leurs séances sportives et leur santé en général. Ce public inclut des utilisateurs sans expertise numérique particulière, des personnes en situation de handicap visuel partiel, et des utilisateurs en mobilité (lors d'une séance de sport, les mains chargées, etc.).

L'accessibilité n'est pas une option dans ce contexte : une application de santé doit être utilisable par le plus grand nombre, notamment parce que les personnes les plus susceptibles d'en avoir besoin (personnes âgées, personnes en réhabilitation, personnes avec restrictions alimentaires médicales) sont souvent celles qui ont des contraintes d'accessibilité.

---

## 2. Choix structurels pour l'accessibilité

### 2.1 Material Design 3 comme socle

**Choix** : l'application utilise `useMaterial3: true` dans son thème Flutter.

**Pourquoi** : Material 3 est le système de design de Google qui intègre nativement les recommandations WCAG (Web Content Accessibility Guidelines). En adoptant M3, l'application bénéficie automatiquement de :
- Rôles sémantiques sur tous les composants natifs (`ElevatedButton`, `Slider`, `Chip`, `DataTable`)
- Gestion correcte du focus clavier
- Tailles de cibles tactiles respectant les recommandations (minimum 48×48 dp selon Material)
- Retours haptiques sur les interactions (selon la plateforme)
- Support natif des lecteurs d'écran (TalkBack Android, VoiceOver iOS)

Les composants Material sont reconnus par les technologies d'assistance : un `ElevatedButton` est annoncé comme "bouton" par TalkBack sans configuration supplémentaire.

### 2.2 Thème centralisé — aucune couleur hardcodée dans les widgets

**Choix** : toutes les couleurs passent par `AppColors` (`lib/app/theme.dart`). Aucun widget n'utilise une couleur RGB directe pour les éléments fonctionnels.

**Pourquoi** : en centralisant les couleurs dans un design token, l'ajout d'un thème sombre ou d'un mode haute-contrast ne nécessite que la modification de `AppColors`, sans toucher à aucun widget. C'est la fondation technique qui rend l'adaptation future possible.

### 2.3 Séparation UI / logique métier

**Choix** : architecture Clean Architecture + Riverpod.

**Pourquoi pour l'accessibilité** : l'état de l'application (loading, error, data) est géré dans les providers et non dans les widgets. Cela signifie que les états sont représentables de multiples façons sans dupliquer la logique. Par exemple, un état `AsyncLoading` peut déclencher à la fois un `CircularProgressIndicator` visuel et une annonce TalkBack "Chargement en cours" sans modifier le provider.

---

## 3. Accessibilité visuelle

### 3.1 Contrastes

La palette de couleurs a été choisie pour garantir des ratios de contraste suffisants sur les éléments fonctionnels :

| Combinaison | Ratio estimé | Standard WCAG AA (texte normal) |
|---|---|---|
| `textPrimary` (#444441) sur `background` (#F1EFE8) | ~8:1 | ✅ Conforme (≥ 4.5:1) |
| `textPrimary` (#444441) sur `surface` (#FFFFFF) | ~9:1 | ✅ Conforme |
| `textSecondary` (#888780) sur `surface` (#FFFFFF) | ~4.5:1 | ✅ Limite conforme |
| `textTertiary` (#B4B2A9) sur `surface` (#FFFFFF) | ~2.5:1 | ⚠️ Non conforme pour texte <18px |
| `primary` (#1D9E75) sur `surface` (#FFFFFF) | ~4.6:1 | ✅ Conforme |
| `textOnPrimary` (#FFFFFF) sur `primary` (#1D9E75) | ~4.6:1 | ✅ Conforme (boutons) |

**Note sur `textTertiary`** : cette couleur est utilisée uniquement pour des informations non critiques (métadonnées, compteurs secondaires). Elle ne porte jamais d'information essentielle à la compréhension de l'écran.

### 3.2 Information jamais transmise par la couleur seule

**Choix** : chaque état coloré est doublé d'un texte ou d'une icône.

Exemples concrets dans l'application :

- **RPE (effort post-séance)** : la couleur du score change (vert → orange → rouge selon l'intensité) mais le label textuel est toujours affiché (`'Très facile'`, `'Modéré'`, `'Très difficile'`). Un utilisateur daltonien comprend l'intensité via le texte.

- **Analyse IA nutrition** : le panneau `_AiAnalysisPanel` utilise vert/rouge mais aussi une icône (`Icons.check_circle` / `Icons.warning_amber_rounded`) ET un label (`'Repas sûr'` / `'Attention requise'`). Trois canaux d'information redondants.

- **Barre de navigation** : l'onglet actif est indiqué par la couleur ET par une icône pleine (vs outline pour les inactifs).

- **Erreurs de connexion** : dans `LoginScreen`, les messages d'erreur sont affichés en texte (`_errorMessage`), pas seulement avec une bordure rouge.

### 3.3 Tailles de texte

Hiérarchie typographique respectant les seuils de lisibilité :

| Niveau | Taille | Usage | WCAG |
|---|---|---|---|
| Titre principal | 22px | AppBar, titres d'écrans | ✅ |
| Titre secondaire | 15–16px | Noms de recettes, sections | ✅ |
| Corps | 13–14px | Contenus, labels | ✅ |
| Métadonnées | 11–12px | Ingrédients, temps, prix | ⚠️ Petit |
| Labels uppercase | 10px | Sections (`MES PRÉFÉRENCES`) | ⚠️ Petit mais non fonctionnel |

Les tailles en 10–11px sont utilisées uniquement pour des informations contextuelles non critiques. Toute information nécessaire à une action (boutons, résultats d'analyse, macros) est en 13px minimum.

---

## 4. Accessibilité motrice

### 4.1 Tailles des zones tactiles

**Choix** : `ElevatedButton` configuré avec `minimumSize: const Size(double.infinity, 44)`.

44px est le minimum recommandé par les guidelines Apple Human Interface. Google Material recommande 48dp. Tous les boutons principaux de l'application respectent ce seuil.

Les `IconButton` natifs Flutter ont une zone tactile de 48×48dp par défaut (padding inclus), même quand l'icône visible est plus petite.

### 4.2 Actions alternatives pour la capture photo

**Choix** : deux méthodes de capture sont toujours proposées côte à côte dans `NutritionHubScreen`.

```
[ Photo — caméra live ]   [ Galerie — image existante ]
```

**Pourquoi** : un utilisateur avec un tremblement de la main ou une faible mobilité des doigts peut avoir du mal à déclencher la caméra au bon moment. La galerie lui permet de prendre une photo à son rythme, ou d'utiliser une photo existante. Ce n'est pas une concession, c'est une vraie alternative fonctionnelle.

### 4.3 Slider RPE accessible

Le `RpeSliderWidget` utilise le `Slider` Material natif. Flutter garantit sur ce composant :
- Navigation au clavier (flèches gauche/droite)
- Annonce de la valeur par TalkBack/VoiceOver
- Taille de cible tactile conforme

### 4.4 Validation des modifications de macros

La fonctionnalité de correction des macros dans `MacroTableWidget` propose un bouton `Valider` explicite. L'utilisateur ne valide pas par perte de focus — il confirme délibérément. Cela évite les modifications accidentelles lors d'une navigation au clavier ou d'un scroll.

---

## 5. Accessibilité cognitive

### 5.1 Principe de moindre surprise

La navigation suit un pattern standard de l'écosystème mobile : `BottomNavigationBar` à 4 onglets avec un bouton central proéminent pour l'action principale (prise de photo). Ce pattern est immédiatement reconnaissable par tout utilisateur d'application mobile.

### 5.2 États de chargement toujours explicites

Chaque action réseau affiche un retour visuel immédiat :

| Action | Retour visuel | Retour textuel |
|---|---|---|
| Connexion | `CircularProgressIndicator` dans le bouton | Bouton désactivé |
| Upload nutrition | Spinner + écran résultat | "Analyse en cours…" |
| Génération menu | Spinner dans bouton | "Génération…" |
| Séance coach | Chronomètre animé | Décompte numérique |

L'utilisateur sait toujours que quelque chose se passe. Il n'y a aucune action qui "disparaît" sans feedback.

### 5.3 Correction des erreurs IA autorisée

**Choix fort pour l'accessibilité cognitive** : la reconnaissance nutritionnelle n'est pas imposée comme vérité absolue. Le tableau des macros dispose d'un mode édition (`Corriger`) permettant à l'utilisateur de corriger les valeurs.

Cela répond à un besoin réel : si l'IA se trompe sur la composition d'un repas, l'utilisateur (souvent quelqu'un avec un suivi médical précis de son alimentation) peut remettre les bonnes valeurs sans quitter l'application.

### 5.4 Messages d'erreur explicites et actionnables

Les erreurs ne sont pas des codes techniques mais des phrases compréhensibles. Le widget `_ErrorCard` (utilisé dans `MealPlanScreen`) affiche toujours un bouton `Réessayer`. L'utilisateur sait quoi faire ensuite.

### 5.5 Libellés en français

L'intégralité de l'interface est en français, incluant les labels techniques (macros, RPE, allergènes). Les termes potentiellement complexes sont contextualisés :
- `RPE` est accompagné de son label (`'Modéré'`, `'Difficile'`)
- Les allergènes sont listés en nom commun (`gluten`, `dairy`, `nuts`) sans code
- Les objectifs nutritionnels utilisent le vocabulaire courant (`Perte de poids`, `Prise de muscle`, `Maintien`)

---

## 6. Accessibilité des features spécifiques

### 6.1 Feature Nutrition — capture photo

- **Double entrée** : caméra live + galerie (voir section 4.2)
- **Compression automatique** : `ImageUtils.compress()` réduit l'image avant upload. L'utilisateur sur une connexion lente (3G, zone rurale) n'attend pas 30 secondes pour voir son résultat
- **Timeout réseau** : `receiveTimeout: 30s` dans Dio — l'application ne se fige pas indéfiniment si le réseau est mauvais
- **Analyse IA non-bloquante** : si le service d'analyse échoue, les macros de base sont quand même affichées. L'utilisateur avec une connexion instable n'est pas pénalisé

### 6.2 Feature Menu IA

- **Slider calorique** avec pas de 100 kcal (pas de valeur précise à saisir au clavier)
- **Allergies en FilterChips** : sélection par tap, pas de saisie texte libre — évite les erreurs de frappe pour des informations médicalement importantes
- **Prix par personne affiché** : information d'accessibilité économique — permet à l'utilisateur de savoir si la recette est dans son budget
- **Ingrédients en chips** : liste visuelle scannée rapidement, pas un bloc de texte

### 6.3 Feature Coach

- **Label textuel RPE** : l'effort est exprimé en mots, pas seulement en chiffre
- **Bouton "Passer"** : permet de valider une séance sans remplir le feedback — pas de contrainte obligatoire sur un utilisateur pressé ou fatigué
- **Timer visible en grand** : pendant une séance, le chronomètre est l'information la plus importante — elle est affiché en grande taille, lisible sans lunettes à distance raisonnable

---

## 7. Accompagnement à l'adoption

### 7.1 Onboarding progressif par le design

L'application ne présente pas d'écran de tutoriel forcé au premier lancement. Le choix est celui d'un **onboarding implicite** :

1. **Écran de connexion épuré** : logo, deux champs, un bouton. Aucune distraction. L'utilisateur comprend immédiatement ce qu'il doit faire.

2. **Onglet Nutrition comme écran d'accueil** : la feature la plus simple (analyser un repas) est celle qui apparaît en premier. Le bouton `+` central dans la nav bar est visuellement distinct — il attire l'œil et invite à l'action sans explication.

3. **Résultats immédiats** : l'utilisateur prend une photo et voit des macros en quelques secondes. La valeur de l'application est perceptible dès la première utilisation, avant même de comprendre toutes les features.

4. **Découverte par les onglets** : les 4 onglets (`Nutrition`, `+`, `Coach`, `Menu IA`) permettent une découverte séquentielle. L'utilisateur explore à son rythme.

### 7.2 Réduction de la friction à l'inscription

- Le formulaire de connexion ne demande que `email` et `mot de passe` — le minimum vital
- Le mot de passe est masqué par défaut avec possibilité de le révéler (icône œil) — évite les erreurs de saisie sans compromettre la sécurité
- Les erreurs de connexion sont affichées inline, dans le même écran, sans redirection

### 7.3 Confiance par la transparence

**L'application ne dissimule pas ses limitations.**

- Si l'analyse IA échoue, les macros brutes sont quand même affichées avec la possibilité de les corriger
- Le panneau IA nutrition n'apparaît que si l'analyse a réussi — pas de résultat inventé
- Les ingrédients d'une recette sont affichés en entier (avec compteur si > 8) — l'utilisateur peut vérifier ce qu'il mange

Cette transparence est cruciale dans une application de santé : un utilisateur qui découvre que l'app lui a menti une fois ne lui fera plus confiance.

### 7.4 Correction et contrôle utilisateur

La possibilité de **corriger les macros** détectées par l'IA (`MacroTableWidget`, mode édition) répond à un principe fondamental d'adoption : l'utilisateur doit avoir le sentiment de contrôler l'application, pas d'en être contrôlé.

En santé particulièrement, les personnes suivant un régime médical strict (diabète, insuffisance rénale, troubles alimentaires) ne peuvent pas se permettre des valeurs approximatives. Leur permettre de corriger renforce la confiance et l'utilisation régulière.

### 7.5 Feedback de fin de séance (RPE)

Le système RPE (Rate of Perceived Exertion) est présenté simplement : un slider de 1 à 10 avec des labels (`Facile`, `Difficile`). Ce mécanisme sert deux objectifs d'adoption :

1. **Engagement** : remplir un court feedback crée un rituel post-séance qui renforce l'habitude d'utilisation
2. **Personnalisation future** : ces données permettront au Coach IA d'adapter les séances futures — l'utilisateur comprend que son feedback a une valeur concrète

---

## 8. Limites identifiées et axes d'amélioration

### Limites actuelles

| Limitation | Impact | Priorité d'amélioration |
|---|---|---|
| Pas de thème sombre | Utilisation difficile en basse luminosité ou pour les personnes photosensibles | Haute |
| `Semantics` non ajoutés manuellement | Les widgets personnalisés (cards, progress indicators) ne sont pas décrits aux lecteurs d'écran | Haute |
| Taille de police fixe (pas de respect de `textScaleFactor`) | L'agrandissement système du téléphone n'est pas honoré sur certains composants | Moyenne |
| `textTertiary` (#B4B2A9) sous le seuil WCAG AA | Ratio < 3:1 pour les petits textes de métadonnées | Basse (non critique) |
| Pas d'écran d'onboarding explicite | Les utilisateurs non familiers des apps de santé peuvent ne pas comprendre la valeur de la photo IA | Moyenne |
| Pas de mode hors ligne pour la nutrition | Utilisateurs sans connexion ne peuvent pas logger un repas | Moyenne |

### Améliorations prioritaires recommandées

**1. Ajout de `Semantics` sur les composants clés**

```dart
// Exemple — barre de progression calorique
Semantics(
  label: '1840 kilocalories consommées sur 2200, soit 84 pourcent',
  child: CircularProgressIndicator(value: 1840 / 2200),
)
```

**2. Support du thème sombre**

La palette `AppColors` étant centralisée, l'ajout se résume à créer `AppColors.dark` et brancher `MediaQuery.platformBrightnessOf(context)` dans `app.dart`.

**3. Respect de `textScaleFactor`**

Remplacer les `fontSize` fixes par des valeurs qui s'adaptent :

```dart
// Avant
style: TextStyle(fontSize: 14)

// Après
style: TextStyle(fontSize: 14 * MediaQuery.textScaleFactorOf(context).clamp(1.0, 1.3))
```

**4. Écran d'onboarding au premier lancement**

3 slides maximum expliquant :
- "Prenez en photo vos repas pour connaître leurs macros"
- "Générez un menu personnalisé selon vos objectifs"
- "Suivez vos séances sport et votre progression"

Déclenchable via `shared_preferences` (flag `has_seen_onboarding`).
