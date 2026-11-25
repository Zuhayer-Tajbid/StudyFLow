
import pytest
from fastapi.testclient import TestClient
from app.main import app


class FakeStorage:
    def __init__(self):
        self.data = {
            "courses": [],
            "tasks": [],
            "sessions": [],
            "next_course_id": 1,
            "next_task_id": 1,
            "next_session_id": 1
        }

    def load(self):
        return self.data

    def save(self, data):
        self.data = data


@pytest.fixture
def fake_storage():
    return FakeStorage()


@pytest.fixture
def client(fake_storage, monkeypatch):
    monkeypatch.setattr("app.main.storage", fake_storage)

    with TestClient(app) as test_client:
        yield test_client
