import json
from pathlib import Path
from typing import Any

DATA_FILE = Path(__file__).resolve().parent.parent / "data.json"

INITIAL_DATA = {
    "courses": [
        {"id": 1, "name": "Software Engineering"},
        {"id": 2, "name": "Artificial Intelligence"},
        {"id": 3, "name": "Computer Networks"},
        {"id": 4, "name": "Database Systems"},
    ],
    "tasks": [
        {"id": 1, "title": "Write SDLC reflection", "course": "Software Engineering", "due_date": "2026-12-02", "priority": "High", "completed": False, "kind": "assignment"},
        {"id": 2, "title": "Study BFS and DFS", "course": "Artificial Intelligence", "due_date": "2026-11-28", "priority": "Medium", "completed": True, "kind": "study"},
        {"id": 3, "title": "Prepare network lab", "course": "Computer Networks", "due_date": "2026-11-30", "priority": "High", "completed": False, "kind": "assignment"},
        {"id": 4, "title": "Review SQL joins", "course": "Database Systems", "due_date": "2026-12-04", "priority": "Low", "completed": False, "kind": "study"},
        {"id": 5, "title": "Practice design patterns", "course": "Software Engineering", "due_date": "2026-12-05", "priority": "Medium", "completed": False, "kind": "study"},
        {"id": 6, "title": "Revise neural networks", "course": "Artificial Intelligence", "due_date": "2026-12-06", "priority": "Medium", "completed": True, "kind": "study"},
        {"id": 7, "title": "Prepare for network quiz", "course": "Computer Networks", "due_date": "2026-12-08", "priority": "High", "completed": False, "kind": "exam"},
        {"id": 8, "title": "Create ER diagram", "course": "Database Systems", "due_date": "2026-12-09", "priority": "Low", "completed": False, "kind": "assignment"},
    ],
    "sessions": [
        {"id": 1, "topic": "Design patterns reading", "course": "Software Engineering", "minutes": 45},
        {"id": 2, "topic": "AI search algorithms", "course": "Artificial Intelligence", "minutes": 60},
        {"id": 3, "topic": "Subnetting practice", "course": "Computer Networks", "minutes": 30},
    ],
    "next_course_id": 5,
    "next_task_id": 9,
    "next_session_id": 4,
}

class JsonStorageAdapter:
    """Adapter for simple JSON-file persistence."""
    def __init__(self, path: Path = DATA_FILE):
        self.path = path
        self.seed_if_missing()

    def seed_if_missing(self) -> None:
        if not self.path.exists():
            self.save(INITIAL_DATA.copy())

    def load(self) -> dict[str, Any]:
        if not self.path.exists():
            self.seed_if_missing()
        return json.loads(self.path.read_text(encoding="utf-8"))

    def save(self, data: dict[str, Any]) -> None:
        self.path.parent.mkdir(parents=True, exist_ok=True)
        self.path.write_text(json.dumps(data, indent=2), encoding="utf-8")
