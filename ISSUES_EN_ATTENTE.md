# Issues en attente — nécessitent modifications d'autres repos

## 1. ✅ GET /api/coach/plan — endpoint ajouté dans le BFF (pull du 21/04)
**Reste à faire Flutter :** brancher `OfflineRepositoryImpl` quand `ACTIVITY_SERVICE_URL` est opérationnel.

## 2. POST /api/coach/feedback — endpoint BFF appelant activity-service
**Impact :** Feedback après séance échoue silencieusement.  
**Fichier Flutter :** `lib/features/offline/data/repositories/offline_repository_impl.dart`

## 3. Résumé du jour (calories/macros) toujours à 0
**Cause :** Le service Python sauvegarde en **MongoDB**, mais `GET /api/user/today` lit depuis **PostgreSQL** via engine-go gRPC. Les deux bases ne sont pas synchronisées.  
**Solution BFF :** Après chaque analyse Python, le BFF doit appeler engine-go via gRPC pour enregistrer les macros en PostgreSQL.  
**Impact Flutter :** Aucun — le fallback à 0 est gracieux, les données apparaîtront automatiquement une fois le BFF corrigé.

## 4. GET /api/nutrition/history — retourne 500 (MongoDB inaccessible en local)
**Comportement actuel :** Fallback gracieux sur liste vide.  
**Cause :** `NUTRITION_SERVICE_URL` non configuré en local, le service MongoDB n'est pas exposé.

## 5. NUTRITION_SERVICE_URL vs python.medev-tech.fr — routes incompatibles
**Cause :** Le BFF appelle `NUTRITION_SERVICE_URL/upload` mais le service Python expose `/predict/upload`.  
**Contournement actuel :** Flutter appelle `python.medev-tech.fr/predict/upload` directement.  
**Solution BFF :** Corriger le handler pour appeler `/predict/upload` et configurer `NUTRITION_SERVICE_URL=https://python.medev-tech.fr` dans `.env.local`.

---

> Ces issues nécessitent des modifications dans `backend-hono` ou `engine-go` (repos des collègues).
