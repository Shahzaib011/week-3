# Week 3: Task Manager App with Firebase Authentication

**Developed By:** M Shahzaib  
**GitHub:** https://github.com/Shahzaib011/week-3.git  
**LinkedIn:** https://www.linkedin.com/in/muhammad-shahzaib-0a4770312

---

## Project Description
A Flutter application that combines **task management** with **Firebase authentication**, demonstrating persistent storage, state management, and basic UI/UX features.

**Key Features:**
- **Splash Screen** on app launch
- **Authentication**:
    - Email/Password login & registration
    - Google login (Apple login can be added)
    - Auth persistence across app restarts
- **Home Screen**:
    - Add, edit, delete tasks
    - Set task time & date (tasks are daily-based)
    - View tasks for selected date using date picker
    - Mark tasks as complete
- **Persistent Storage** with `SharedPreferences` for tasks
- **Side Menu** (Drawer) with:
    - Profile section showing user name/email
    - Settings with dark mode toggle
    - Logout button
- **Responsive UI** with Material design

---

## Folder Structure

lib/
├── main.dart
    ├──Screens/
        ├── splash.dart
        ├── login.dart
        ├── register.dart
        ├── home.dart
        ├── profile.dart
        ├── setting.dart
    ├──services/
        ├── storage.dart
        ├──auth.dart
    ├──models/
        ├── task_model.dart
├──auth_wrapper.dart

---

## How to Run the Project

1. Install [Flutter SDK](https://flutter.dev/docs/get-started/install)
2. Clone the repository:
bash

git clone "https://github.com/Shahzaib011/week-3.git"
cd week-3

3. Install dependencies
    flutter pub get
    flutter run


## Requirements

        Flutter 3+

        Android Studio or VS Code

        Firebase project configured with your app

        Dart SDK

## Notes:

        Splash screen is included for UX enhancement.

        Firebase Authentication ensures that users stay logged in until they log out.

        Tasks are date-specific and persist locally.

## Firebase authentication.

        Google Sign-In is implemented; Apple Sign-In can be added for iOS.


