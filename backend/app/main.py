from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from .models import Task, TaskCreate, TaskUpdate, Course, CourseCreate, SessionCreate
from .storage import JsonStorageAdapter
from .factory import TaskFactory
from .events import TaskEvents

app = FastAPI(title="StudyFlow API", description="Simple student task and study planner")
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"], allow_credentials=False)
storage = JsonStorageAdapter()
events = TaskEvents()
# Observer example: this listener is intentionally lightweight for demonstration.
events.subscribe(lambda: None)

@app.get("/", tags=["General"])
def home():
    return {"message": "StudyFlow API. Visit /docs for interactive documentation."}

@app.get("/courses", response_model=list[Course], tags=["Courses"])
def list_courses():
    return storage.load()["courses"]

@app.post("/courses", response_model=Course, tags=["Courses"])
def add_course(data: CourseCreate):
    db = storage.load()
    course = Course(id=db["next_course_id"], name=data.name.strip())
    db["next_course_id"] += 1
    db["courses"].append(course.model_dump())
    storage.save(db)
    return course

@app.delete("/courses/{course_id}", tags=["Courses"])
def delete_course(course_id: int):
    db = storage.load()
    course = next((c for c in db["courses"] if c["id"] == course_id), None)
    if course is None:
        raise HTTPException(404, "Course not found")
    db["courses"] = [c for c in db["courses"] if c["id"] != course_id]
    storage.save(db)
    return {"message": "Course deleted"}

@app.get("/tasks", response_model=list[Task], tags=["Tasks"])
def list_tasks():
    return storage.load()["tasks"]

@app.post("/tasks", response_model=Task, tags=["Tasks"])
def add_task(data: TaskCreate):
    db = storage.load()
    task = TaskFactory.create(db["next_task_id"], data)
    db["next_task_id"] += 1
    db["tasks"].append(task.model_dump())
    storage.save(db)
    events.notify()
    return task


@app.put("/tasks/{task_id}", response_model=Task, tags=["Tasks"])
def update_task(task_id: int, data: TaskUpdate):
    db = storage.load()
    task = next((t for t in db["tasks"] if t["id"] == task_id), None)
    if task is None:
        raise HTTPException(404, "Task not found")
    changes = data.model_dump(exclude_unset=True)
    for key, value in changes.items():
        task[key] = value
    task["title"] = task["title"].strip()
    storage.save(db)
    events.notify()
    return task

@app.put("/tasks/{task_id}/toggle", response_model=Task, tags=["Tasks"])
def toggle_task(task_id: int):
    db = storage.load()
    task = next((t for t in db["tasks"] if t["id"] == task_id), None)
    if task is None:
        raise HTTPException(404, "Task not found")
    task["completed"] = not task["completed"]
    storage.save(db)
    events.notify()
    return task

@app.delete("/tasks/{task_id}", tags=["Tasks"])
def delete_task(task_id: int):
    db = storage.load()
    if not any(t["id"] == task_id for t in db["tasks"]):
        raise HTTPException(404, "Task not found")
    db["tasks"] = [t for t in db["tasks"] if t["id"] != task_id]
    storage.save(db)
    events.notify()
    return {"message": "Task deleted"}

@app.get("/dashboard", tags=["Dashboard"])
def dashboard():
    tasks = storage.load()["tasks"]
    total = len(tasks)
    completed = sum(1 for t in tasks if t["completed"])
    return {"total": total, "completed": completed, "pending": total-completed,
            "progress_percent": round(completed/total*100) if total else 0}

@app.get("/reminders", tags=["Reminders"])
def reminders():
    # Simple in-app reminder list: tasks with a due date that are not completed.
    return [t for t in storage.load()["tasks"] if t["due_date"] and not t["completed"]]

@app.get("/sessions", tags=["Study Sessions"])
def list_sessions():
    return storage.load()["sessions"]

@app.post("/sessions", tags=["Study Sessions"])
def add_session(data: SessionCreate):
    db = storage.load()
    session = {"id": db["next_session_id"], "topic": data.topic.strip(), "course": data.course, "minutes": data.minutes}
    db["next_session_id"] += 1
    db["sessions"].append(session)
    storage.save(db)
    return session
