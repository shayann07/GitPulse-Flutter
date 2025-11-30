# GitPulse (Flutter)

GitPulse is a mobile app that connects to your GitHub account, lets you choose which repositories are eligible, and then automatically adds harmless marker commits (`<!-- commit N -->`) to the README of a randomly selected repo. Each marker is one real commit. The goal is simple: keep your contribution graph alive with zero friction.

This repository contains the **Flutter implementation** of GitPulse.

---

## 🚀 Features

* GitHub OAuth login (secure, token stays on-device)
* Fetches all user-owned repositories
* Include/exclude toggles for each repo
* Runs a session that:

  * Picks a random eligible repo with a README
  * Detects the last `<!-- commit N -->` marker
  * Adds new markers sequentially (one commit per marker)
* Firestore sync for:

  * Settings
  * Run history
  * Daily commit counters
* Modern UI with screens for:

  * Login
  * Dashboard
  * Repo selection
  * Run history
  * Settings

---

## 📱 Screens

* **Walkthrough / Intro** – first-run explanation
* **Login Screen** – GitHub OAuth
* **Home Dashboard** – active repos, commits-per-run, run button
* **Repositories Screen** – full list of repos with include toggles
* **Run Screen** – live progress of each commit
* **History Screen** – past sessions with details
* **Settings Screen** – templates, counters, preferences

---

## 🏗️ Architecture

* Flutter
* Provider state management
* Firebase Firestore
* GitHub REST API
* Secure local token storage

---

## 📂 Project Structure

```
lib/
 ├── main.dart
 ├── auth/
 │   └── auth_service.dart
 ├── data/
 │   ├── github_service.dart
 │   ├── firestore_service.dart
 │   └── run_service.dart
 ├── models/
 │   ├── github_repo.dart
 │   ├── run_result.dart
 │   ├── run_history_entry.dart
 │   ├── user_profile.dart
 │   └── user_settings.dart
 ├── providers/
 │   └── app_providers.dart
 ├── screens/
 │   ├── walkthrough_screen.dart
 │   ├── login_screen.dart
 │   ├── home_screen.dart
 │   ├── repositories_screen.dart
 │   ├── run_screen.dart
 │   ├── settings_screen.dart
 │   └── history_screen.dart
 ├── firebase/
 │   └── firebase_options.dart
 └── utils/
     ├── session_data.dart
     └── today_stats.dart
```

---

## ⚙️ How It Works

### 1. Repo Selection

* Fetches all owner repos from GitHub
* Filters out: archived, forks, org-owned, non-writable repos
* Lets user toggle inclusion per repo

### 2. Commit Flow

For the selected random repo:

1. Read README
2. Detect last marker (`<!-- commit N -->`)
3. Generate M new markers
4. Commit updates **one-by-one**, each as a separate commit
5. Store results in Firestore

### 3. Daily Limit

* Max 500 commits per day
* Counter synced across devices

---

## 🔧 Setup

### Requirements

* Flutter SDK
* Firebase project
* GitHub OAuth App

### Steps

1. Clone repo
2. Add your `firebase_options.dart`
3. Add GitHub OAuth client ID + redirect URI
4. Run:

```bash
flutter pub get
flutter run
```

---

## 🔐 Security

* GitHub token stored **only** on-device
* Firestore stores metadata & history only

---

## 📝 License

MIT License © 2025
