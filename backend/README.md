# CareVoice-Edge FastAPI Backend

FastAPI + MongoDB backend for the **CareVoice-Edge** Flutter application. Provides patient profile management, daily voice reminder scheduling, speech confirmation tracking, patient activity logging, health vitals monitoring, and emergency fall detection event handling.

---

## Features

1. **Patient Management**: Full CRUD for patient demographic, medical conditions, and emergency contact details.
2. **Activity Management**: Log and query patient activities (`Walking`, `Sitting`, `Standing`, `Lying`, `Fall Detected`) with time filtering.
3. **Health Data Monitoring**: Store and retrieve patient vitals (heart rate, SpO2, body temperature, blood pressure).
4. **Reminders & Voice Loop**: Schedule recurring audio reminders, trigger announcements, and record spoken patient confirmations.
5. **Alerts & Emergency Events**: Record fall detection alerts, voice SOS triggers, and caretaker resolution notes.
6. **Analytics & Live Status**: Adherence percentages, task completion breakdowns, and real-time edge device status.
7. **Interactive Documentation**: Built-in interactive Swagger UI at `/docs`.

---

## Project Structure

```
backend/
├── app/
│   ├── main.py                  # FastAPI entry point, CORS, lifespan
│   ├── config.py                # Pydantic configuration & .env loader
│   ├── database.py              # MongoDB connection & auto-seeding
│   ├── schemas/                 # Pydantic request/response models
│   │   ├── user.py
│   │   ├── patient.py
│   │   ├── reminder.py
│   │   ├── activity.py
│   │   ├── health_data.py
│   │   ├── emergency.py
│   │   ├── analytics.py
│   │   └── live_status.py
│   ├── routes/                  # REST API endpoints
│   │   ├── auth.py
│   │   ├── patients.py
│   │   ├── reminders.py
│   │   ├── activities.py
│   │   ├── health_data.py
│   │   ├── emergency.py
│   │   ├── analytics.py
│   │   └── live_status.py
│   └── services/                # Business logic & database operations
│       ├── patient_service.py
│       ├── reminder_service.py
│       ├── activity_service.py
│       ├── health_data_service.py
│       ├── emergency_service.py
│       ├── analytics_service.py
│       └── live_status_service.py
├── .env                         # Active configuration
├── .env.example                 # Example template
├── requirements.txt             # Python dependencies
└── README.md
```

---

## Setup & Running the Server

### 1. Prerequisites
- Python 3.10+
- (Optional) Local MongoDB or MongoDB Atlas free cluster

### 2. Install Dependencies
```bash
cd backend
python -m venv venv
# Windows:
.\venv\Scripts\activate
# macOS/Linux:
source venv/bin/activate

pip install -r requirements.txt
```

### 3. Configure Environment Variables
Copy `.env.example` to `.env`:
```bash
cp .env.example .env
```

Edit `.env` to configure your MongoDB URL:
- **Local MongoDB**: `MONGODB_URL=mongodb://localhost:27017`
- **MongoDB Atlas Cloud**: `MONGODB_URL=mongodb+srv://<username>:<password>@cluster0.mongodb.net/?retryWrites=true&w=majority`

> **Note**: If MongoDB is not running locally, the server automatically initializes an in-memory database mock so you can immediately test and demonstrate the application.

### 4. Start the FastAPI Server
```bash
# From the backend directory:
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

Server will start on:
- **API URL**: `http://localhost:8000`
- **Swagger Interactive Docs**: `http://localhost:8000/docs`
- **ReDoc**: `http://localhost:8000/redoc`

---

## Connecting Flutter to the Backend

The Flutter application connects to the backend using [lib/services/api_client.dart](file:///d:/Flutter_app%20-%20Copy/lib/services/api_client.dart).

- **Android Emulator**: Uses `http://10.0.2.2:8000/api/v1` (default)
- **Windows / Web / iOS Simulator**: Set to `http://localhost:8000/api/v1` in the app's Settings screen
- **Physical Phone**: Set to your computer's LAN IP, e.g. `http://192.168.1.50:8000/api/v1`
