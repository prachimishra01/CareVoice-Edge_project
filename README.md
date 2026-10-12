# CareVoice Edge 🩺

> **Intelligent Edge-Assisted Patient Monitoring, Voice Reminders & Emergency Dispatch System**  
> *Developed for Flutter (Android) with a FastAPI + MongoDB Backend*

---

## Table of Contents
1. [Project Overview](#project-overview)
2. [Problem Statement & Motivation](#problem-statement--motivation)
3. [Project Objectives](#project-objectives)
4. [System Architecture](#system-architecture)
5. [Key Features & Modules](#key-features--modules)
   - [Verified & Implemented Features](#verified--implemented-features)
   - [Simulated, Demo & Planned Modules](#simulated-demo--planned-modules)
6. [Technology Stack](#technology-stack)
7. [Project Folder Structure](#project-folder-structure)
8. [Prerequisites & Software Requirements](#prerequisites--software-requirements)
9. [Step-by-Step Installation & Setup (Windows)](#step-by-step-installation--setup-windows)
   - [1. Backend Setup & Virtual Environment Activation](#1-backend-setup--virtual-environment-activation)
   - [2. MongoDB Database Connection & Verification](#2-mongodb-database-connection--verification)
   - [3. Starting the FastAPI Backend](#3-starting-the-fastapi-backend)
   - [4. Accessing Interactive API Documentation](#4-accessing-interactive-api-documentation)
10. [Configuring Backend API URL for a Physical Android Device](#configuring-backend-api-url-for-a-physical-android-device)
11. [Running the Flutter Application on an Android Phone](#running-the-flutter-application-on-an-android-phone)
12. [Troubleshooting & Known Limitations](#troubleshooting--known-limitations)
13. [Future Enhancements](#future-enhancements)
14. [Project Conclusion](#project-conclusion)

---

## Project Overview

**CareVoice Edge** is a comprehensive, mobile-first healthcare platform engineered to assist elderly individuals, recovering patients, and their caregivers. Operating directly on Android devices with support for edge voice interactions, the application integrates real-time vitals monitoring, an interactive patient AI companion, voice-driven medication reminders with audible confirmation tracking, and an automated emergency fall-detection dispatch workflow.

The project connects a modern, responsive **Flutter** front-end with an asynchronous **FastAPI** backend and a **MongoDB** data store, providing seamless telemetry, adherence logs, and alert dispatching even across local network environments.

---

## Problem Statement & Motivation

As the global population ages, millions of elderly individuals live independently or require round-the-clock home care. Caregivers face constant cognitive strain trying to ensure medications are taken on time, routine vitals remain within healthy parameters, and unexpected emergencies—such as falls or sudden acute distress—are addressed immediately.

Traditional reminder apps are passive, easy to dismiss, and lack feedback verification. Conversely, enterprise clinical systems are overly rigid, expensive, and difficult for non-technical seniors to navigate. 

**CareVoice Edge** addresses this gap by combining:
- **Auditory Guidance**: Speaking reminders out loud via Text-to-Speech (TTS).
- **Verbal Feedback**: Allowing patients to confirm adherence with spoken voice replies (Speech-to-Text).
- **Proactive Safety**: Triggering automatic visual and audio alarms with direct one-tap emergency calling when critical incidents occur.
- **Companion Support**: Providing a dedicated chatbot interface to offer guidance and reduce feelings of isolation.

---

## Project Objectives

1. **Active Medication Adherence**: Deliver proactive audio alerts and verify task completion through spoken patient confirmation.
2. **Comprehensive Vital Monitoring**: Display essential patient vitals, such as Heart Rate in BPM with clinical classification and pulse visualizers.
3. **Emergency Alert Dispatch**: Provide a countdown overlay and immediate telephone dialer dispatch to nominated caregivers.
4. **Accessible Patient Companion**: Deliver a clear, empathetic chat interface for patient questions, status checks, and wellness tips.
5. **Resilient Local Architecture**: Ensure continuous local functionality on real Android devices through configurable local network networking and fallback database mechanisms.

---

## System Architecture

The following diagram illustrates how the Flutter client, FastAPI backend, and MongoDB database interact:

```
┌───────────────────────────────────────────────────────────────┐
│             Physical Android Device / Emulator                │
│                                                               │
│   ┌───────────────────────────────────────────────────────┐   │
│   │                 CareVoice Edge (Flutter)              │   │
│   │                                                       │   │
│   │  • Dashboard Screen          • Patient Chatbot Screen │   │
│   │  • Heart Rate BPM Card       • Reminders & TTS/STT    │   │
│   │  • Camera Monitor Preview    • Emergency Alert Banner │   │
│   │  • Settings & Theme Engine   • Emergency Countdown    │   │
│   └──────────────────────────┬────────────────────────────┘   │
└──────────────────────────────┼────────────────────────────────┘
                               │
                HTTP REST (JSON) over Wi-Fi / LAN
           (Configurable: http://<PC_LAN_IP>:8000/api/v1)
                               │
                               ▼
┌───────────────────────────────────────────────────────────────┐
│                   Host PC (Windows / Linux)                   │
│                                                               │
│   ┌───────────────────────────────────────────────────────┐   │
│   │              FastAPI Backend (Port 8000)              │   │
│   │                                                       │   │
│   │  • /api/v1/patients          • /api/v1/activities     │   │
│   │  • /api/v1/reminders         • /api/v1/health-data    │   │
│   │  • /api/v1/emergency         • /api/v1/analytics      │   │
│   │  • /api/v1/alerts            • /api/v1/live-status    │   │
│   │  • Interactive Swagger Docs: /docs                    │   │
│   └──────────────────────────┬────────────────────────────┘   │
│                              │                                │
│            Async Motor Driver (Fallback: mongomock)           │
│                              │                                │
│                              ▼                                │
│   ┌───────────────────────────────────────────────────────┐   │
│   │         MongoDB Database: carevoice_test_db           │   │
│   │                                                       │   │
│   │  • users                     • reminders              │   │
│   │  • patients                  • activities             │   │
│   │  • health_data               • counters               │   │
│   └───────────────────────────────────────────────────────┘   │
└───────────────────────────────────────────────────────────────┘
```

### Communication Flow:
1. **Telemetry & Vitals**: The Flutter app polls or fetches patient vitals and activity history from `/api/v1/health-data` and `/api/v1/activities`.
2. **Reminders & Completions**: When a reminder triggers, TTS vocalizes it. If the patient responds, STT captures the text and posts completion data to `/api/v1/reminders/{id}/complete`.
3. **Emergency Escalation**: When triggered, the app registers an incident at `/api/v1/emergency/trigger` and displays the countdown overlay.
4. **Resilient Data Layer**: If MongoDB is active, data persists in `carevoice_test_db`. If MongoDB is unavailable, FastAPI automatically falls back to an in-memory mock (`mongomock_motor`), ensuring testing is never blocked.

---

## Key Features & Modules

### Verified & Implemented Features

| Feature / Module | Verification Source | Description |
| :--- | :--- | :--- |
| **Caretaker Dashboard** | [`lib/screens/dashboard_screen.dart`](file:///d:/carevoice_finalproject/lib/screens/dashboard_screen.dart) | Displays patient summary, live status badge, vital stat cards, and recent activity timeline. |
| **Heart Rate Card** | [`lib/widgets/heart_rate_card.dart`](file:///d:/carevoice_finalproject/lib/widgets/heart_rate_card.dart) | Visualizes patient heart rate in BPM with dynamic rhythm classification (Normal, Bradycardia, Elevated) and pulse animations. Clearly displays demo badge when offline. |
| **Patient AI Chatbot** | [`lib/screens/patient_chatbot_screen.dart`](file:///d:/carevoice_finalproject/lib/screens/patient_chatbot_screen.dart) | Dedicated chat screen with prompt chips (*"My Heart Rate status"*, *"When is my next medicine?"*, *"I feel dizzy / unwell"*, *"Hydration reminder"*), message bubbles, and typing indicators. |
| **Voice Reminders Loop** | [`lib/services/repeating_reminder_manager.dart`](file:///d:/carevoice_finalproject/lib/services/repeating_reminder_manager.dart) | Periodically evaluates due reminders and announces them aloud via local Text-to-Speech. |
| **Text-to-Speech (TTS)** | [`lib/services/tts_service.dart`](file:///d:/carevoice_finalproject/lib/services/tts_service.dart) | Integrated using `flutter_tts` for vocal reminder prompts and emergency alerts. |
| **Speech-to-Text (STT) & Mic Test** | [`lib/screens/settings_screen.dart`](file:///d:/carevoice_finalproject/lib/screens/settings_screen.dart) | Integrates `speech_to_text` to verify microphone hardware and capture spoken replies from the patient. |
| **Emergency Fall Alert Overlay** | [`lib/widgets/emergency_countdown_overlay.dart`](file:///d:/carevoice_finalproject/lib/widgets/emergency_countdown_overlay.dart) | Visual countdown with auditory alarm. If not cancelled within the window, initiates direct dialing. |
| **One-Tap Emergency Calling** | [`lib/services/emergency_manager.dart`](file:///d:/carevoice_finalproject/lib/services/emergency_manager.dart) | Uses `url_launcher` (`tel:`) to launch the phone dialer directly to the configured emergency contact. |
| **Patient Profile Management** | [`lib/screens/patient_profile_screen.dart`](file:///d:/carevoice_finalproject/lib/screens/patient_profile_screen.dart) | Allows editing patient demographics, room numbers, medical notes, and emergency phone numbers. |
| **Task History & Compliance** | [`lib/screens/task_history_screen.dart`](file:///d:/carevoice_finalproject/lib/screens/task_history_screen.dart) | Chronological log of reminder responses, completion times, and spoken transcripts. |
| **Dynamic Theme Engine** | [`lib/providers/theme_provider.dart`](file:///d:/carevoice_finalproject/lib/providers/theme_provider.dart) | Instant toggle between Light, Dark, and System modes with customized glassmorphism cards. |
| **In-App API URL Configuration** | [`lib/services/api_client.dart`](file:///d:/carevoice_finalproject/lib/services/api_client.dart) | Configurable base URL stored in `SharedPreferences`, editable directly from the Settings screen. |
| **FastAPI REST Endpoints** | [`backend/app/routes/`](file:///d:/carevoice_finalproject/backend/app/routes/) | Async endpoints for patients, activities, health data, alerts, analytics, reminders, and emergencies. |
| **In-Memory Fallback Database** | [`backend/app/database.py`](file:///d:/carevoice_finalproject/backend/app/database.py) | Connects to MongoDB, but seamlessly activates `mongomock_motor` if MongoDB is offline. Auto-seeds initial demo data. |

---

### Simulated, Demo & Planned Modules

To provide full clarity, the following components are currently demo, simulated, or scheduled for future iterations:

- **Heart Rate Sensor Feed**: The Heart Rate card in [`heart_rate_card.dart`](file:///d:/carevoice_finalproject/lib/widgets/heart_rate_card.dart) uses demo data (`74 BPM` baseline or server health record) until integrated with physical Bluetooth Low Energy (BLE) or wearable smartwatch hardware.
- **Camera Fall Detection AI**: The patient camera preview ([`patient_camera_monitor.dart`](file:///d:/carevoice_finalproject/lib/widgets/patient_camera_monitor.dart)) captures local phone camera video; automated computer-vision edge AI inferencing is simulated via scheduled API triggers.
- **Chatbot Intelligence Model**: The Patient Chatbot screen utilizes local clinical response patterns and symptom triage logic; integration with a dedicated cloud LLM endpoint is planned.
- **Raspberry Pi Subsystem**: External Raspberry Pi 5 hardware integration (Vosk offline, pyttsx3, OpenWakeWord) has been removed in favor of native mobile edge processing directly on Android.

---

## Technology Stack

### Frontend (Mobile App)
- **Framework**: Flutter SDK (^3.8.1)
- **Language**: Dart
- **State Management**: `provider` (^6.1.2)
- **Networking**: `http` (^1.2.2)
- **Local Storage**: `shared_preferences` (^2.3.3)
- **Voice & Speech**: `flutter_tts` (^4.2.0), `speech_to_text` (^7.0.0)
- **Hardware Integration**: `camera` (^0.11.0+2), `permission_handler` (^11.3.1)
- **Telephony & Links**: `url_launcher` (^6.3.1)
- **Data Visualization**: `fl_chart` (^0.69.2)
- **UI Animation & Styling**: `flutter_animate` (^4.5.2), Custom Glassmorphism

### Backend (REST API Server)
- **Framework**: FastAPI (>=0.110.0)
- **ASGI Server**: Uvicorn (>=0.28.0)
- **Language**: Python 3.10+
- **Data Validation & Settings**: Pydantic (>=2.6.4), Pydantic Settings (>=2.2.1)
- **Database Driver**: Motor (Async MongoDB, >=3.3.2), PyMongo (>=4.6.2)
- **Mock Fallback**: `mongomock-motor` (>=0.0.30)
- **Environment Management**: `python-dotenv` (>=1.0.1)

### Database
- **Primary Database**: MongoDB (Community Server 6.0+)
- **Database Name**: `carevoice_test_db`
- **Fallback Engine**: In-memory `mongomock_motor`

---

## Project Folder Structure

```
D:\carevoice_finalproject\
├── README.md                           # Master Project Documentation
├── pubspec.yaml                        # Flutter dependencies and asset configuration
├── build.gradle.kts                    # Root Gradle configuration
├── settings.gradle.kts                 # Root Gradle settings
│
├── lib/                                # Flutter application source code
│   ├── main.dart                       # App entry point, route definitions, provider setup
│   ├── models/                         # Data transfer objects and serialization
│   │   ├── analytics_summary.dart      # Task completion and adherence metrics
│   │   ├── emergency_event.dart        # Incident dispatch model
│   │   ├── health_data.dart            # Heart rate, SpO2, blood pressure records
│   │   ├── live_status.dart            # Edge connectivity and device telemetry
│   │   ├── patient.dart                # Patient demographic and medical information
│   │   ├── patient_activity.dart       # Activity timeline events (Walking, Sitting, etc.)
│   │   ├── reminder.dart               # Scheduled audio reminders
│   │   ├── task_completion.dart        # Spoken confirmation transcripts and latency
│   │   └── user.dart                   # Caretaker credentials and profile
│   ├── providers/                      # App state management
│   │   ├── auth_provider.dart          # Authentication session state
│   │   └── theme_provider.dart         # Theme mode (Light, Dark, System) manager
│   ├── screens/                        # User interface screens
│   │   ├── dashboard_screen.dart       # Main vitals and monitoring dashboard
│   │   ├── login_screen.dart           # Caretaker authentication screen
│   │   ├── patient_chatbot_screen.dart # Interactive patient AI assistant screen
│   │   ├── patient_profile_screen.dart # Patient medical record and contacts
│   │   ├── reminders_screen.dart       # Audio reminder management screen
│   │   ├── root_shell.dart             # Persistent bottom bar and navigation shell
│   │   ├── settings_screen.dart        # API base URL, theme, mic test, and calling settings
│   │   └── task_history_screen.dart    # Historical reminder compliance logs
│   ├── services/                       # Background services and networking
│   │   ├── api_client.dart             # HTTP client with persistent base URL
│   │   ├── emergency_manager.dart      # Fall detection alarm and telephone dialer
│   │   ├── repeating_reminder_manager.dart # Audio loop for due reminders
│   │   └── tts_service.dart            # Text-to-Speech synthesis service
│   ├── theme/                          # Design system
│   │   └── app_theme.dart              # Custom HSL palette, dark theme, and typography
│   └── widgets/                        # Modular reusable UI widgets
│       ├── active_repeating_reminder_banner.dart
│       ├── custom_nav_bar.dart         # Floating styled bottom navigation bar
│       ├── emergency_alert_banner.dart
│       ├── emergency_countdown_overlay.dart
│       ├── glass_card.dart             # Frosted-glass container widget
│       ├── heart_rate_card.dart        # BPM monitor card with rhythm status
│       ├── live_status_widget.dart
│       ├── patient_camera_monitor.dart # Real-time camera monitor preview
│       ├── patient_summary_widget.dart
│       ├── recent_patient_activity.dart
│       ├── reminder_modal.dart         # Modal sheet for creating/editing reminders
│       ├── stat_card.dart
│       └── tts_status_widget.dart
│
├── backend/                            # FastAPI backend server
│   ├── requirements.txt                # Python package dependencies
│   ├── .env                            # Active environment variables
│   ├── .env.example                    # Environment variable template
│   ├── venv_new/                       # Dedicated Python virtual environment
│   └── app/                            # Backend source code
│       ├── main.py                     # FastAPI application entry point and lifespan
│       ├── config.py                   # Pydantic BaseSettings configuration
│       ├── database.py                 # MongoDB connection, mock fallback, and seed data
│       ├── routes/                     # REST API route handlers
│       │   ├── activities.py           # /api/v1/activities
│       │   ├── alerts.py               # /api/v1/alerts
│       │   ├── analytics.py            # /api/v1/analytics
│       │   ├── auth.py                 # /api/v1/auth
│       │   ├── emergency.py            # /api/v1/emergency
│       │   ├── health_data.py          # /api/v1/health-data
│       │   ├── live_status.py          # /api/v1/live-status
│       │   ├── patients.py             # /api/v1/patients
│       │   └── reminders.py            # /api/v1/reminders
│       ├── schemas/                    # Pydantic request and response schemas
│       └── services/                   # Business logic and database operations
│
└── android/                            # Android native Gradle project configuration
```

---

## Prerequisites & Software Requirements

Before setting up the project on Windows, ensure the following tools are installed:

| Software | Required Version | Verification Command |
| :--- | :--- | :--- |
| **Windows OS** | Windows 10 or 11 (64-bit) | `winver` |
| **Python** | 3.10 or higher | `python --version` |
| **Flutter SDK** | 3.8.1 or higher | `flutter --version` |
| **Android Studio** | Ladybug (2024.2+) or newer | Launch Android Studio |
| **Java JDK** | JDK 17 or bundled Android Studio JBR | `java -version` |
| **MongoDB** | Community Server 6.0+ (Optional) | `mongod --version` |
| **Physical Android Phone**| Android 9.0 (API 28) or higher | Connected via USB Debugging |

---

## Step-by-Step Installation & Setup (Windows)

### 1. Backend Setup & Virtual Environment Activation

The project includes an existing, pre-configured virtual environment located at `D:\carevoice_finalproject\backend\venv_new`.

Open a **PowerShell** or **Command Prompt** terminal window:

```powershell
# Navigate to the backend directory
cd D:\carevoice_finalproject\backend

# In PowerShell:
.\venv_new\Scripts\Activate.ps1

# (Or in standard Command Prompt cmd.exe):
# .\venv_new\Scripts\activate.bat
```

> **PowerShell Script Execution Note:** If PowerShell displays an execution policy error, enable local script execution for the current session:
> ```powershell
> Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
> .\venv_new\Scripts\Activate.ps1
> ```

Verify that your terminal prompt shows `(venv_new)`. If you ever need to re-install or verify dependencies:
```powershell
pip install -r requirements.txt
```

---

### 2. MongoDB Database Connection & Verification

The backend uses MongoDB for persistent records.

* **Connection URI:** `mongodb://localhost:27017`
* **Target Database:** `carevoice_test_db`

#### Starting MongoDB Locally
If MongoDB is installed as a Windows Service, it starts automatically on port `27017`. Otherwise, run:
```powershell
mongod --dbpath="C:\data\db"
```

#### Collections Created by CareVoice:
When the server starts for the first time, [`backend/app/database.py`](file:///d:/carevoice_finalproject/backend/app/database.py) automatically inspects the database and seeds initial records into the following collections:
- `users`: Caretaker accounts and authentication records.
- `patients`: Patient profiles (e.g., *Eleanor Vance*, age 78, room 302B).
- `reminders`: Scheduled medication and hydration tasks.
- `activities`: Timestamped patient movement logs (*Walking*, *Sitting*, *Medicine Taken*).
- `health_data`: Historical vital readings (Heart Rate, SpO2, Temperature, Blood Pressure).
- `counters`: Atomic integer sequence counters for auto-incrementing record IDs.

> **Automatic Fallback:** If you do not have MongoDB running locally, **do not worry**. The backend will automatically detect that port 27017 is unavailable, initialize an in-memory database mock using `mongomock_motor`, seed the demo data, and print:
> `In-memory MongoDB mock database is active.`

---

### 3. Starting the FastAPI Backend

With `venv_new` activated and inside `D:\carevoice_finalproject\backend`, start the server:

```powershell
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

* `--host 0.0.0.0` ensures the server listens on **all network interfaces**, allowing physical Android phones on your local Wi-Fi network to connect.
* `--port 8000` starts the API on port `8000`.
* `--reload` enables live-reload upon any code changes.

Once running, you will see:
```text
INFO:     Application startup complete.
INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
```

---

### 4. Accessing Interactive API Documentation

Open your browser to explore and test the endpoints directly:
* **Interactive Swagger UI:** [http://localhost:8000/docs](http://localhost:8000/docs)
* **ReDoc Specification:** [http://localhost:8000/redoc](http://localhost:8000/redoc)
* **API Health Check:** [http://localhost:8000/health](http://localhost:8000/health)

---

## Configuring Backend API URL for a Physical Android Device

> **CRITICAL NETWORKING CONCEPT:**  
> When testing on a real Android phone, `localhost` or `127.0.0.1` refers to the **phone itself**, NOT your computer. To connect your phone to the backend running on your PC, you must point the app to your computer's **Local Area Network (LAN) IPv4 address**.

### Step 1: Find Your Computer's LAN IP Address
1. Open a new terminal on your Windows computer.
2. Run:
   ```cmd
   ipconfig
   ```
3. Locate your active network adapter (e.g., **Wireless LAN adapter Wi-Fi**).
4. Find the **IPv4 Address** (for example: `192.168.1.45` or `10.91.188.174`).
5. Ensure your Android phone is connected to the **exact same Wi-Fi network**.

### Step 2: Configure the URL in the App (Two Methods Available)

#### Method A: Inside the App UI (Recommended — No Code Changes)
1. Open the CareVoice app on your Android phone.
2. Navigate to **Settings** (gear icon on the bottom navigation bar).
3. Scroll to the **Backend API Connection** card.
4. In the **API Base URL** text box, enter:
   ```text
   http://<YOUR_COMPUTER_IPV4_ADDRESS>:8000/api/v1
   ```
   *(Example: `http://192.168.1.45:8000/api/v1`)*
5. Tap **Save Base URL**. The URL is saved immediately to device storage (`SharedPreferences`) and persists across app restarts.

#### Method B: In Code Default Configuration
If you want to change the fallback default before building the app, open [`lib/services/api_client.dart`](file:///d:/carevoice_finalproject/lib/services/api_client.dart) and update line 20:
```dart
static const String defaultBaseUrl = 'http://<YOUR_COMPUTER_IPV4_ADDRESS>:8000/api/v1';
```

---

## Running the Flutter Application on an Android Phone

### Step 1: Enable USB Debugging on Your Android Phone
1. Open **Settings** > **About Phone**.
2. Tap **Build Number** 7 times until Developer Mode is unlocked.
3. Open **Settings** > **Developer Options** and turn ON **USB Debugging**.
4. Connect the phone to your Windows PC using a USB data cable.
5. Accept the prompt on your phone screen: *"Allow USB debugging from this computer?"*.

### Step 2: Set PUB_CACHE Environment Variable (Prevents Cross-Drive Errors)
Because this project is on drive `D:\`, configure Flutter to keep downloaded packages on drive `D:\`:
```powershell
$env:PUB_CACHE = "D:\PubCache"
```
*(To make this permanent on Windows, add `PUB_CACHE` with value `D:\PubCache` to your User Environment Variables in Windows Settings).*

### Step 3: Verify the Connected Device
In your terminal:
```powershell
cd D:\carevoice_finalproject
flutter devices
```
You should see your physical Android phone listed (e.g., `CPH2269 • 0123456789 • android-arm64 • Android 12`).

### Step 4: Run the Application
Ensure the backend server is running in terminal 1, then launch the app in terminal 2:
```powershell
flutter run -d <DEVICE_ID>
```
*(Or simply run `flutter run` if only one device is connected).*

Flutter will compile the Android APK and deploy it directly to your phone screen.

---

## Troubleshooting & Known Limitations

### 1. Cross-Drive Gradle Error (`this and base files have different roots`)
* **Cause**: Flutter installed packages on drive `C:\` while your project resides on `D:\`.
* **Fix**: Ensure `PUB_CACHE=D:\PubCache` is set in your environment variables, then execute `flutter pub get`.

### 2. SocketException / Connection Refused (`errno = 111` or `errno = 113`)
* **Cause**: The phone cannot reach the PC's IP address.
* **Checks**:
  1. Verify the backend is actively running (`python -m uvicorn app.main:app ...`).
  2. Confirm both the PC and phone are on the **same Wi-Fi network**.
  3. Ensure Windows Defender Firewall is not blocking incoming connections on port `8000`. You can allow port 8000 by running PowerShell as Administrator:
     ```powershell
     New-NetFirewallRule -DisplayName "FastAPI Port 8000" -Direction Inbound -LocalPort 8000 -Protocol TCP -Action Allow
     ```

### 3. Microphone or Speech-to-Text Fails on Device
* **Cause**: Android runtime permission not granted.
* **Fix**: When opening the Settings screen and tapping **Test Mic**, tap **Allow** when the system prompt asks for Microphone access. Alternatively, grant it manually under phone **Settings > Apps > CareVoice Edge > Permissions**.

### 4. Duplicate Gradle Plugin Declaration Error
* **Resolved**: Any duplicate plugin requests in `build.gradle.kts` have been cleaned up to maintain Gradle DSL compliance.



---

## Project Conclusion

**CareVoice Edge** bridges the gap between passive health applications and active, compassionate caregiving. By uniting real-time patient metrics, audible reminder loops, quick emergency dispatch, and conversational companionship into a single accessible mobile platform, the application empowers patients with greater autonomy while giving caregivers indispensable peace of mind.
