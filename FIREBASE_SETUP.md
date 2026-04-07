# Firebase Setup Instructions

## Quick Setup (Recommended)

1. **Install FlutterFire CLI** (if not already installed):
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. **Login to Firebase**:
   ```bash
   firebase login
   ```

3. **Configure Firebase for your project**:
   ```bash
   flutterfire configure
   ```
   
   This will:
   - Detect your Firebase projects
   - Let you select a project
   - Automatically generate `lib/firebase_options.dart` with correct credentials
   - Configure all platforms (iOS, Android, macOS, Web)

## Manual Setup

If you prefer to configure manually:

1. **Get your Firebase credentials**:
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Select your project (or create a new one)
   - Go to Project Settings
   - Under "Your apps", add apps for each platform (iOS, Android, macOS, Web)

2. **Update `lib/firebase_options.dart`**:
   Replace the placeholder values with your actual Firebase credentials:
   - `apiKey`: Found in Firebase Console > Project Settings > General
   - `appId`: Found in Firebase Console > Project Settings > Your apps
   - `messagingSenderId`: Found in Firebase Console > Project Settings > Cloud Messaging
   - `projectId`: Your Firebase project ID
   - `storageBucket`: Your Firebase Storage bucket (usually `project-id.appspot.com`)

3. **For macOS specifically**:
   - Make sure you've added a macOS app in Firebase Console
   - The `iosBundleId` should match your macOS bundle ID (check `macos/Runner/Configs/AppInfo.xcconfig`)

## Verify Setup

After configuration, the app should start without Firebase errors. You can test by:
1. Running the app: `flutter run`
2. Trying to login (you'll need to create users in Firebase Authentication first)

## Creating Users

1. Go to Firebase Console > Authentication
2. Enable Email/Password authentication
3. Add users manually or let them sign up (if you enable sign-up)

## Setting User Roles

After creating users, set their roles in Firestore:
1. Go to Firebase Console > Firestore Database
2. Create a collection named `users`
3. For each user, create a document with their UID as the document ID
4. Add a field `role` with value: `"admin"`, `"staff"`, or `"viewer"`

Example document structure:
```
users/
  {user-uid}/
    role: "admin"
```

## Troubleshooting

- **"Configuration fails" error**: Make sure `firebase_options.dart` has real values, not placeholders
- **"GOOGLE_APP_ID" error**: Check that you've added the macOS app in Firebase Console
- **Authentication errors**: Make sure Email/Password auth is enabled in Firebase Console



