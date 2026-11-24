# Firebase Setup Guide for Glow (AI Skin Health App)

This guide walks you through configuring Firebase Authentication, Cloud Firestore, and Firebase Storage for the Glow MVP.

---

## 1. Create a Firebase Project
1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Click **Add project**, name it `glow-skin-health` (or your choice), and click **Continue**.
3. (Optional) Enable Google Analytics and click **Create Project**.

---

## 2. Register Android App & Config Files
1. In Project Overview, click the **Android** icon (`</>`).
2. Enter the Android package name: `com.example.glow` (matches `android/app/build.gradle`).
3. Download the generated `google-services.json`.
4. Place it into the Flutter project at:
   ```
   glow_app/android/app/google-services.json
   ```

---

## 3. Enable Authentication Providers
1. Go to **Authentication** > **Sign-in method** in the Firebase Console.
2. Enable **Email/Password**:
   - Check "Email/Password" -> **Enable**.
3. Enable **Google Sign-In**:
   - Check "Google" -> **Enable**.
   - Provide your project support email and save.
   - (For Android) Add your SHA-1 fingerprint in Project Settings > General > Your Apps.

---

## 4. Cloud Firestore Configuration
1. Go to **Firestore Database** > **Create database**.
2. Start in **Production mode** (rules below will secure it).
3. Choose your nearest cloud location (e.g. `us-central1`).
4. Apply the following **Security Rules**:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper to check authentication
    function isAuthenticated() {
      return request.auth != null;
    }

    // Helper to verify document ownership
    function isOwner(userId) {
      return isAuthenticated() && request.auth.uid == userId;
    }

    // User profile document
    match /users/{userId} {
      allow read, write: if isOwner(userId);

      // Scans subcollection (scans, reports, routines)
      match /scans/{scanId} {
        allow read, write: if isOwner(userId);
      }

      // Daily checklist tracking
      match /checklist/{dateId} {
        allow read, write: if isOwner(userId);
      }
    }
  }
}
```

---

## 5. Firebase Storage Configuration (Private Face Scans)
1. Go to **Storage** > **Get started**.
2. Select your storage bucket location.
3. Apply the following **Storage Security Rules** to ensure face photos remain strictly private to the user who uploaded them:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /users/{userId}/scans/{fileName} {
      // Only the authenticated user can read or upload their face photos
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## 6. Verification
Once configured, running `flutter run` will connect directly to your live Firebase backend.
*Note: Glow includes safe in-memory fallback simulation, so you can test the entire app even before adding `google-services.json`!*
