# Documentation technique — HealthAI Coach (Flutter)

**Projet** : MSPR TPRE502  
**Application** : `healthai_coach_mobile`  
**Framework** : Flutter 3.x / Dart SDK ≥ 3.0  
**Version** : 1.0.0+1

---

## Table des matières

1. [Architecture générale](#1-architecture-générale)
2. [Stack technique](#2-stack-technique)
3. [Structure des fichiers](#3-structure-des-fichiers)
4. [Couche Core](#4-couche-core)
5. [Feature : Authentification](#5-feature--authentification)
6. [Feature : Nutrition](#6-feature--nutrition)
7. [Feature : Menu IA (Spoonacular)](#7-feature--menu-ia-spoonacular)
8. [Feature : Coach](#8-feature--coach)
9. [Navigation](#9-navigation)
10. [Thème et design system](#10-thème-et-design-system)
11. [Communication avec le backend](#11-communication-avec-le-backend)
12. [État des connexions backend](#12-état-des-connexions-backend)
13. [Ce qui reste à faire](#13-ce-qui-reste-à-faire)

---

## 1. Architecture générale

L'application suit une **Clean Architecture** organisée par feature. Chaque feature est découpée en trois couches indépendantes :

```
feature/
├── domain/          # Entités métier + interfaces de repository (pur Dart, 0 dépendance)
├── data/            # Implémentations concrètes (modèles JSON, appels API)
└── presentation/    # UI, providers Riverpod, widgets
```

**Pourquoi ce choix ?**  
Cette séparation garantit que la logique métier ne dépend jamais du framework UI ni du transport réseau. Si l'on change Dio pour un autre client HTTP, ou Riverpod pour un autre state manager, seule la couche `data` ou `presentation` est impactée. C'est aussi ce qui permet de brancher facilement un mock ou une vraie implémentation sans toucher à l'UI.

---

## 2. Stack technique

| Domaine | Librairie | Version | Justification |
|---|---|---|---|
| State management | `flutter_riverpod` | ^2.5.0 | `AsyncNotifier` couvre nativement loading/error/data sans boilerplate |
| Navigation | `go_router` | ^14.0.0 | Navigation déclarative, deep links, type-safe routes |
| HTTP client | `dio` | ^5.4.0 | Intercepteurs pour auth token, gestion d'erreurs centralisée |
| Auth locale | `shared_preferences` | ^2.3.0 | Persistance simple du JWT et userId entre sessions |
| Caméra | `camera` + `image_picker` | ^0.11 / ^1.1 | `camera` pour le viewfinder live, `image_picker` pour la galerie |
| Compression image | `flutter_image_compress` | ^2.3.0 | Réduit le poids des photos avant upload (réseau + performance) |
| Images réseau | `cached_network_image` | ^3.3.0 | Cache automatique des photos de recettes Spoonacular |
| Stockage offline | `isar` | ^3.1.0 | Base de données locale NoSQL rapide pour le plan d'entraînement hors ligne |
| Vidéo | `video_player` | ^2.8.0 | Démos vidéo des exercices (feature Coach) |

---

## 3. Structure des fichiers

```
lib/
├── app/
│   ├── app.dart              # Point d'entrée app, router GoRouter
│   └── theme.dart            # Design system (couleurs, thème Material3)
│
├── core/
│   ├── auth/
│   │   └── token_storage.dart        # Persistance JWT + userId (SharedPreferences)
│   ├── constants/
│   │   └── api_constants.dart        # Toutes les URLs d'endpoints
│   ├── network/
│   │   └── dio_client.dart           # Instance Dio singleton + intercepteur auth
│   ├── errors/
│   │   └── failures.dart             # Classes d'erreurs métier
│   └── utils/
│       └── image_utils.dart          # Compression et nettoyage des images temp
│
├── features/
│   ├── auth/
│   │   └── presentation/screens/login_screen.dart
│   ├── nutrition/
│   │   ├── domain/
│   │   │   ├── entities/meal_analysis.dart
│   │   │   └── repositories/nutrition_repository.dart
│   │   ├── data/
│   │   │   ├── models/meal_analysis_model.dart
│   │   │   └── repositories/nutrition_repository_impl.dart
│   │   └── presentation/
│   │       ├── providers/nutrition_provider.dart
│   │       ├── screens/camera_screen.dart
│   │       ├── screens/meal_result_screen.dart
│   │       └── widgets/macro_table_widget.dart
│   ├── meal_plan/
│   │   ├── domain/
│   │   │   ├── entities/meal_plan.dart
│   │   │   └── repositories/meal_plan_repository.dart
│   │   ├── data/
│   │   │   ├── models/meal_plan_model.dart
│   │   │   └── repositories/meal_plan_repository_impl.dart
│   │   └── presentation/
│   │       ├── providers/meal_plan_provider.dart
│   │       └── screens/meal_plan_screen.dart
│   ├── coach/
│   │   ├── domain/entities/     # SessionState, SessionFeedback
│   │   ├── data/repositories/   # CoachRepositoryMock (temporaire)
│   │   └── presentation/
│   │       ├── providers/coach_provider.dart
│   │       └── screens/         # CoachHubScreen, SessionScreen, RpeScreen
│   └── offline/
│       ├── domain/entities/     # Exercise, DayPlan, WeekPlan
│       ├── data/                # Modèles Isar + OfflineRepositoryMock
│       └── presentation/        # WeekPlanScreen, providers
│
└── shared/
    └── screens/
        ├── home_screen.dart      # Shell avec BottomNavigationBar (4 tabs)
        └── dev_home_screen.dart  # Écran de debug (non exposé en prod)
```

---

## 4. Couche Core

### 4.1 `ApiConstants`

Fichier : `lib/core/constants/api_constants.dart`

Centralise toutes les URLs. La base URL est injectable via `--dart-define` pour distinguer les environnements :

```dart
static const String baseUrl = String.fromEnvironment(
  'BFF_BASE_URL',
  defaultValue: 'http://localhost:3002',
);
```

**Choix** : utiliser `String.fromEnvironment` plutôt qu'un fichier `.env` tiers permet de compiler la valeur dans le binaire Flutter sans dépendance supplémentaire.

| Constante | Endpoint | Usage |
|---|---|---|
| `signIn` | `POST /api/auth/sign-in/email` | Connexion Better Auth |
| `signUp` | `POST /api/auth/sign-up/email` | Inscription |
| `uploadMeal` | `POST /api/nutrition/upload` | Upload photo repas |
| `analyzeMeal` | `POST /api/nutrition/analyze` | Analyse IA macros (gRPC engine-go) |
| `generateMenu` | `POST /api/generate-menu` | Menu Spoonacular |
| `weeklyPlan` | `GET /api/coach/plan` | Plan coach (non implémenté BFF) |
| `userProfile` | `GET /api/user/profile` | Profil utilisateur |

### 4.2 `DioClient`

Fichier : `lib/core/network/dio_client.dart`

Instance Dio singleton avec :
- `baseUrl` depuis `ApiConstants`
- `connectTimeout` : 10 secondes
- `receiveTimeout` : 30 secondes
- `LogInterceptor` : log toutes les requêtes/réponses en debug
- `_AuthInterceptor` : injecte le Bearer token sur chaque requête

**Fonctionnement de `_AuthInterceptor`** :
1. Avant chaque requête → lit le token depuis `TokenStorage` → injecte `Authorization: Bearer <token>`
2. Sur erreur 401 → efface le token automatiquement (déconnexion silencieuse)

**Pourquoi un singleton ?**  
Dio maintient un pool de connexions. Instancier Dio à chaque appel recréerait ce pool inutilement. Le singleton garantit une seule instance partagée par toutes les features.

### 4.3 `TokenStorage`

Fichier : `lib/core/auth/token_storage.dart`

Persistance du JWT et du `userId` Better Auth via `SharedPreferences`.

```
Clés stockées :
  auth_token   → JWT Bearer token
  auth_user_id → ID utilisateur (UUID Better Auth)
```

**Pourquoi stocker les deux ?**  
Le `userId` est nécessaire lors de l'upload nutrition (`POST /api/nutrition/upload`) pour associer le repas à l'utilisateur en base MongoDB. Sans lui, on retombait sur un `'user_placeholder'` hardcodé.

---

## 5. Feature : Authentification

### Flux de connexion

```
LoginScreen
  → saisie email + password
  → POST /api/auth/sign-in/email  (Better Auth / backend-hono)
  → réponse : { token: "...", user: { id: "..." } }
  → TokenStorage.save(token, userId: userId)
  → context.go('/home')
```

### Gestion d'erreurs

Les erreurs `DioException` sont catchées et affichées inline dans l'écran (pas de SnackBar) via `_errorMessage`. Le message provient du champ `message` ou `error` de la réponse JSON du BFF.

### Limites actuelles

- L'inscription (`S'inscrire`) et la récupération de mot de passe sont des boutons présents dans l'UI mais sans navigation ni appel API branché.
- L'authentification sociale (Google, Apple) est affichée mais non implémentée.
- Pas de bouton de déconnexion dans l'UI — la déconnexion se produit automatiquement si le serveur retourne 401.

---

## 6. Feature : Nutrition

### 6.1 Flux complet

```
CameraScreen
  ├── Prise de photo (CameraController)
  └── Sélection galerie (ImagePicker)
       ↓
  ImageUtils.compress()          ← compression JPEG avant upload
       ↓
  POST /api/nutrition/upload     ← multipart/form-data { file, userId }
  → réponse : { macros: { calories, protein, carbs, fat } }
       ↓
  MealAnalysisModel.fromUploadJson()
       ↓
  POST /api/nutrition/analyze    ← { ingredients, macros } — NON BLOQUANT
  → réponse : { is_safe, warnings, advice }
       ↓
  model.withAiAnalysis(...)
       ↓
  MealResultScreen               ← affiche MacroTableWidget + _AiAnalysisPanel
```

**Choix clé — appel IA non bloquant** : L'endpoint `/api/nutrition/analyze` passe par gRPC → engine-go qui peut être instable. Si cet appel échoue, les macros brutes de l'upload sont quand même affichées. L'erreur est loggée (`debugPrint`) mais ne fait pas crasher le flux utilisateur.

### 6.2 Entités domaine

**`FoodItem`** : représente un aliment individuel avec ses macros (calories, protéines, glucides, lipides).

**`MealAnalysis`** : agrège une liste de `FoodItem`, les totaux calculés, des suggestions textuelles, et les champs IA optionnels (`isSafe`, `warnings`, `advice`).

### 6.3 `MacroTableWidget`

Widget central de `MealResultScreen`. Il propose deux modes :

- **Lecture** : `DataTable` avec les macros par aliment + ligne Total
- **Édition** (`Corriger`) : chaque cellule devient un `TextFormField` permettant de corriger les valeurs si l'IA s'est trompée. La validation recalcule les totaux et met à jour le provider.

Ce mode édition répond à un besoin concret : les macros retournées par le BFF sont pour l'instant estimées (pas de vraie reconnaissance visuelle), donc l'utilisateur peut les corriger manuellement.

### 6.4 `_AiAnalysisPanel`

Panel conditionnel affiché uniquement si `analysis.isSafe != null` (c'est-à-dire si l'appel à `/api/nutrition/analyze` a réussi). Affiche :
- Badge vert `Repas sûr` ou rouge `Attention requise`
- Liste des avertissements (ex: "Repas calorique > 800 kcal")
- Conseil personnalisé

### 6.5 Limitation connue — reconnaissance visuelle

Actuellement, `POST /api/nutrition/upload` dans le BFF **ignore le contenu de la photo** et retourne des macros hardcodées (550 kcal, 30g prot, etc.). La vraie reconnaissance visuelle sera assurée par le service Python (`python.medev-tech.fr/predict/upload`) une fois son modèle `.pt` déployé sur le serveur. Côté Flutter, **aucune modification ne sera nécessaire** : il suffit que le BFF transmette la photo au service Python et retourne un JSON enrichi avec `detectedFood`.

---

## 7. Feature : Menu IA (Spoonacular)

### 7.1 Objectif

Permettre à l'utilisateur de générer un menu personnalisé (Déjeuner + Dîner) en fonction de ses préférences caloriques, son objectif et ses allergies. C'est la seule feature IA **entièrement fonctionnelle** de l'application.

### 7.2 Flux

```
MealPlanScreen
  → slider calorique (1200–3500 kcal, pas de 100)
  → chips objectif : weight_loss / muscle_gain / maintenance
  → chips allergies : gluten, dairy, nuts, eggs, soy, fish
       ↓
  Bouton "Générer mon menu"
       ↓
  MealPlanNotifier.generate(calories, allergies, goal)
       ↓
  POST /api/generate-menu
  body : { user: { dailyCaloriesTarget, allergies, goal } }
       ↓
  réponse : { lunch: { ...recipe }, dinner: { ...recipe }, totalCalories }
       ↓
  _MealPlanResult → 2x _RecipeCard
```

### 7.3 Entités domaine

**`MealPlanRecipe`** : recette complète avec id, name, ingredients, calories, protein, carbs, fat, sugar, sodium, pricePerServing, preparationTime, imageUrl, diets, dishTypes, score.

**`GeneratedMealPlan`** : conteneur de `lunch` + `dinner` + `totalCalories`.

### 7.4 Affichage

Chaque `_RecipeCard` affiche :
- Photo de la recette via `CachedNetworkImage` (avec placeholder et fallback icône)
- Badge de label (DÉJEUNER / DÎNER) en overlay sur la photo
- Badge score étoile (si score > 0)
- Chips macros : kcal, protéines, glucides (couleurs codées)
- Temps de préparation + prix par personne
- Tags régimes alimentaires (vegan, gluten-free, etc.)
- Ingrédients (8 premiers + compteur du reste)

### 7.5 `MealPlanNotifier`

`AsyncNotifier<GeneratedMealPlan?>` — état initial `null`. Lors de `generate()`, l'état passe à `AsyncLoading` puis `AsyncData` ou `AsyncError`. Le bouton de génération est désactivé pendant le chargement.

---

## 8. Feature : Coach

### 8.1 État actuel

La feature Coach est **partiellement implémentée**. L'UI est complète et fonctionnelle avec des données mockées. La connexion au backend est bloquée pour des raisons indépendantes du Flutter (voir section 12).

### 8.2 Ce qui fonctionne

- `CoachHubScreen` : affiche la séance du jour, les stats de la semaine, le planning 7 jours
- `SessionScreen` : chronomètre de séance, navigation entre exercices, phase repos
- `RpeScreen` : saisie du ressenti d'effort post-séance (RPE 1–10)
- `SessionNotifier` : gestion complète du timer, pause, passage à l'exercice suivant

### 8.3 Données actuellement mockées

Le planning hebdomadaire est défini dans `coach_hub_screen.dart` via `_mockWeek` (constante Dart, 3 jours). `CoachRepositoryMock` simule un délai réseau de 800ms pour `sendFeedback`.

### 8.4 Architecture de connexion prévue

```
CoachRepository (interface)
  └── sendFeedback(SessionFeedback) → bool

À compléter :
  └── getWeekPlan(String userId) → WeekPlan   ← méthode manquante
```

---

## 9. Navigation

Fichier : `lib/app/app.dart`

Routeur GoRouter avec 7 routes déclaratives :

| Route | Widget | Paramètre |
|---|---|---|
| `/login` | `LoginScreen` | — |
| `/home` | `HomeScreen` | — |
| `/camera` | `CameraScreen` | — |
| `/meal-result` | `MealResultScreen` | `extra: String` (imagePath) |
| `/week-plan` | `WeekPlanScreen` | — |
| `/session` | `SessionScreen` | `extra: DayPlan` |
| `/rpe` | `RpeScreen` | — |
| `/meal-plan` | `MealPlanScreen` | — |

**`HomeScreen`** est le shell principal. Il contient un `IndexedStack` avec 3 écrans persistants (Nutrition, Coach, Menu IA) et une `BottomNavigationBar` à 4 items :

| Index tap | Action |
|---|---|
| 0 | Affiche `NutritionHubScreen` |
| 1 | `context.push('/camera')` (bouton central +) |
| 2 | Affiche `CoachHubScreen` |
| 3 | Affiche `MealPlanScreen` |

**Pourquoi `IndexedStack` ?**  
Contrairement à `PageView`, `IndexedStack` garde les widgets en mémoire entre les onglets. L'état des providers Riverpod (notamment `mealPlanProvider`) n'est pas réinitialisé quand l'utilisateur change d'onglet.

**Pourquoi GoRouter ?**  
L'utilisation de `context.push('/meal-result', extra: imagePath)` permet de passer des données complexes (chemin d'image, objet `DayPlan`) entre routes sans les sérialiser dans l'URL.

---

## 10. Thème et design system

Fichier : `lib/app/theme.dart`

Design épuré inspiré d'applications wellness (fond beige chaud, vert primaire, accents ambre).

### Palette `AppColors`

| Token | Hex | Usage |
|---|---|---|
| `primary` | `#1D9E75` | Actions principales, icônes actives |
| `primaryDark` | `#0F6E56` | Hover, focus |
| `primaryLight` | `#E1F5EE` | Backgrounds de chips, badges |
| `accent` | `#FAC775` | Indicateurs, streak |
| `background` | `#F1EFE8` | Fond général (beige chaud) |
| `surface` | `#FFFFFF` | Cards, bottom nav |
| `surfaceAlt` | `#E8E7E0` | Champs de saisie, placeholders |
| `textPrimary` | `#444441` | Texte principal |
| `textSecondary` | `#888780` | Labels, sous-titres |
| `textTertiary` | `#B4B2A9` | Placeholders, métadonnées |
| `border` | `#D3D1C7` | Bordures de cards |

### Material 3

Le thème utilise `useMaterial3: true`. Les composants sont tous redéfinis globalement (`ElevatedButton`, `OutlinedButton`, `InputDecoration`, `BottomNavigationBar`, `Chip`) pour éviter toute surcharge locale dans les widgets. Cela garantit la cohérence visuelle sur l'ensemble de l'application.

---

## 11. Communication avec le backend

### Architecture globale

```
Flutter App
    │
    │  HTTP/REST (Dio + Bearer JWT)
    ▼
BFF backend-hono (:3002)
    │
    ├── Better Auth         → Authentification
    ├── MongoDB             → Historique repas
    ├── Spoonacular API     → Génération menu IA
    ├── gRPC → engine-go    → Analyse nutritionnelle, workout
    └── HTTP → python.medev-tech.fr → Reconnaissance visuelle (à venir)
```

### Authentification

Better Auth retourne `{ token, user: { id } }` à la connexion. Le token est un JWT persisté en local. Il est injecté automatiquement sur toutes les requêtes par `_AuthInterceptor`. Sur 401, le token est effacé et l'utilisateur devra se reconnecter.

### Format des requêtes

- **Upload nutrition** : `multipart/form-data` avec `file` (image compressée) et `userId`
- **Toutes les autres** : `application/json`
- **Header commun** : `Authorization: Bearer <token>`

---

## 12. État des connexions backend

| Feature Flutter | Endpoint BFF | Statut | Détail |
|---|---|---|---|
| Connexion | `POST /api/auth/sign-in/email` | **Fonctionnel** | Better Auth opérationnel |
| Upload photo nutrition | `POST /api/nutrition/upload` | **Fonctionnel** | Macros estimées (hardcodées BFF) |
| Analyse IA nutrition | `POST /api/nutrition/analyze` | **Partiel** | gRPC engine-go instable — non bloquant |
| Génération menu | `POST /api/generate-menu` | **Fonctionnel** | Spoonacular, données réelles |
| Reconnaissance visuelle | via `python.medev-tech.fr` | **En attente** | Modèle `.pt` pas encore sur le serveur prod |
| Plan coach | `GET /api/coach/plan` | **Non connecté** | Endpoint inexistant dans BFF |
| Profil utilisateur | `GET /api/user/profile` | **Non connecté** | Endpoint disponible, non branché Flutter |

---

## 13. Ce qui reste à faire

### Priorité haute

**Reconnaissance visuelle (nutrition)**  
Une fois que le service Python aura son modèle déployé (`models/best.pt` sur le serveur), une seule ligne Flutter est à modifier dans `meal_analysis_model.dart` :

```dart
// Ligne 102 — fromUploadJson()
name: (json['detectedFood'] as String?) ?? 'Repas analysé',
```

**Connexion feature Coach**  
L'endpoint `GET /api/coach/plan` n'existe pas dans le BFF. Il faudra :
1. (backend) Implémenter l'endpoint + seeder la table `exercises` dans PostgreSQL
2. (Flutter) Ajouter `getWeekPlan(String userId)` à `CoachRepository`
3. (Flutter) Créer `CoachRepositoryImpl` appelant le nouvel endpoint
4. (Flutter) Remplacer `_mockWeek` dans `CoachHubScreen` par le provider

### Priorité moyenne

**Écran profil**  
`ProfileScreen` existe mais n'appelle pas `GET /api/user/profile`. À brancher via un provider dédié.

**Déconnexion manuelle**  
`TokenStorage.clear()` est implémentée mais aucun bouton logout n'est exposé dans l'UI. À ajouter dans `ProfileScreen` ou l'AppBar.

**Inscription**  
Le bouton `S'inscrire` est présent sur `LoginScreen` mais ne navigue nulle part. Un `SignUpScreen` appelant `POST /api/auth/sign-up/email` est à créer.

### Priorité basse

**Plan semaine offline (Isar)**  
`OfflineRepositoryImpl` et les modèles Isar (`ExerciseIsar`, `DayPlanIsar`) sont implémentés mais `offline_provider.dart` utilise encore `OfflineRepositoryMock`. La synchronisation depuis le backend vers Isar est à connecter.

**Historique nutrition**  
`GET /api/nutrition/history` est disponible côté BFF mais pas branché Flutter. À afficher dans `NutritionHubScreen`.

**Feedback séance (Coach)**  
`sendFeedback` dans `SessionNotifier` utilise encore `'test-user-001'` hardcodé comme `userId`. À remplacer par `await TokenStorage.getUserId()`.
