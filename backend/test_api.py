import asyncio
import httpx
from app.database import connect_to_database, close_database_connection
from app.main import app


async def run_tests():
    print("=" * 60)
    print("Testing CareVoice-Edge FastAPI + MongoDB Backend Endpoints")
    print("=" * 60)

    # Initialize database connection and seed data
    await connect_to_database()

    transport = httpx.ASGITransport(app=app)
    try:
        async with httpx.AsyncClient(transport=transport, base_url="http://testserver") as client:
            # 1. System Endpoints
            res = await client.get("/")
            assert res.status_code == 200, f"Root failed: {res.text}"
            print(" [PASS] GET / -> Root pointer")

            res = await client.get("/health")
            assert res.status_code == 200, f"Health check failed: {res.text}"
            health_data = res.json()
            print(f" [PASS] GET /health -> status={health_data['status']}, db={health_data['database']}")

            # 2. Auth Endpoint
            res = await client.get("/api/v1/auth/me")
            assert res.status_code == 200, f"Auth failed: {res.text}"
            user = res.json()
            assert user["role"] == "caretaker"
            print(f" [PASS] GET /api/v1/auth/me -> user={user['full_name']} ({user['email']})")

            # 3. Patient Management (Create, Read, Update, Delete)
            res = await client.get("/api/v1/patients")
            assert res.status_code == 200
            patients = res.json()
            assert len(patients) >= 1
            print(f" [PASS] GET /api/v1/patients -> found {len(patients)} patient(s)")

            p1 = patients[0]
            res = await client.get(f"/api/v1/patients/{p1['id']}")
            assert res.status_code == 200
            assert res.json()["full_name"] == p1["full_name"]
            print(f" [PASS] GET /api/v1/patients/{p1['id']} -> {p1['full_name']}")

            # Create patient
            new_p = {
                "full_name": "Clara Oswald",
                "age": 74,
                "room_number": "204A",
                "medical_conditions": "Type 2 Diabetes, Mild Osteoarthritis",
                "emergency_contact": "+1 (555) 432-8765",
                "notes": "Monitor evening glucose levels.",
                "summary": "Independent mobility, dietary routine required.",
            }
            res = await client.post("/api/v1/patients", json=new_p)
            assert res.status_code == 201
            created_patient = res.json()
            created_pid = created_patient["id"]
            print(f" [PASS] POST /api/v1/patients -> created patient ID {created_pid}")

            # Update patient
            res = await client.put(f"/api/v1/patients/{created_pid}", json={"room_number": "204B"})
            assert res.status_code == 200
            assert res.json()["room_number"] == "204B"
            print(f" [PASS] PUT /api/v1/patients/{created_pid} -> updated room to 204B")

            # Delete patient
            res = await client.delete(f"/api/v1/patients/{created_pid}")
            assert res.status_code == 200
            print(f" [PASS] DELETE /api/v1/patients/{created_pid} -> deleted successfully")

            # 4. Reminders Management (Create, Read, Update, Delete, Complete)
            res = await client.get("/api/v1/reminders")
            assert res.status_code == 200
            reminders = res.json()
            assert len(reminders) >= 1
            print(f" [PASS] GET /api/v1/reminders -> found {len(reminders)} reminder(s)")

            r1 = reminders[0]
            res = await client.get(f"/api/v1/reminders/{r1['id']}")
            assert res.status_code == 200
            print(f" [PASS] GET /api/v1/reminders/{r1['id']} -> {r1['title']}")

            # Create reminder
            new_rem = {
                "patient_id": 1,
                "title": "Evening Walk & Posture Exercise",
                "category": "exercise",
                "scheduled_time": "18:00",
                "repeat_days": "daily",
                "is_active": True,
                "audio_prompt": "Time for your 15-minute gentle walk in the garden corridor.",
                "max_retries": 2,
            }
            res = await client.post("/api/v1/reminders", json=new_rem)
            assert res.status_code == 201
            created_rem = res.json()
            created_rem_id = created_rem["id"]
            print(f" [PASS] POST /api/v1/reminders -> created reminder ID {created_rem_id}")

            # Update reminder
            res = await client.put(f"/api/v1/reminders/{created_rem_id}", json={"is_active": True, "max_retries": 4})
            assert res.status_code == 200
            assert res.json()["max_retries"] == 4
            print(f" [PASS] PUT /api/v1/reminders/{created_rem_id} -> updated max_retries to 4")

            # Announce reminder
            res = await client.post(f"/api/v1/reminders/{created_rem_id}/announce")
            assert res.status_code == 200
            print(f" [PASS] POST /api/v1/reminders/{created_rem_id}/announce")

            # Complete reminder via REST endpoint
            complete_payload = {
                "status": "completed",
                "notes": "Patient completed walking exercise accompanied by caretaker.",
                "patient_speech": "I have finished my walk",
                "response_time_seconds": 8.2,
            }
            res = await client.post(f"/api/v1/reminders/{created_rem_id}/complete", json=complete_payload)
            assert res.status_code == 200
            assert res.json()["status"] == "completed"
            print(f" [PASS] POST /api/v1/reminders/{created_rem_id}/complete -> completed verified")

            # Confirm voice
            res = await client.post("/api/v1/reminders/confirm-voice", json={
                "reminder_id": created_rem_id,
                "patient_speech": "Yes, medicine taken with water",
            })
            assert res.status_code == 200
            print(f" [PASS] POST /api/v1/reminders/confirm-voice -> {res.json()['status']}")

            # Delete test reminder
            res = await client.delete(f"/api/v1/reminders/{created_rem_id}")
            assert res.status_code == 200
            print(f" [PASS] DELETE /api/v1/reminders/{created_rem_id} -> deleted successfully")

            # 5. Patient Activity Management
            for act_name in ["Walking", "Sitting", "Standing", "Lying", "Fall Detected"]:
                act_data = {
                    "patient_id": 1,
                    "activity_type": act_name,
                    "status": "Normal" if act_name != "Fall Detected" else "Alert Triggered",
                    "details": f"Patient state recorded as {act_name}",
                    "timestamp": "Just now",
                }
                res = await client.post("/api/v1/activities", json=act_data)
                assert res.status_code == 201
                logged_act = res.json()
            print(" [PASS] POST /api/v1/activities -> successfully stored Walking, Sitting, Standing, Lying, Fall Detected")

            res = await client.get("/api/v1/activities?patient_id=1&limit=10")
            assert res.status_code == 200
            assert len(res.json()) >= 5
            print(f" [PASS] GET /api/v1/activities -> retrieved {len(res.json())} activity records")

            res = await client.get("/api/v1/activities/recent?limit=5")
            assert res.status_code == 200
            print(f" [PASS] GET /api/v1/activities/recent -> {len(res.json())} recent records")

            # 6. Health Data & Vitals (Heart rate, SpO2, Temperature)
            vitals = {
                "patient_id": 1,
                "heart_rate": 74.0,
                "spo2": 98.5,
                "temperature": 36.7,
                "systolic_bp": 119,
                "diastolic_bp": 79,
                "status": "Normal",
            }
            res = await client.post("/api/v1/health-data", json=vitals)
            assert res.status_code == 201
            created_vital = res.json()
            vital_id = created_vital["id"]
            print(f" [PASS] POST /api/v1/health-data -> HR={created_vital['heart_rate']}, SpO2={created_vital['spo2']}%, Temp={created_vital['temperature']}°C")

            res = await client.get("/api/v1/health-data/latest?patient_id=1")
            assert res.status_code == 200
            assert res.json()["heart_rate"] == 74.0
            print(" [PASS] GET /api/v1/health-data/latest -> latest vitals verified")

            res = await client.get(f"/api/v1/health-data/{vital_id}")
            assert res.status_code == 200
            print(f" [PASS] GET /api/v1/health-data/{vital_id} -> retrieved by ID")

            # 7. Alerts & Fall Detection Management
            alert_payload = {
                "patient_id": 1,
                "alert_type": "Fall Alert",
                "message": "Optical sensor detected sudden fall in living room area",
                "details": "Patient on floor near table",
                "status": "active",
            }
            res = await client.post("/api/v1/alerts", json=alert_payload)
            assert res.status_code == 201
            created_alert = res.json()
            alert_id = created_alert["id"]
            assert created_alert["alert_type"] == "Fall Alert"
            assert created_alert["status"] == "active"
            print(f" [PASS] POST /api/v1/alerts -> created {created_alert['alert_type']} ID {alert_id}")

            res = await client.get("/api/v1/alerts?status=active")
            assert res.status_code == 200
            assert len(res.json()) >= 1
            print(f" [PASS] GET /api/v1/alerts -> {len(res.json())} active alert(s)")

            res = await client.put(f"/api/v1/alerts/{alert_id}/resolve", json={"notes": "Nurse arrived, patient assisted safely."})
            assert res.status_code == 200
            assert res.json()["status"] == "resolved"
            print(f" [PASS] PUT /api/v1/alerts/{alert_id}/resolve -> marked resolved")

            # Verify existing /emergency compatibility
            res = await client.get("/api/v1/emergency")
            assert res.status_code == 200
            print(f" [PASS] GET /api/v1/emergency -> compatibility verified ({len(res.json())} events)")

            # 8. Analytics & Live Status
            res = await client.get("/api/v1/analytics")
            assert res.status_code == 200
            an = res.json()
            assert "completion_rate_percentage" in an
            assert "category_breakdown" in an
            print(f" [PASS] GET /api/v1/analytics -> compliance={an['completion_rate_percentage']}%, categories={len(an['category_breakdown'])}")

            res = await client.get("/api/v1/live-status")
            assert res.status_code == 200
            ls = res.json()
            assert "current_reminder" in ls
            assert "device_status" in ls
            print(f" [PASS] GET /api/v1/live-status -> device_status={ls['device_status']['system_status']}")

        print("\n" + "=" * 60)
        print("ALL BACKEND API TESTS PASSED SUCCESSFULLY! (100% PASS)")
        print("=" * 60)
    finally:
        await close_database_connection()


if __name__ == "__main__":
    asyncio.run(run_tests())
