
def test_create_task_and_dashboard(client):
    response = client.post(
        "/tasks",
        json={
            "title": "Test task",
            "course": "CSE",
            "due_date": "2026-12-01",
            "priority": "High",
            "kind": "assignment"
        }
    )

    assert response.status_code == 200
    assert response.json()["title"] == "Test task"

    dashboard = client.get("/dashboard")

    assert dashboard.status_code == 200
    assert dashboard.json()["total"] == 1


def test_task_not_found(client):
    response = client.put("/tasks/999/toggle")

    assert response.status_code == 404


def test_get_tasks(client):
    client.post(
        "/tasks",
        json={
            "title": "Study Python",
            "course": "CSE",
            "due_date": "2026-12-05",
            "priority": "Medium",
            "kind": "study"
        }
    )

    response = client.get("/tasks")

    assert response.status_code == 200
    assert len(response.json()) == 1
    assert response.json()[0]["title"] == "Study Python"


def test_toggle_task_completion(client):
    create_response = client.post(
        "/tasks",
        json={
            "title": "Complete assignment",
            "course": "CSE",
            "due_date": "2026-12-10",
            "priority": "High",
            "kind": "assignment"
        }
    )

    task_id = create_response.json()["id"]

    toggle_response = client.put(f"/tasks/{task_id}/toggle")

    assert toggle_response.status_code == 200

    tasks_response = client.get("/tasks")
    task = tasks_response.json()[0]

    assert task["completed"] is True


def test_delete_task(client):
    create_response = client.post(
        "/tasks",
        json={
            "title": "Temporary task",
            "course": "CSE",
            "due_date": "2026-12-10",
            "priority": "Low",
            "kind": "study"
        }
    )

    task_id = create_response.json()["id"]

    delete_response = client.delete(f"/tasks/{task_id}")

    assert delete_response.status_code == 200

    tasks_response = client.get("/tasks")

    assert tasks_response.status_code == 200
    assert len(tasks_response.json()) == 0
