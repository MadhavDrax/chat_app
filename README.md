# Chat App 💬

A real-time chat application built with Flutter and Firebase.

## Features

- **User authentication** — sign up / sign in with Firebase Auth
- **Real-time messaging** powered by Cloud Firestore
- **Image sharing** in chat via Firebase Storage
- **Cloud Functions** backend for server-side logic (e.g. notifications, message processing)
- Cross-platform: Android, iOS, Web, macOS, Linux

## Tech Stack

- **Flutter / Dart**
- **Firebase Authentication**
- **Cloud Firestore** — real-time database
- **Firebase Storage** — image/media storage
- **Firebase Cloud Functions** (Node.js/TypeScript, under `functions/`)

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed and set up
- A [Firebase project](https://console.firebase.google.com/) with Auth, Firestore, and Storage enabled
- [Node.js](https://nodejs.org/) (for the Cloud Functions in `functions/`)
- [Firebase CLI](https://firebase.google.com/docs/cli) installed (`npm install -g firebase-tools`)

### Setup

1. Clone the repo
   ```bash
   git clone https://github.com/MadhavDrax/chat_app.git
   cd chat_app
   ```

2. Install Flutter dependencies
   ```bash
   flutter pub get
   ```

3. Configure Firebase for your own project:
   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   This generates your own `lib/firebase_options.dart`, `android/app/google-services.json`, and `ios/Runner/GoogleService-Info.plist` — these are **gitignored** and must be generated per developer/environment, not committed.

4. Install Cloud Functions dependencies
   ```bash
   cd functions
   npm install
   cd ..
   ```

5. Deploy Cloud Functions (optional, only if you're modifying backend logic)
   ```bash
   firebase deploy --only functions
   ```

6. Run the app
   ```bash
   flutter run
   ```

## Environment / Secrets

This project does **not** commit any Firebase config or API keys. Required local-only files (already covered by `.gitignore`):

```
.env
.env.*
**/firebase_options.dart
**/google-services.json
**/GoogleService-Info.plist
functions/node_modules/
```

Each contributor should run `flutterfire configure` against their own Firebase project (or get the shared project's config from the team through a secure channel — never via git).

## Project Structure

```
lib/
├── models/          # Data models (User, Message, etc.)
├── screens/         # App screens (login, chat list, chat room)
├── widgets/         # Reusable UI components
└── services/        # Firebase service wrappers (auth, chat, storage)

functions/           # Firebase Cloud Functions (Node.js/TypeScript backend)
```

## Permissions

The app may require the following device permissions:
- **Camera / Gallery** — to send images in chat
- **Notifications** — for push notifications on new messages (if configured)

Make sure these are set up in `android/app/src/main/AndroidManifest.xml` and `ios/Runner/Info.plist`.

## License

This project is for personal/learning purposes.
