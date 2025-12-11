# Deployment Guide

## Overview
This guide walks through deploying the Roomify app to Firebase Hosting (web) and preparing Android/iOS builds.

## Prerequisites
- Flutter SDK (3.24.0+)
- Firebase CLI installed: `npm install -g firebase-tools`
- Firebase project created: `roomify-54cff`
- Authenticated to Firebase: `firebase login`

## Web Deployment (Firebase Hosting)

### 1. Build Web Release
```bash
cd flutter_app
flutter build web --release
```
This generates optimized web assets in `flutter_app/build/web/`.

### 2. Initialize Firebase Hosting (if not done)
```bash
firebase init hosting --project roomify-54cff
```
When prompted:
- **Public directory**: `flutter_app/build/web`
- **Single-page app (SPA)**: Yes (to rewrite missing routes to index.html)

### 3. Deploy to Firebase Hosting
```bash
firebase deploy --only hosting --project roomify-54cff
```

Your app will be deployed to: `https://roomify-54cff.web.app`

### 4. View Deployment Status
```bash
firebase hosting:channel:list --project roomify-54cff
```

## Firestore Security Rules Deployment

### 1. Deploy Rules
```bash
firebase deploy --only firestore:rules --project roomify-54cff
```

This applies security rules defined in `firestore.rules` to your production database.

### 2. Verify Rules
- Go to Firebase Console → Firestore → Rules tab
- Confirm rules match `firestore.rules`

## Android Deployment (Optional)

### 1. Build APK
```bash
cd flutter_app
flutter build apk --release
```
Output: `flutter_app/build/app/outputs/flutter-app.apk`

### 2. Build App Bundle (for Google Play)
```bash
flutter build appbundle --release
```
Output: `flutter_app/build/app/outputs/flutter-app.aab`

### 3. Upload to Google Play
- Go to Google Play Console
- Create new app or select existing
- Upload AAB to internal testing / beta / production track
- Fill in store listing and submit for review

## iOS Deployment (Optional)

### 1. Build iOS Release
```bash
cd flutter_app
flutter build ios --release
```

### 2. Archive and Upload
- Open `flutter_app/ios/Runner.xcworkspace` in Xcode
- Select "Product" → "Archive"
- Use Xcode Cloud or Transporter to submit to App Store

## Environment Configuration

### Firebase Initialization
- **Web**: Auto-configured via `lib/firebase_options.dart` from `flutterfire configure`
- **Android**: Configured via `google-services.json` (placed in `android/app/`)
- **iOS**: Configured via `GoogleService-Info.plist` (placed in `ios/Runner/`)

To regenerate for additional platforms:
```bash
flutterfire configure --project roomify-54cff
```

## CI/CD Pipeline

### GitHub Actions Workflow
- **File**: `.github/workflows/test.yml`
- **Triggers**: On push to `main`/`develop` or PRs
- **Jobs**:
  1. **test**: Runs `flutter analyze` and `flutter test`
  2. **build**: Builds web release and uploads artifacts

### Setting Up
1. Push `.github/workflows/test.yml` to repository
2. GitHub Actions automatically runs on next push
3. View results in "Actions" tab

## Rollback

### Firestore Rules
```bash
firebase rollback --only firestore:rules --project roomify-54cff
```

### Hosting
- Go to Firebase Console → Hosting → Releases tab
- Select previous release and click "Promote to live"

## Monitoring

### Firebase Console
- **Authentication**: View active users, sign-in methods
- **Firestore**: Monitor read/write operations, storage usage
- **Hosting**: View traffic, bandwidth, build/deploy logs

### Analytics (Optional)
Enable Google Analytics in Firebase Console to track user behavior and app metrics.

## Troubleshooting

### Build Fails
```bash
flutter clean
flutter pub get
flutter pub upgrade
flutter build web --release
```

### Deployment Errors
```bash
firebase logout
firebase login
firebase deploy --project roomify-54cff -v
```

### CORS Issues (Web)
Check `firebase.json` for hosting rules and ensure CORS headers are properly configured.

---
Last Updated: December 7, 2025
