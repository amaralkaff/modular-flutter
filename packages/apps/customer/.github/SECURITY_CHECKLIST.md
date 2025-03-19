# Security Checklist for Contributors

Before submitting a pull request, please review this security checklist:

## Firebase Security

- [ ] No Admin SDK credentials are used in the client app
- [ ] Proper Firebase security rules are implemented for Firestore/Storage
- [ ] Firebase App Check is enabled 
- [ ] No sensitive data is stored in unprotected Firestore collections
- [ ] Authentication state is properly managed throughout the app

## API Keys and Sensitive Information

- [ ] No API keys, tokens, or credentials are hardcoded in the source code
- [ ] No sensitive information is logged to the console
- [ ] Example files with placeholders are provided for configuration files (e.g., `.env.example`)
- [ ] All sensitive files are listed in `.gitignore`

## Configuration Files

- [ ] `google-services.json` only contains placeholders in example files
- [ ] `firebase_options.dart` only contains placeholders in example files 
- [ ] `.env` files are not committed to the repository
- [ ] Mapbox tokens are properly secured:
  - [ ] Public tokens (pk.*) only in .env files (not committed)
  - [ ] Secret tokens (sk.*) only in local.properties (not committed)

## Client-Side Security

- [ ] User input is properly validated before sending to Firebase
- [ ] No sensitive operations rely solely on client-side validation
- [ ] Cloud Functions are used for critical operations
- [ ] No bypassing of security rules through application logic

## Android Security

- [ ] No API keys in `AndroidManifest.xml`
- [ ] No credentials in `build.gradle` files
- [ ] ProGuard/R8 rules properly configured for release builds
- [ ] SafetyNet/Play Integrity is enabled for App Check

## iOS Security

- [ ] No API keys in `Info.plist`
- [ ] No credentials in `Podfile` or other build files
- [ ] DeviceCheck is enabled for App Check

## Data Handling

- [ ] User input is properly validated
- [ ] HTTPS is used for all network requests
- [ ] Authentication tokens are securely stored using encrypted storage
- [ ] App permissions are limited to only what's necessary
- [ ] Analytics does not collect PII (Personally Identifiable Information)

## Reporting Security Issues

If you discover a security vulnerability, please do NOT open an issue. 
Email [security@example.com](mailto:security@example.com) instead. 