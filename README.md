# BNWEMS Mobile App

Flutter mobile application for **Field Staff (Leader Staff & Technical Staff)** of the Binh Nguyen Wedding Event Management System.

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter (Dart SDK ^3.12.1) |
| HTTP | `http` package |
| Storage | `shared_preferences` |
| State | `ChangeNotifier` + InheritedWidget |
| Testing | `flutter_test` + `mockito` |

## Target Users

- **Leader Staff**: View assigned orders, record field attendance, submit change requests, upload survey reports
- **Technical Staff**: View assigned tasks, update progress

## Quick Start

### Prerequisites

- Flutter SDK installed and on PATH
- **Windows Developer Mode enabled** (required for Flutter plugin symlinks)
  - Run: `start ms-settings:developers`

```bash
# 1. Get dependencies
flutter pub get

# 2. Run on connected device/emulator
flutter run

# 3. Run tests
flutter test
```

## Project Structure

```
mobile-app/
├── lib/
│   ├── main.dart                  # App entry point
│   ├── models/
│   │   ├── user_model.dart        # User + Role data model
│   │   └── order_model.dart       # Order + CustomerSummary model
│   ├── services/
│   │   ├── api_service.dart       # HTTP client with JWT auth headers
│   │   ├── auth_service.dart      # Login, logout, change-password
│   │   └── order_service.dart     # Order list and detail
│   ├── providers/
│   │   └── auth_provider.dart     # ChangeNotifier for auth state
│   └── utils/
│       └── storage_helper.dart    # SharedPreferences token storage
└── test/
    └── models/
        └── models_test.dart       # Unit tests for UserModel & OrderModel
```

## Important Notes

> **Android Emulator**: The app uses `http://10.0.2.2:3001/api/v1` as the backend URL.  
> `10.0.2.2` maps to your host machine's `localhost` from within the Android emulator.

## Running Tests

```bash
flutter test
```

Tests in `test/models/models_test.dart` are pure Dart unit tests that don't require a running device.
