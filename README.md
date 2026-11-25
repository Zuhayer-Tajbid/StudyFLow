# StudyFlow — simple student planner

A small Flutter Web + FastAPI app for CSE 3206. No database server is used; the backend persists data in a JSON file.

## Modules
- Tasks: add, toggle complete, delete; task types and priorities
- Courses: add/delete
- Study sessions: record topic/course/time
- Dashboard: counts and completion percentage
- Reminders: show unfinished tasks with due dates

## Design patterns included
- Factory Method: `backend/app/factory.py` creates task objects by task kind
- Adapter: `backend/app/storage.py` adapts JSON-file persistence to load/save operations
- Observer: `backend/app/events.py` provides task change notification listeners

## Start backend
```bash
cd backend
python -m venv venv
# Windows: venv\\Scripts\\activate
# Linux/macOS: source venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```
Swagger: http://127.0.0.1:8000/docs

## Start frontend
Install Flutter SDK, then:
```bash
cd frontend
flutter pub get
flutter run -d chrome
```
If Chrome/frontend is hosted separately, adjust `api` in `frontend/lib/main.dart` to the backend URL. For local development the default is `http://127.0.0.1:8000`.

## Backend tests
```bash
cd backend
pytest
```

## Note
This is a starter implementation for a student project. It uses simple JSON storage and is not designed for concurrent production use. Add tests and improve validation/error handling as you build each increment.
