# Firestore Data Schema & Security Rules

## Collections Overview

### `users` Collection
Stores user profile information created at sign-up.

**Document ID:** Firebase Auth UID

**Schema:**
```json
{
  "displayName": "string (required)",
  "email": "string (required, unique)",
  "phone": "string (optional)",
  "createdAt": "timestamp",
  "updatedAt": "timestamp",
  "photoUrl": "string (optional, for profile picture)",
  "bio": "string (optional)"
}
```

---

### `rooms` Collection
Main entity: Room listings for roommate search/management.

**Document ID:** Auto-generated (Firestore)

**Schema:**
```json
{
  "title": "string (required, min 5 chars)",
  "description": "string (required, min 20 chars)",
  "location": "string (required)",
  "rent": "number (required, >= 0)",
  "bedrooms": "number (required, >= 1)",
  "bathrooms": "number (required, >= 1)",
  "amenities": ["string"],
  "imageUrl": "string (optional, from Firebase Storage)",
  "ownerId": "string (required, UID of the user who posted)",
  "status": "string (enum: 'available', 'pending', 'rented')",
  "tags": ["string (optional)"],
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

**Example:**
```json
{
  "title": "Cozy 2BR Apartment Downtown",
  "description": "Recently renovated apartment near metro, close to restaurants and shops.",
  "location": "123 Main St, Downtown",
  "rent": 1200,
  "bedrooms": 2,
  "bathrooms": 1,
  "amenities": ["WiFi", "Parking", "Laundry", "AC"],
  "imageUrl": "gs://roomify-54cff.appspot.com/rooms/room1.jpg",
  "ownerId": "user123",
  "status": "available",
  "tags": ["pet-friendly", "furnished"],
  "createdAt": 1702000000000,
  "updatedAt": 1702000000000
}
```

---

## Firestore Security Rules

Save as `firestore.rules` in the project root and deploy with `firebase deploy --only firestore:rules`.

```firestore
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    
    // Users collection: read own profile, write/update own profile
    match /users/{uid} {
      allow read: if request.auth.uid == uid;
      allow create: if request.auth.uid == uid 
        && request.resource.data.keys().hasAll(['displayName', 'email', 'createdAt']);
      allow update: if request.auth.uid == uid;
      allow delete: if false; // Prevent accidental deletion
    }
    
    // Rooms collection: public read, authenticated create, owner update/delete
    match /rooms/{roomId} {
      allow read: if true; // Anyone can view room listings
      allow create: if request.auth != null
        && request.resource.data.keys().hasAll(['title', 'description', 'location', 'rent', 'bedrooms', 'bathrooms', 'ownerId', 'status', 'createdAt'])
        && request.resource.data.ownerId == request.auth.uid
        && request.resource.data.rent >= 0
        && request.resource.data.bedrooms >= 1
        && request.resource.data.bathrooms >= 1;
      allow update: if request.auth.uid == resource.data.ownerId;
      allow delete: if request.auth.uid == resource.data.ownerId;
    }
    
    // Default: deny all
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

---

## Deployment Steps

1. **Initialize Firestore:**
   ```bash
   firebase init firestore
   ```

2. **Deploy rules:**
   ```bash
   firebase deploy --only firestore:rules
   ```

3. **Create Firestore database (if not already created):**
   - Go to Firebase Console → Firestore Database
   - Click "Create Database"
   - Choose region (e.g., `us-central1`) and start in "Test mode" during development

---

## Future Enhancements

- Add `reviews` subcollection under `rooms` for user feedback.
- Add `bookmarks` collection to track user-saved favorite rooms.
- Add `messages` collection for in-app chat between room owners and interested users.
- Add `applications` collection to track room inquiries/applications.
- Implement full-text search using Algolia or similar.
