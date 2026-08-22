# TERA — Application Mobile Client

Projet de Développement Mobile.

Application Flutter (Clean Architecture) destinée aux **producteurs** et aux
**acheteurs** de la plateforme Tera (Dakar, Sénégal) : catalogue, demandes de
stockage, commandes, livraisons, portefeuille et notifications push.

> L'application consomme l'API REST lancée par le dossier backend.
> **Le backend doit tourner avant de lancer le mobile.**

---

## Table des matières

1. [Vue d'ensemble](#1-vue-densemble)
2. [Prérequis](#2-prérequis)
3. [Démarrage rapide](#3-démarrage-rapide)
4. [Étape A — Lancer l'infrastructure serveur](#étape-a--lancer-linfrastructure-serveur)
5. [Étape B — Configurer Firebase](#étape-b--configurer-firebase)
6. [Étape C — Configurer l'URL de l'API](#étape-c--configurer-lurl-de-lapi)
7. [Étape D — Lancer l'application](#étape-d--lancer-lapplication)
8. [Commandes Makefile](#8-commandes-makefile)
9. [Tests et qualité de code](#9-tests-et-qualité-de-code)
10. [Architecture du projet](#10-architecture-du-projet)
11. [Traductions](#11-traductions)
12. [Dépannage](#12-dépannage)

---

## 1. Vue d'ensemble

Le projet complet est composé de trois briques :

| Brique | Rôle | Port par défaut |
|---|---|---|
| **Backend** (Spring Boot) | API REST + base MySQL | `8081` |
| **Back-office** (React/Nginx) | Interface d'administration web | `5173` |
| **Mobile** (Flutter) — *ce dépôt* | Application producteur / acheteur | — |

Backend et back-office se lancent ensemble via le `docker-compose.yml` présent à
la racine de ce dépôt, en **une seule commande**. L'application mobile appelle
ensuite directement l'API sur le port `8081`.

---

## 2. Prérequis

| Logiciel | Version | Vérification |
|---|---|---|
| Docker Desktop | 20.10 ou plus | `docker --version` |
| Docker Compose | v2 ou plus | `docker compose version` |
| Flutter | **3.41.6** (Dart 3.11.4) | `flutter --version` |
| Android Studio / SDK Android | — | `flutter doctor` |

La version de Flutter est épinglée dans `.fvmrc`. Si vous utilisez
[FVM](https://fvm.app/) :

```sh
fvm use
```

et préfixez alors toutes les commandes par `fvm` (`fvm flutter run ...`).

Un **émulateur Android** doit être démarré (ou un téléphone branché en mode
débogage USB). Pour vérifier les appareils détectés :

```sh
flutter devices
```

---

## 3. Démarrage rapide

Pour les personnes pressées — le détail de chaque étape suit.

```sh
# A. Infrastructure serveur (à la racine de ce dépôt)
#    déposer d'abord serviceAccountKey.json à côté de docker-compose.yml
docker compose up -d
docker compose ps             # attendre que tera-backend soit "healthy"

# B. Firebase mobile (même projet Firebase qu'à l'étape A)
#    génère google-services.json ET lib/firebase_options.dart
flutterfire configure --project=<ID_DU_PROJET_FIREBASE> \
  --android-package-name=com.tera.client.dev

# C. Dépendances et génération de code
flutter pub get
make build

# D. Lancement sur l'émulateur
flutter run --flavor development --target lib/main_development.dart
```

---

## Étape A — Lancer l'infrastructure serveur

Le fichier `docker-compose.yml` situé **à la racine de ce dépôt** lance toute
l'infrastructure serveur : base MySQL, API backend et back-office web.
Rien à compiler, aucune installation de Java, Maven, Node ou MySQL : les images
sont téléchargées depuis Docker Hub.

Toute la configuration (identifiants de base, clé JWT, compte administrateur)
est déjà renseignée dans `docker-compose.yml` — **il n'y a pas de fichier `.env`
à créer**.

### A.1 — Déposer la clé Firebase du backend

Placer la clé de compte de service **à côté du fichier `docker-compose.yml`**,
nommée exactement `serviceAccountKey.json` :

```
tera-front-mobile-client/
├── docker-compose.yml
└── serviceAccountKey.json   ← à ajouter
```

Pour l'obtenir : **Console Firebase → Paramètres du projet (roue dentée) →
onglet « Comptes de service » → « Générer une nouvelle clé privée »**, puis
renommer le fichier téléchargé en `serviceAccountKey.json`.

> ⚠️ Déposer la clé **avant** le premier `docker compose up`. Si le fichier est
> absent, Docker crée un **dossier vide** à sa place et le backend redémarre en
> boucle (voir [Dépannage](#le-backend-redémarre-en-boucle--erreur-is-a-directory)).

> Pour démarrer **sans** Firebase : dans `docker-compose.yml`, mettre
> `FIREBASE_ENABLED: "false"` et supprimer la ligne du volume
> `./serviceAccountKey.json:...`. Tout fonctionne, seules les notifications push
> sont désactivées.

⚠️ **Retenez le projet Firebase utilisé ici** : l'application mobile devra
utiliser **exactement le même** (voir [Étape B](#étape-b--configurer-firebase)).

### A.2 — Démarrer les conteneurs

Depuis la racine du dépôt :

```bash
docker compose up -d
```

Le premier lancement télécharge les images (~950 Mo) et prend quelques minutes.

```bash
docker compose ps
```

Attendre que `tera-backend` affiche le statut **`healthy`** — environ 1 minute
au premier démarrage (initialisation de la base de données).

### A.3 — Accès aux services

| Service | URL | Description |
|---|---|---|
| **Back-office** | <http://localhost:5173> | Interface web d'administration |
| API Backend | <http://localhost:8081> | API REST consommée par le mobile |
| Documentation API | <http://localhost:8081/swagger-ui.html> | Swagger — teste les endpoints |

La base MySQL n'est **pas exposée** sur la machine hôte : elle n'est accessible
que depuis le réseau interne de Docker.

**Compte administrateur** (créé automatiquement au premier démarrage) :

| Téléphone | Mot de passe |
|---|---|
| `221772222224` | `AdminDefault` |

Modifiables via `ADMIN_DEFAULT_PHONE` / `ADMIN_DEFAULT_PASSWORD` dans
`docker-compose.yml`, **avant** le premier démarrage.

### A.4 — Vérifier que tout fonctionne

```bash
curl -X POST http://localhost:5173/api/admin/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phoneNumber":"221772222224","password":"AdminDefault"}'
```

Une réponse contenant `"token"` valide **toute la chaîne** : back-office →
backend → base de données. **Ne passez à l'étape suivante qu'après ce test.**

Pour tester l'API seule (celle que le mobile appellera), la même requête sur le
port `8081` doit donner le même résultat :

```bash
curl -X POST http://localhost:8081/api/admin/auth/login \
  -H "Content-Type: application/json" \
  -d '{"phoneNumber":"221772222224","password":"AdminDefault"}'
```

---

## Étape B — Configurer Firebase

L'application utilise `firebase_core` et `firebase_messaging` pour les
notifications push. Deux fichiers sont nécessaires et **ne sont pas versionnés**
(ils sont propres à votre projet Firebase) — il faut donc les générer :

| Fichier | Rôle | Sans lui |
|---|---|---|
| `android/app/google-services.json` | Configuration native Android | La compilation échoue : `File google-services.json is missing` |
| `lib/firebase_options.dart` | Configuration côté Dart | La compilation échoue : import introuvable dans `bootstrap.dart` |

Le moyen le plus simple de générer **les deux d'un coup** est la FlutterFire CLI
(voir [B.3](#b3--générer-les-fichiers-avec-la-flutterfire-cli)).

> 🔑 **Point important** — utilisez le **même projet Firebase** que celui dont
> provient le `serviceAccountKey.json` déposé côté backend
> ([étape A.1](#a1--déposer-la-clé-firebase-du-backend)). Si le mobile et le
> backend pointent vers deux projets différents, les jetons FCM enregistrés par
> l'application ne seront jamais joignables par le serveur : **aucune
> notification push n'arrivera.**

### B.1 — Enregistrer les applications Android

Dans la [console Firebase](https://console.firebase.google.com/), ouvrir le
projet, puis **Paramètres du projet → Vos applications → Ajouter une application
Android**.

Chaque saveur (*flavor*) possède son propre `applicationId` et doit donc être
enregistrée séparément :

| Saveur | `applicationId` | Nécessaire pour |
|---|---|---|
| `development` | `com.tera.client.dev` | Développement quotidien |
| `staging` | `com.tera.client.stg` | Recette |
| `production` | `com.tera.client` | Publication |

Pour un simple lancement en développement, **seul `com.tera.client.dev` est
indispensable**.

### B.2 — Télécharger et placer `google-services.json`

Télécharger le `google-services.json` généré par la console, puis le placer à
cet emplacement exact :

```
android/app/google-services.json
```

Le fichier doit contenir un bloc `client` pour chaque `package_name` enregistré.
Vérification rapide :

```bash
grep package_name android/app/google-services.json
```

### B.3 — Générer les fichiers avec la FlutterFire CLI

**Méthode recommandée** : la CLI enregistre les applications, télécharge le
`google-services.json` **et** génère `lib/firebase_options.dart`, en une seule
commande :

```sh
dart pub global activate flutterfire_cli
flutterfire configure --project=<ID_DU_PROJET_FIREBASE> \
  --android-package-name=com.tera.client.dev
```

Où `<ID_DU_PROJET_FIREBASE>` est l'identifiant du **même** projet Firebase que
celui du `serviceAccountKey.json` du backend.

Vérifier ensuite que les deux fichiers existent :

```sh
ls android/app/google-services.json lib/firebase_options.dart
```

Le `Makefile` fournit également des raccourcis (`make firebase-dev`,
`firebase-stg`, `firebase-prod`) qui s'appuient sur les variables
d'environnement `FIREBASE_EMAIL`, `FIREBASE_PROJECT_ID_DEV` et
`PROJECT_PACKAGE` — à adapter à votre projet avant usage.

---

## Étape C — Configurer l'URL de l'API

L'URL de base est définie dans `lib/core/network/dio_client.dart` :

```dart
const _baseUrl = 'http://10.0.2.2:8081';
```

Le port `8081` est celui publié par le service `backend` dans
`docker-compose.yml` (`"8081:8080"`). L'hôte dépend en revanche de l'appareil
utilisé :

| Cible | Valeur à utiliser | Pourquoi |
|---|---|---|
| **Émulateur Android** | `http://10.0.2.2:8081` | `10.0.2.2` est l'alias de la machine hôte vue depuis l'émulateur |
| **Simulateur iOS** | `http://localhost:8081` | Le simulateur partage le réseau de l'hôte |
| **Téléphone physique** | `http://<IP_LOCALE_DU_PC>:8081` | Ex. `http://192.168.1.12:8081` — le téléphone doit être sur le même Wi-Fi |

Pour connaître l'IP locale du PC : `ipconfig` (Windows) ou `ifconfig` / `ip a`
(macOS/Linux).

⚠️ Si vous avez modifié le port publié dans `docker-compose.yml` (par exemple
pour cause de conflit), reportez la même valeur ici.

---

## Étape D — Lancer l'application

### D.1 — Dépendances et génération de code

```sh
flutter pub get
```

Puis générer le code (injection de dépendances, sérialisation JSON, assets,
traductions) :

```sh
make build
```

équivalent à :

```sh
dart run build_runner build --delete-conflicting-outputs
```

> Cette étape est **obligatoire** après un premier clonage, et à relancer après
> toute modification d'une classe annotée `@injectable` / `@JsonSerializable`,
> ou après l'ajout d'un asset.

### D.2 — Lancer en mode développement

Le projet comporte trois saveurs : `development`, `staging` et `production`.

```sh
# Développement (celle à utiliser)
flutter run --flavor development --target lib/main_development.dart

# Recette
flutter run --flavor staging --target lib/main_staging.dart

# Production
flutter run --flavor production --target lib/main_production.dart
```

Vous pouvez aussi utiliser les configurations de lancement fournies par
VSCode / Android Studio.

Pour cibler un appareil précis lorsque plusieurs sont connectés :

```sh
flutter devices                       # lister les appareils
flutter run --flavor development --target lib/main_development.dart -d emulator-5554
```

> ⏳ **La première compilation Android est longue** (plusieurs dizaines de
> minutes selon la machine) : Gradle télécharge et compile toutes les
> dépendances. Les lancements suivants sont bien plus rapides, et le *hot
> reload* (`r` dans le terminal) est instantané.

Au premier lancement, l'application demande l'autorisation d'envoyer des
notifications : accepter pour que l'enregistrement du jeton FCM aboutisse.

### D.3 — Générer un APK de développement

Plutôt que de retenir les commandes, utilisez le `Makefile` :

```sh
make apk-dev     # APK debug, saveur development
make apk-stg     # APK profile, saveur staging
make apk-prod    # APK release, saveur production
```

`make apk-dev` correspond à :

```sh
flutter build apk --debug --flavor development --target lib/main_development.dart
```

L'APK est généré dans `build/app/outputs/flutter-apk/`. Il peut ensuite être
installé manuellement :

```sh
adb install build/app/outputs/flutter-apk/app-development-debug.apk
```

Pour iOS, les cibles équivalentes sont `make ipa-dev`, `ipa-stg` et `ipa-prod`.

---

## 8. Commandes Makefile

```sh
make get           # flutter pub get
make build         # génération de code (build_runner), une passe
make watch         # génération de code en continu
make apk-dev       # APK debug (development)
make apk-stg       # APK profile (staging)
make apk-prod      # APK release (production)
make ipa-dev       # IPA debug (development)
make ipa-stg       # IPA profile (staging)
make ipa-prod      # IPA release (production)
make test          # tests + couverture
make fix           # dart fix --apply
make check-fix     # dart fix --dry-run
make analyze       # dart analyze lib test
make format        # dart format (échoue si non formaté)
make prepare       # fix + format + analyze (à lancer avant un commit)
```

Les cibles `firebase-dev` / `firebase-stg` / `firebase-prod` appellent
`flutterfire config` et nécessitent les variables d'environnement
`FIREBASE_EMAIL`, `FIREBASE_PROJECT_ID_*` et `PROJECT_PACKAGE`.

---

## 9. Tests et qualité de code

```sh
# Tests unitaires et de widgets, avec couverture
flutter test --coverage --test-randomize-ordering-seed random

# Un seul fichier ou dossier
flutter test test/features/counter/
```

Rapport de couverture HTML via [lcov](https://github.com/linux-test-project/lcov) :

```sh
genhtml coverage/lcov.info -o coverage/
open coverage/index.html
```

Avant tout commit :

```sh
make prepare       # dart fix --apply → format → analyze
```

L'analyse statique suit les règles de
[`very_good_analysis`](https://pub.dev/packages/very_good_analysis). Les
fichiers générés (`*.g.dart`, `*.gen.dart`, `*.config.dart`) en sont exclus.

---

## 10. Architecture du projet

Architecture **Clean** : trois couches par fonctionnalité, plus des dossiers
transverses `core/` et `shared/`.

| Couche | Emplacement | Contenu |
|---|---|---|
| Data | `features/<f>/data/` | `datasources/` (réseau, local), `models/` (DTO), `repositories/` (implémentations) |
| Domain | `features/<f>/domain/` | `entities/`, `repositories/` (interfaces), `usecases/` |
| Presentation | `features/<f>/presentation/` | `blocs/` (Cubits/Blocs), `pages/`, `widgets/` |

### Fonctionnalités

`auth` · `market` · `orders` · `storage` · `payment` · `wallet` ·
`notifications` · `profile`

### Fichiers clés

| Fichier | Rôle |
|---|---|
| `lib/main_development.dart` (et `_staging`, `_production`) | Points d'entrée, appellent `bootstrap()` |
| `lib/bootstrap.dart` | Initialise Firebase, l'injection de dépendances et `AppBlocObserver` |
| `lib/injector.dart` | GetIt + Injectable (config générée : `injector.config.dart`) |
| `lib/app/router/app_router.dart` | Routes GoRouter — utiliser les constantes `AppRouter.<nom>` |
| `lib/app/view/app.dart` | `MultiBlocProvider`, `ScreenUtilInit`, `MaterialApp.router` |
| `lib/core/network/dio_client.dart` | Client HTTP Dio, URL de base, intercepteurs |
| `lib/firebase_options.dart` | Options Firebase générées par FlutterFire |

### Conventions

- **Gestion d'erreurs** — toutes les méthodes de repository et de use case
  renvoient `Either<Failure, T>` (dartz). `Failure` est une classe scellée avec
  `LocalFailure` et `ServerFailure`
  (`lib/core/domain/failures/failure.dart`). Côté UI, le mixin
  `FailureMessageHandler` traduit les échecs en messages.
- **State management** — BLoC / Cubit via `flutter_bloc`. L'état global est
  fourni à la racine, les Cubits de fonctionnalité au niveau de la page.
- **Notifications flash** — `context.displayFlash(message)` depuis n'importe où
  dans l'arbre de widgets.
- **Assets** — références générées dans `lib/gen/assets.gen.dart` :
  utiliser `Assets.images.foo` plutôt qu'une chaîne brute.

### Arborescence

```tree
assets
├── fonts                               # Polices non-Google
├── google_fonts                        # Polices Google hors-ligne
├── icons                               # Icônes
├── images                              # Images
docker-compose.yml                      # Infrastructure serveur (voir Étape A)
serviceAccountKey.json                  # ⚠ à fournir (voir Étape A.1)
android
└── app
    └── google-services.json            # ⚠ à fournir (voir Étape B)
lib
├── app
│   ├── router/app_router.dart          # Routeur de l'application
│   └── view/app.dart                   # Widget racine
├── core
│   ├── di                              # Modules d'injection de dépendances
│   ├── domain                          # Classes de base de la couche domaine
│   ├── network                         # Dio, session, intercepteurs
│   ├── notifications                   # Service FCM
│   └── extensions                      # Extensions et utilitaires
├── shared                              # Entités, modèles et widgets partagés
├── features
│   └── <fonctionnalité>
│       ├── data
│       │   ├── datasources             # Sources de données (réseau, local)
│       │   ├── models                  # DTO / modèles de payload
│       │   └── repositories            # Implémentations des repositories
│       ├── domain
│       │   ├── entities                # Entités métier
│       │   ├── repositories            # Interfaces de repository
│       │   └── usecases                # Cas d'usage métier
│       └── presentation
│           ├── blocs                   # Logique applicative et état
│           ├── pages                   # Écrans
│           └── widgets                 # Widgets de la fonctionnalité
├── l10n
│   ├── arb
│   │   ├── app_en.arb                  # Anglais
│   │   ├── app_fr.arb                  # Français
│   │   └── app_id.arb                  # Indonésien
│   └── generated                       # Fichiers générés (ne pas éditer)
├── bootstrap.dart                      # Script de démarrage commun
├── firebase_options.dart               # Options Firebase
├── main_development.dart               # Point d'entrée development
├── main_staging.dart                   # Point d'entrée staging
└── main_production.dart                # Point d'entrée production
test                                    # Tests, structure miroir de lib/
```

---

## 11. Traductions

Le projet s'appuie sur
[`flutter_localizations`](https://api.flutter.dev/flutter/flutter_localizations/flutter_localizations-library.html)
et suit le
[guide officiel d'internationalisation](https://flutter.dev/docs/development/accessibility-and-localization/internationalization).

### Ajouter une chaîne

Ouvrir `lib/l10n/arb/app_fr.arb` et ajouter la clé, sa valeur et sa description :

```arb
{
    "@@locale": "fr",
    "helloWorld": "Bonjour tout le monde",
    "@helloWorld": {
        "description": "Texte de bienvenue"
    }
}
```

Répercuter la clé dans **chaque** fichier `.arb` (`app_en.arb`, `app_id.arb`),
puis régénérer :

```sh
flutter gen-l10n
```

### Utiliser la chaîne

```dart
import 'package:tera/l10n/generated/app_localizations.dart';

@override
Widget build(BuildContext context) {
  final l10n = context.l10n;
  return Text(l10n.helloWorld);
}
```

> ⚠️ Importer depuis `package:tera/l10n/generated/app_localizations.dart`, et
> **non** depuis `flutter_gen` (paquet synthétique déprécié).

### Ajouter une langue

1. Créer `lib/l10n/arb/app_<code>.arb`.
2. Ajouter le code de langue au tableau `CFBundleLocalizations` dans
   `ios/Runner/Info.plist`.

---

## 12. Dépannage

### `File google-services.json is missing` à la compilation

Le fichier n'a pas été déposé, ou pas au bon endroit. Il doit se trouver dans
`android/app/google-services.json` — voir [Étape B](#étape-b--configurer-firebase).

### `Target of URI doesn't exist: 'firebase_options.dart'`

Le fichier `lib/firebase_options.dart` n'a pas été généré. Il n'est pas versionné
car il est propre à chaque projet Firebase — le créer avec
`flutterfire configure` (voir [Étape B.3](#b3--générer-les-fichiers-avec-la-flutterfire-cli)).

### `No matching client found for package name 'com.tera.client.stg'`

La saveur que vous compilez n'est pas enregistrée dans le projet Firebase.
Ajouter l'application Android correspondante dans la console (voir le tableau
des `applicationId` en [Étape B.1](#b1--enregistrer-les-applications-android)),
puis retélécharger `google-services.json`.

### L'application se lance mais aucune donnée ne s'affiche

Vérifier dans l'ordre :

1. Le backend est-il démarré et `healthy` ? → `docker compose ps`
2. Répond-il ? → la requête `curl` de l'[étape A.4](#a4--vérifier-que-tout-fonctionne)
3. L'URL de base correspond-elle à l'appareil utilisé ?
   → [Étape C](#étape-c--configurer-lurl-de-lapi)

Les requêtes HTTP sont tracées dans les logs. Sur Android :

```sh
adb logcat | grep "\[HTTP\]"
```

Un `401 UNAUTHORIZED` au démarrage sur `/api/notifications/token` est **normal**
tant que l'utilisateur n'est pas connecté.

### `Connection refused` ou délai d'attente dépassé

L'appareil n'atteint pas le backend. Sur émulateur, l'hôte est `10.0.2.2` et non
`localhost` (`localhost` désigne l'émulateur lui-même). Sur téléphone physique,
utiliser l'IP locale du PC et vérifier que les deux sont sur le même réseau.

### « port is already allocated » au lancement de Docker

Le port `8081` ou `5173` est déjà utilisé sur votre machine. Modifier la partie
**gauche** du mapping dans `docker-compose.yml` (par exemple `"8082:8080"` pour
le backend), puis relancer `docker compose up -d`.
**Reporter le nouveau port dans `dio_client.dart`** (voir
[Étape C](#étape-c--configurer-lurl-de-lapi)).

⚠️ Ne pas modifier `API_BASE_URL` : elle utilise le réseau interne de Docker et
reste `http://backend:8080` quels que soient les ports publiés.

### Le backend redémarre en boucle — erreur `(Is a directory)`

```
FirebaseException: Error while initializing firebase
/app/config/serviceAccountKey.json (Is a directory)
```

Cela signifie que `serviceAccountKey.json` était **absent** au moment du
`docker compose up`. Docker a alors créé un **dossier vide** portant ce nom à la
place du fichier. Correction :

```bash
docker compose down
rm -rf serviceAccountKey.json
```

Sous Windows (PowerShell) :

```powershell
docker compose down
Remove-Item -Recurse -Force serviceAccountKey.json
```

Déposer ensuite la vraie clé, vérifier qu'il s'agit bien d'un **fichier** et non
d'un dossier, puis relancer `docker compose up -d`.

> ⚠️ Toujours déposer la clé **avant** le premier `docker compose up`.

### Le back-office affiche « 502 Bad Gateway »

Le backend n'est pas encore prêt. Attendre qu'il soit `healthy`
(`docker compose ps`), puis rafraîchir la page.

### Les notifications push n'arrivent jamais

Le mobile et le backend doivent utiliser **le même projet Firebase** — voir
l'encadré de l'[Étape B](#étape-b--configurer-firebase). Vérifier aussi que
l'autorisation de notification a bien été accordée sur l'appareil.

### Erreurs de compilation après un `git pull`

Le code généré est désynchronisé :

```sh
flutter clean
flutter pub get
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
```

### Repartir de zéro côté serveur (base vide)

```bash
docker compose down -v     # ⚠ supprime AUSSI la base de données
docker compose up -d
```

---

## Annexe — Commandes Docker utiles

```bash
docker compose ps                  # état des conteneurs
docker compose logs -f backend     # logs du backend en direct
docker compose logs -f             # logs de tous les services
docker compose restart backend     # redémarrer le backend
docker compose stop                # arrêter (les données sont conservées)
docker compose up -d               # relancer
docker compose down                # arrêter et supprimer les conteneurs
docker compose down -v             # ⚠ supprime AUSSI la base de données
```

---

## Annexe — Architecture serveur

**Backend** — Java 17 / Spring Boot 4, architecture hexagonale (ports &
adaptateurs), découpée en 8 modules métier : `iam` (authentification JWT),
`users`, `catalog`, `stock`, `order`, `delivery`, `payment`, `notification`.
Les modules communiquent exclusivement par **événements Spring**
(`@TransactionalEventListener`), garantissant un couplage faible : une commande
déclenche en cascade la réservation de stock, la création de la livraison et
l'envoi des notifications.

**Persistance** — MySQL 8.4, clés primaires UUID, pool de connexions HikariCP.

**Sécurité** — JWT sans état (token 15 min, refresh 7 jours), contrôle d'accès
par rôle via `@PreAuthorize`.

**Notifications** — Firebase Cloud Messaging (push) + notifications in-app
diffusées en temps réel par SSE.

**Back-office** — React (Vite + TypeScript) servi par Nginx, qui relaie lui-même
les appels `/api/` vers le backend à l'intérieur du réseau Docker
(`API_BASE_URL=http://backend:8080`). Le navigateur ne contacte donc qu'une
seule origine : `http://localhost:5173`. C'est pourquoi `API_BASE_URL` ne doit
**jamais** valoir `localhost` — nginx se renverrait vers lui-même. Modules
couverts : tableau de bord, demandes de stockage, commandes, livraisons, stocks,
catalogue produits, entrepôts, utilisateurs et notifications. Interface bilingue
FR/EN, exports CSV et flux temps réel SSE.

**Rôles** — `SUPERADMIN` et `ADMIN` (accès complet), `WAREHOUSEADMIN` (limité à
son entrepôt), `PRODUCER` et `CONSUMER` (comptes gérés depuis le back-office,
sans accès à celui-ci).

**Images Docker**

| Composant | Image |
|---|---|
| Backend | `melasembene/sembene-dev-mobile:backend-latest` |
| Back-office | `melasembene/sembene-dev-mobile:frontend-latest` |

---

## Bibliothèques principales

| Catégorie | Bibliothèque |
|---|---|
| **State management** | `bloc`, `flutter_bloc`, `rxdart` |
| **Réseau** | `dio` |
| **Firebase** | `firebase_core`, `firebase_messaging` |
| **Routage** | `go_router` |
| **Génération de code** | `build_runner`, `flutter_gen_runner` |
| **Langage** | `dartz`, `equatable`, `change_case`, `intl`, `uuid`, `crypto` |
| **Injection de dépendances** | `get_it`, `injectable`, `injectable_generator` |
| **Stockage local** | `shared_preferences` |
| **Validation de formulaires** | `formz` |
| **Widgets** | `flutter_screenutil`, `google_fonts` |
| **Tests** | `mocktail`, `bloc_test` |

Compatibles avec Flutter 3.41.6 (Dart 3.11.4).
