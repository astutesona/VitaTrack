# VitaTrack – Personal Health & Wellness Tracker 🌿

**Academic MCA Capstone Project | Advanced Mobile Application Development (AMAD)**  
*Student / Developer:* Sonali Kumari  
*Target Platform:* Android Mobile Application  
*Framework:* Flutter 3.47+ (Dart 3.13+)  

---

## 📱 Project Overview

**VitaTrack** is a modern, responsive, and database-connected personal health and wellness tracker built for Android mobile devices. Designed around clean architecture and Material 3 design principles, the application provides an all-in-one ecosystem for users to monitor their physical activity, track hydration levels, record sleep schedules, manage workout routines, receive timely health reminders, and analyze long-term wellness trends using interactive data visualizations.

---

## 🌟 Advanced Mobile Application Development (AMAD) Concepts Implemented

VitaTrack demonstrates comprehensive practical implementation of core MCA-level mobile concepts:

1. **Declarative Navigation & Dynamic Routing:**
   - Multi-tab bottom navigation with `NavigationBar` (Home, Activity, Workouts, Progress, Profile).
   - `IndexedStack` preservation pattern preventing tab re-render loss.
   - Declarative named routing (`/`, `/login`, `/register`, `/home`, `/reminders`) with authentication route guards.

2. **Mobile Authentication & Session Persistence:**
   - Firebase Authentication with email & password verification, sign-in, account creation, and password reset flows.
   - Persistent user authentication caching via `SharedPreferences`.
   - Automatic session checking on app launch via an animated branding Splash Screen.
   - Zero-crash fallback engine ensuring seamless functionality both with cloud credentials and in offline demo evaluation modes.

3. **Cloud Database & Offline Synchronization:**
   - Google Cloud Firestore integration with strict user isolation (`users`, `health_records`, `workouts`, `reminders`).
   - Local-first cache pattern: Reads and writes are cached locally in JSON format, ensuring 100% offline persistence and instant UI responsiveness.

4. **Hardware Sensor Integration & Fallback:**
   - Android Pedometer hardware step sensor integration (`pedometer` plugin) with `Permission.activityRecognition` runtime permission requests.
   - Real-time sensor stream listener calculating delta steps since midnight.
   - Full manual step entry fallback dialog ensuring evaluation works on emulators without physical step counter sensors.

5. **Scheduled Local Notifications & Background Reminders:**
   - Android Notification Channels (`vitatrack_reminders`) with High Importance and custom vibration patterns.
   - Configurable alarms for Hydration, Walking/Inactivity, and Sleep Schedules.
   - Android 13+ `POST_NOTIFICATIONS` runtime permission handling.
   - Instant verification trigger for testing notifications during examiner evaluation.

6. **Interactive Data Visualization & Charts:**
   - Interactive `fl_chart` Bar Charts for 7-day step volume with goal lines and tooltips.
   - Weekly water intake volume charts (ml).
   - Sleep duration trend charts (hours/night).
   - Workout activity distribution breakdowns.
   - Real-time arithmetic goal completion percentage calculations.

7. **Material 3 Design System & Responsive UI:**
   - Healthcare palette featuring Teal (`#0D9488`), Emerald Green (`#10B981`), Mint (`#CCFBF1`), and Soft Slate backgrounds (`#F8FAFC`).
   - Rounded card architecture with subtle elevation shadows.
   - Form input validation, password obscurity toggles, and contextual SnackBar alerts.
   - Dynamic Body Mass Index (BMI) calculator with health category badges (Underweight, Normal weight, Overweight, Obese).

---

## 🏗️ Clean Project Architecture

```
lib/
├── main.dart                       # App entry point, MultiProvider setup & Firebase initialization
├── models/
│   ├── user_profile.dart           # User data model & BMI calculation logic
│   ├── health_record.dart          # Daily health metrics (steps, water, sleep) & drink logs
│   ├── workout.dart                # Exercise entity with MET-based calorie estimation
│   └── reminder_model.dart         # Notification reminder model with time & status
├── services/
│   ├── auth_service.dart           # Firebase Auth + local session caching
│   ├── database_service.dart       # Cloud Firestore CRUD operations + local JSON cache
│   ├── notification_service.dart   # FlutterLocalNotificationsPlugin scheduling & channels
│   └── step_counter_service.dart   # Pedometer stream listener & permission handling
├── providers/
│   ├── auth_provider.dart          # Authentication state management
│   ├── health_provider.dart        # Steps, water, sleep & daily goal progress state
│   ├── workout_provider.dart       # Workout history, weekly goals & calorie totals
│   └── reminder_provider.dart      # Notification schedules, toggles & tests
├── widgets/
│   ├── metric_card.dart            # Rounded metric dashboard card with mini progress bar
│   ├── circular_goal_indicator.dart# Daily goal completion percentage ring banner
│   ├── quick_add_button.dart       # Pill action buttons (+250 ml, Log Steps, etc.)
│   ├── custom_text_field.dart      # Material 3 validated text input field
│   ├── custom_button.dart          # Primary/Secondary button with loading state
│   ├── workout_card.dart           # Activity log list item with delete capability
│   └── empty_state_view.dart       # Clean placeholder view for empty lists
├── screens/
│   ├── splash_screen.dart          # Animated branding splash screen with session check
│   ├── main_navigation_screen.dart # Bottom Navigation bar controller with 5 tabs
│   ├── auth/
│   │   ├── login_screen.dart       # Sign-in with form validation & demo one-click fill
│   │   └── register_screen.dart    # Account creation & initial wellness profile setup
│   ├── home/
│   │   └── dashboard_screen.dart   # Personalized dashboard with daily metrics & quick actions
│   ├── activity/
│   │   └── activity_screen.dart    # Steps, Water fill bottle & Sleep duration calculation
│   ├── workouts/
│   │   └── workouts_screen.dart    # Exercise logger, weekly goals & workout history
│   ├── progress/
│   │   └── progress_screen.dart    # Interactive fl_chart visualizations & trends
│   ├── profile/
│   │   └── profile_screen.dart     # Physical stats, live BMI calculator & target settings
│   └── reminders/
│       └── reminders_screen.dart   # Water, Walking & Sleep notification configuration
├── utils/
│   └── date_formatter.dart         # Standardized date, time, and duration formatting
└── theme/
    └── app_theme.dart              # Material 3 colors, typography, and card decorations
```

---

## 🗄️ Cloud Firestore Database Structure

The application integrates with Google Cloud Firestore using the following collections and schemas:

### 1. `users` Collection
- **Document ID:** `{userId}`
- **Fields:**
  - `userId` (String): Unique identifier from Firebase Auth
  - `name` (String): Full user display name
  - `email` (String): User email address
  - `createdAt` (String / Timestamp): Account creation timestamp
  - `stepGoal` (int): Target daily steps (e.g. `8000`)
  - `waterGoalMl` (int): Target daily water consumption in ml (e.g. `2500`)
  - `sleepGoalHours` (double): Target sleep duration in hours (e.g. `8.0`)
  - `workoutGoalMinutes` (int): Weekly active workout target (e.g. `150`)
  - `heightCm` (double): Height in centimeters for BMI (e.g. `170.0`)
  - `weightKg` (double): Weight in kilograms for BMI (e.g. `68.0`)

### 2. `health_records` Collection
- **Document ID:** `{userId}_{YYYY-MM-DD}`
- **Fields:**
  - `id` (String): Composite document ID
  - `userId` (String): Owner user ID
  - `date` (String): ISO date string (`YYYY-MM-DD`)
  - `steps` (int): Steps recorded today
  - `waterIntake` (int): Total water consumed today (ml)
  - `sleepDuration` (double): Sleep duration in hours
  - `sleepStartTime` (String): e.g. `"11:00 PM"`
  - `sleepEndTime` (String): e.g. `"07:00 AM"`
  - `sleepQuality` (String): `"Deep" | "Light" | "Restless"`
  - `waterLogs` (Array of Objects): `[{"id": "...", "amountMl": 250, "timestamp": "..."}]`
  - `updatedAt` (String / Timestamp): Last update timestamp

### 3. `workouts` Collection
- **Document ID:** `{workoutId}`
- **Fields:**
  - `workoutId` (String): UUID of the workout
  - `userId` (String): Owner user ID
  - `workoutType` (String): `"Walking" | "Running" | "Cycling" | "Yoga" | "Strength Training" | "Other Activities"`
  - `duration` (int): Active workout time in minutes
  - `workoutDate` (String / Timestamp): Timestamp of workout session
  - `caloriesBurned` (int): Estimated or entered calories burned
  - `notes` (String): User workout notes

### 4. `reminders` Collection
- **Document ID:** `{reminderId}`
- **Fields:**
  - `reminderId` (String): Identifier
  - `userId` (String): Owner user ID
  - `reminderType` (String): `"Water" | "Walking" | "Sleep"`
  - `reminderTime` (String): Time string (`"09:00"`, `"14:30"`, `"22:30"`)
  - `isEnabled` (bool): `true` if notification schedule is active
  - `title` (String): Notification title
  - `message` (String): Notification body content
  - `notificationId` (int): Unique integer ID used for Android alarms

---

## ⚙️ Android Configuration & Permissions

File: `android/app/src/main/AndroidManifest.xml`
```xml
<!-- Network for Firebase Auth & Firestore -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

<!-- Sensor for Step Counting -->
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />

<!-- Local Notifications (Android 13+) -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
```

File: `android/app/build.gradle.kts`
- `minSdk = 23`
- `multiDexEnabled = true`
- `targetSdk = flutter.targetSdkVersion`

---

## 🚀 How to Run the Application

### Prerequisites
- Flutter SDK 3.19+ or 3.47+ installed and configured on your PATH.
- Android Studio with an Android Emulator (API 26+) or a physical Android smartphone with USB debugging enabled.

### Step 1: Open the Project Directory
```powershell
cd c:\Users\astut\Desktop\AMAD_Project
```

### Step 2: Fetch Packages
```powershell
flutter pub get
```

### Step 3: Run Static Analysis & Verification
```powershell
flutter analyze
flutter test
```

### Step 4: Launch on Android Emulator or Physical Device
```powershell
# List available emulators
flutter emulators

# Launch an Android emulator (e.g., Pixel 7 Pro)
flutter emulators --launch Pixel_7_Pro

# Run the application
flutter run
```

---

## 🔑 Firebase Cloud Setup Instructions (Optional for Live Production)

The app is fully self-contained and functions in offline-first mode out of the box. To connect your own live Firebase project:

1. Open the [Firebase Console](https://console.firebase.google.com/) and click **Add Project**.
2. Name the project `vitatrack-app`.
3. Add an **Android app** with package name `com.vitatrack.app.vitatrack`.
4. Download the generated `google-services.json` and place it in `android/app/google-services.json`.
5. Enable **Email/Password** authentication under *Firebase Authentication -> Sign-in method*.
6. Create a **Cloud Firestore Database** under *Build -> Firestore Database* with standard read/write security rules for authenticated users:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

## 🧪 Testing Credentials for Evaluation

For rapid evaluation and viva demonstration, one-click demo credentials are built directly into the login screen:
- **Email:** `sonali@gmail.com`
- **Password:** `vitapass123`
- Or click the **"Auto-fill Demo Credentials"** button on the Login Screen.
- Alternatively, test user registration with any custom email and password.
