# Customer App

This is the customer-facing mobile application for the food delivery system. It integrates multiple feature modules to provide a seamless user experience.

## Setup Instructions

### Prerequisites
- Flutter 3.13.0 or higher
- Dart 3.0.0 or higher
- Firebase project
- Mapbox account (for map functionality)

### Environment Setup

1. Create a `.env` file by copying `.env.example`:
   ```
   cp .env.example .env
   ```
   Then edit the `.env` file with your actual values:
   ```
   FIREBASE_REGION=asia
   FIREBASE_USE_EMULATOR=false  # Set to true for local development
   MAPBOX_ACCESS_TOKEN=your_mapbox_token
   ENABLE_PUSH_NOTIFICATIONS=true
   ENABLE_IN_APP_CHAT=true
   APP_NAME=Food Delivery
   APP_VERSION=1.0.0
   ```

2. Configure Firebase:
   - Create a Firebase project at https://console.firebase.google.com/
   - Register your app with Firebase
   - Download `google-services.json` and place it in `android/app/`
   - Download `GoogleService-Info.plist` and place it in `ios/Runner/`
   - Generate Firebase configuration using FlutterFire CLI:
   ```
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```
   This will create your actual `firebase_options.dart` file.
   
   - Enable the Firebase services you need:
     - Firebase Authentication
     - Cloud Firestore
     - Firebase Storage
     - Firebase Cloud Messaging (for notifications)
     - Firebase App Check (for security)

3. Configure Mapbox (for maps functionality):
   - Create a Mapbox account at https://www.mapbox.com/
   - Generate a public access token for your app
   - Add this token to your `.env` file as MAPBOX_ACCESS_TOKEN
   - For Android build functionality, you need a Mapbox Downloads token:
     - Go to your Mapbox account > Access Tokens
     - Create a secret token with the `DOWNLOADS:READ` scope
     - Add this token securely using one of these methods (never commit it to git):
       - Create a `local.properties` file in the android folder with: `MAPBOX_DOWNLOADS_TOKEN=your_secret_token`
       - Or set it as an environment variable: `export MAPBOX_DOWNLOADS_TOKEN=your_secret_token`

### Running the App

1. Install dependencies:
```
flutter pub get
```

2. Run the app:
```
flutter run
```

## Architecture

This app follows a modular Firebase-based architecture where features are separated into independent modules:

- **Core Module**: Contains shared utilities, services, and UI components
- **Auth Module**: Handles Firebase Authentication and user management
- **Restaurant Catalog**: Manages restaurant data from Firestore
- **Cart Module**: Handles shopping cart functionality
- **Orders Module**: Manages order placement and tracking with Firestore
- **Live Tracking**: Provides real-time delivery tracking

## Firebase Security

Since this app directly connects to Firebase without an intermediate API layer, it's important to:

1. **Set up proper Firebase Security Rules** for Firestore and Storage
2. **Implement Firebase App Check** to prevent unauthorized API access
3. **Use Firebase Authentication** for proper user access control
4. **Never use Admin SDK credentials** in the mobile app

Example Firestore Security Rules:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User profiles
    match /users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Restaurants
    match /restaurants/{restaurantId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && 
                    get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
    }
    
    // Orders
    match /orders/{orderId} {
      allow read: if request.auth != null && 
                  (request.auth.uid == resource.data.userId || 
                   get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
      allow create: if request.auth != null;
      allow update: if request.auth != null && 
                    (request.auth.uid == resource.data.userId || 
                     get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin');
    }
  }
}
```

## Common Issues and Solutions

### Firebase Initialization Error

If you see an error related to Firebase initialization, make sure:
- You've properly configured Firebase using the FlutterFire CLI
- Your `firebase_options.dart` file contains valid configuration values, not placeholders
- Your device/emulator has Google Play Services installed (for Android)
- If using Firebase Emulators, check that they're running and configured correctly

### Mapbox Integration

If maps are not showing correctly:
- Verify your Mapbox access token is correctly set in the `.env` file
- For Android, make sure your Downloads token is correctly set in `local.properties` or as an environment variable
- Check that you have the necessary permissions in AndroidManifest.xml and Info.plist
- If you get a "Failed to download Mapbox SDK" error during build, check your secret token permissions

### Authentication Issues

If you're experiencing authentication problems:
- Check your Firebase console to ensure Authentication is enabled
- Verify that the email/password authentication method is enabled
- For Google Sign-In, make sure you've configured the OAuth consent screen and added the SHA-1 fingerprint

## Security Best Practices

### Sensitive Files That Should Never Be Committed

The following files contain sensitive API keys and should NEVER be committed to version control:

1. **Firebase Configuration**
   - `google-services.json` (Android)
   - `GoogleService-Info.plist` (iOS)
   - `firebase_options.dart` (Flutter)

2. **Environment Variables**
   - `.env` (All secrets and API keys)
   - Any file with the pattern `*.env`

3. **Local Properties**
   - `android/local.properties` (Contains Mapbox secret token)

### Firebase Security Best Practices

1. **Security Rules**
   - Implement detailed security rules for Firestore, Storage, and Realtime Database
   - Test your security rules with the Firebase Rules Simulator

2. **Authentication**
   - Use Firebase Authentication for all user access
   - Implement proper authentication state management in the app

3. **App Check**
   - Enable Firebase App Check to prevent abuse of your Firebase resources
   - Use SafetyNet/Play Integrity for Android and DeviceCheck for iOS

4. **Data Validation**
   - Validate all data on the client before sending to Firebase
   - Use server-side Cloud Functions for critical validation logic

### Mapbox Tokens

- Public tokens (starting with `pk.`) are used client-side in the app
- Secret tokens (starting with `sk.`) must NEVER be exposed in client-side code
- For Android builds, store the secret download token in `local.properties`

## Contributing

Please follow the project's coding standards and architecture guidelines when contributing.

## License

This project is proprietary and confidential.
