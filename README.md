# 🎵 SoundWave — Secure Flutter Music App

A full-featured secure audio app built with Flutter + Firebase.

---

## ✅ Features

| Feature | Status |
|---|---|
| 🔐 Biometric fingerprint on launch | ✅ |
| 🔥 Firebase Auth (login/register/reset) | ✅ |
| 📋 Registration with name, DOB, age check (≥13) | ✅ |
| 📊 Stats page with welcome message + histogram | ✅ |
| 🎯 Monthly listening goal (dropdown, saved locally) | ✅ |
| 🏆 Most played tracks list | ✅ |
| 🎵 Audio player with categories from Quran API | ✅ |
| ▶️ Play / Pause / Skip / Previous / Loop / Shuffle | ✅ |
| ❤️ Favorites saved to Firebase Firestore | ✅ |
| 🔐 Fingerprint required to delete favorites | ✅ |
| 👤 Profile page with full user info | ✅ |

---

## 🔥 Step 1 — Setup Firebase

1. Go to https://console.firebase.google.com
2. Create a new project called `soundwave`
3. Add an **Android app** with package name: `com.example.music_app`
4. Download `google-services.json`
5. Place it at: `android/app/google-services.json`
6. Enable **Authentication** → Email/Password
7. Enable **Firestore Database** (start in test mode)

---

## 🚀 Step 2 — Run

```bash
flutter pub get
flutter run
```

---

## 📁 Project Structure

```
lib/
├── main.dart                    ← Entry point
├── config/
│   └── theme.dart               ← App colors & theme
├── models/
│   ├── track.dart
│   └── user_model.dart
├── services/
│   ├── auth_service.dart        ← Firebase auth
│   ├── biometric_service.dart   ← Fingerprint
│   ├── favorites_service.dart   ← Firestore favorites
│   ├── player_provider.dart     ← Audio player state
│   ├── quran_service.dart       ← Quran API
│   └── stats_service.dart       ← Listening stats
├── screens/
│   ├── biometric_screen.dart    ← Launch screen
│   ├── auth_gate.dart
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── reset_password_screen.dart
│   ├── main_screen.dart         ← Bottom nav
│   ├── stats_screen.dart        ← Statistics + chart
│   ├── player_screen.dart       ← Library / categories
│   ├── now_playing_screen.dart  ← Full player
│   ├── favorites_screen.dart    ← Favorites list
│   └── profile_screen.dart
└── widgets/
    └── mini_player.dart
```

---

## ⚠️ Notes

- `minSdk` is set to **23** (required for biometric)
- `MainActivity` extends `FlutterFragmentActivity` (required for local_auth)
- Favorites deletion requires fingerprint confirmation
- Stats are stored locally with `SharedPreferences`
