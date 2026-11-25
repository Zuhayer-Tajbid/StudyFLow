from fastapi.testclient import TestClient
from app.main import app, storage
from unittest.mock import Mock

client = TestClient(app)

class FakeStorage:
    def __init__(self):
        self.data = {"courses": [], "tasks": [], "sessions": [], "next_course_id": 1, "next_task_id": 1, "next_session_id": 1}
    def load(self):
        return self.data
    def save(self, data):
        self.data = data

def test_create_task_and_dashboard(monkeypatch):
    fake = FakeStorage()
    monkeypatch.setattr("app.main.storage", fake)
    response = client.post("/tasks", json={"title":"Test task", "course":"CSE", "due_date":"2026-12-01", "priority":"High", "kind":"assignment"})
    assert response.status_code == 200
    assert response.json()["title"] == "Test task"
    assert client.get("/dashboard").json()["total"] == 1

def test_task_not_found(monkeypatch):
    fake = FakeStorage()
    monkeypatch.setattr("app.main.storage", fake)
    response = client.put("/tasks/999/toggle")
    assert response.status_code == 404
