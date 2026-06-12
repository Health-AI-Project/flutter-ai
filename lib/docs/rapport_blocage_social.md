# Rapport de blocage — Module Réseau Social
## Date : 2026-05-22

---

## 1. Résumé du constat

L'audit du backend (`backend-hono`, `auth-service`, `engine-go`) révèle qu'**aucun endpoint dédié au module réseau social n'est exposé**. Le service BFF (`hono.medev-tech.fr`) ne dispose d'aucune route permettant la gestion des publications, des likes, des commentaires ou de l'upload de médias sociaux.

En conséquence, le module réseau social Flutter est implémenté en **mode dégradé** avec des données mockées localement, permettant une démonstration complète de l'interface et des interactions sans dépendance au back-end.

---

## 2. Détail par fonctionnalité

### Publications (Posts)

- [ ] `GET /api/posts` — Récupérer le feed
- [ ] `POST /api/posts` — Créer une publication
- [ ] `DELETE /api/posts/:id` — Supprimer une publication
- [ ] `GET /api/posts/:id` — Détail d'une publication

**Statut : absent**

Remarques : La base de données PostgreSQL (schéma Drizzle) ne contient aucune table `posts`. Le schéma actuel couvre uniquement les utilisateurs, sessions, repas et plans.

---

### Médias (upload social)

- [ ] `POST /api/media/upload` — Upload photo/vidéo pour une publication
- [ ] Stockage objet (MinIO ou équivalent)

**Statut : absent**

Remarques : Le BFF dispose d'un endpoint `POST /api/nutrition/upload` pour l'analyse IA de repas, mais il est dédié au service Python d'IA nutritionnelle (`/api/v1/predictions/upload`) et ne peut pas servir d'upload généraliste pour des publications sociales.

---

### Likes

- [ ] `POST /api/posts/:id/like` — Liker une publication
- [ ] `DELETE /api/posts/:id/like` — Retirer son like

**Statut : absent**

---

### Commentaires

- [ ] `GET /api/posts/:id/comments` — Lister les commentaires
- [ ] `POST /api/posts/:id/comments` — Ajouter un commentaire
- [ ] `DELETE /api/posts/:id/comments/:commentId` — Supprimer un commentaire

**Statut : absent**

---

### Profil utilisateur (édition)

- [x] `GET /api/me` — Récupérer le profil (présent) ✅
- [ ] `PATCH /api/me` — Modifier le nom d'affichage *(endpoint PATCH /api/me/health existe mais ne couvre pas le display name)*
- [ ] `POST /api/me/avatar` — Uploader une photo de profil

**Statut : partiel**

Remarques : Le nom d'affichage et l'avatar sont gérés localement via `SharedPreferences` dans l'application Flutter. Une synchronisation serveur sera possible une fois l'endpoint disponible.

---

## 3. Impact sur le développement Flutter

### Ce qui fonctionne malgré tout

- **Authentification** : login, signup et token JWT via `POST /api/auth/sign-in/email` et `POST /api/auth/sign-up/email` — pleinement fonctionnels
- **Profil** : lecture des données via `GET /api/me` — fonctionnel
- **Interface complète** du module social : feed, création de post, likes animés, commentaires — démontrable via mocks locaux

### Ce qui est bloqué

- Persistance des publications entre sessions (données perdues au redémarrage de l'app)
- Partage de publications entre utilisateurs différents
- Upload de médias vers un stockage distant

---

## 4. Recommandations pour l'équipe back-end

Les endpoints suivants sont nécessaires pour débloquer la fonctionnalité en production :

```
# Publications
GET    /api/posts                     (feed paginé, ?page=&limit=)
POST   /api/posts                     (body: { content, mediaUrl? })
DELETE /api/posts/:id

# Interactions
POST   /api/posts/:id/like
DELETE /api/posts/:id/like

# Commentaires
GET    /api/posts/:id/comments
POST   /api/posts/:id/comments        (body: { content })

# Médias
POST   /api/media/upload              (multipart/form-data, field: file)
                                      → response: { url: "https://..." }

# Profil
PATCH  /api/me                        (body: { name?, avatarUrl? })
```

**Modèle de données suggéré (PostgreSQL) :**

```sql
CREATE TABLE posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id TEXT NOT NULL,  -- référence auth-service user.id
  content TEXT NOT NULL,
  media_url TEXT,
  media_type TEXT,          -- 'image' | 'video'
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE post_likes (
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
  user_id TEXT NOT NULL,
  PRIMARY KEY (post_id, user_id)
);

CREATE TABLE post_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
  author_id TEXT NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);
```

> **Note :** Ces modifications ne concernent que le back-end. L'équipe Flutter ne modifie aucun repo back-end.

---

## 5. Plan de travail Flutter en mode dégradé

| Fonctionnalité | État | Détail |
|---|---|---|
| Feed scrollable | ✅ Implémenté | 5 posts initiaux réalistes en mémoire |
| Pull-to-refresh | ✅ Implémenté | Recharge les mocks |
| Like / unlike animé | ✅ Implémenté | Toggle local avec animation ScaleTransition |
| Création de publication | ✅ Implémenté | Texte + photo (image_picker), ajout en tête de liste |
| Commentaires | ✅ Implémenté | Liste + saisie, ajout local |
| Édition nom profil | ✅ Implémenté | Dialog + persistance SharedPreferences |
| Photo de profil | ✅ Implémenté | image_picker + affichage local |
| Déconnexion | ✅ Implémenté | Existant, inchangé |

**Chemin de migration vers l'API réelle :**  
Remplacer `FeedRepositoryMock` par `FeedRepositoryImpl` (appels Dio vers les endpoints listés ci-dessus) dans `feed_provider.dart` — une seule ligne à changer dans le `Provider`.
