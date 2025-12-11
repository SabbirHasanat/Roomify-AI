# Project Roadmap

## Vision
Build a simple, well-tested Flutter web/mobile app that demonstrates a full Firebase-backed workflow (auth, Firestore CRUD, responsive UI) as a Final Year Project.

## Objectives
- Produce a working MVP demonstrating core functionality.
- Use modern Flutter practices (state management, testing, CI).
- Prepare deployment and documentation suitable for a demo and evaluation.

## MVP Features (Must-have)
- User authentication (Email/password + Google).
- Main entity CRUD (create, list, view, update, delete) stored in Firestore.
- Responsive UI that works on web and mobile.
- Basic input validation and error handling.

## Stretch Features (If time allows)
- Offline support and synchronization.
- User profiles and role-based features.
- Image uploads with Firebase Storage.
- Real-time collaboration features (listeners/streams).

## Success Criteria
- Core flows (auth + CRUD) work end-to-end for a reviewer.
- Automated tests cover critical logic (unit + widget tests).
- CI runs tests on PRs and deploys the web app to Firebase Hosting.
- README and a short demo (video/GIF) explain how to run and test the app.

## Timeline (Suggested)
- Week 1: Project setup, roadmap, Firebase configuration (web + mobile), dependencies.
- Week 2: Implement authentication and protected routes.
- Week 3: Design data models, implement Firestore CRUD and UI.
- Week 4: State management, tests, accessibility, responsive polish.
- Week 5: CI, deployment, documentation, demo recording.

## Tech Stack
- Flutter (Dart)
- Firebase (Authentication, Firestore, Hosting)
- State: `Provider` or `Riverpod` (decide early)
- Testing: `flutter_test`, widget tests

## Next Steps (Immediate)
1. Run `flutterfire configure` and add Firebase config files for target platforms.
2. Implement authentication UI and integration with `firebase_auth`.
3. Define Firestore document schemas and security rules.

---
Created: 2025-12-07
