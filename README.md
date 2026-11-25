# StudyFlow – Student Planner

A student productivity and study management web application built with **Flutter Web** and **FastAPI**. StudyFlow helps students organize academic tasks, manage courses, record study sessions, and monitor their study progress through a simple dashboard.

The application uses a lightweight JSON file for backend data persistence, so no separate database server is required.

---

## Table of Contents

- [Features](#features)
- [Technology Stack](#technology-stack)
- [Project Architecture](#project-architecture)
- [Design Patterns](#design-patterns)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Running the Application](#running-the-application)
- [API Documentation](#api-documentation)
- [Testing](#testing)
- [Continuous Integration](#continuous-integration)
- [Configuration](#configuration)
- [Limitations](#limitations)
- [Future Improvements](#future-improvements)

---

## Features

### 1. Task Management
- Create academic tasks.
- View and organize tasks.
- Mark tasks as completed or incomplete.
- Delete existing tasks.
- Assign task types and priorities.
- Set due dates for tasks.

### 2. Course Management
- Add new courses.
- View available courses.
- Delete courses.
- Organize academic activities by course.

### 3. Study Session Management
- Record study sessions.
- Add a study topic and associated course.
- Record study time.
- Keep track of study activities.

### 4. Dashboard
- View total task count.
- Monitor completed and unfinished tasks.
- View task completion percentage.
- Get an overview of academic progress.

### 5. Reminders
- Display unfinished tasks with due dates.
- Help students keep track of upcoming academic work.

---

## Technology Stack

| Technology | Purpose |
|---|---|
| Flutter Web | Frontend development |
| Dart | Frontend programming language |
| Python | Backend programming language |
| FastAPI | REST API development |
| JSON | Data storage |
| Uvicorn | Backend development server |
| Pytest | Backend testing |
| FastAPI TestClient | API endpoint testing |
| unittest.mock | Mocking dependencies |
| Schemathesis | Automated API testing |
| Flutter Test | Frontend widget testing |
| Selenium | Browser automation |
| Git and GitHub | Version control |
| GitHub Actions | Continuous Integration |
| Swagger UI / OpenAPI | API documentation |

---

## Project Architecture

StudyFlow follows a client-server architecture.

- **Frontend:** Flutter Web provides the user interface.
- **Backend:** FastAPI handles application logic and API requests.
- **Storage:** A JSON file stores application data.
- **Communication:** The frontend communicates with the backend through REST APIs using JSON.

### Application Flow

```text
       Student
          |
          v
   Flutter Web Frontend
          |
          | HTTP Requests / JSON
          v
     FastAPI Backend
          |
          v
    Application Logic
          |
          v
      JSON Storage
```

The frontend does not access the JSON storage directly. All data operations are handled by the backend.

---

## Design Patterns

Three design patterns are implemented in the backend.

### 1. Factory Method – Creational Pattern

**File:** `backend/app/factory.py`

The Factory Method pattern is used to create task objects based on their task kind.

It centralizes task creation and helps maintain consistent object initialization without placing all creation logic inside API endpoints.

### 2. Adapter – Structural Pattern

**File:** `backend/app/storage.py`

The Adapter pattern is used to adapt JSON-file persistence to a common storage interface.

It provides load and save operations, allowing the application to interact with storage without depending directly on file-handling details.

### 3. Observer – Behavioral Pattern

**File:** `backend/app/events.py`

The Observer pattern provides a task change notification mechanism.

Listeners can subscribe to task-related events and receive notifications when the event system is triggered.

---

## Project Structure

```text
StudyFlow/
│
├── backend/
│   ├── app/
│   │   ├── main.py
│   │   ├── models.py
│   │   ├── factory.py
│   │   ├── storage.py
│   │   └── events.py
│   │
│   ├── tests/
│   │   ├── test_api.py
│   │   └── test_logic.py
│   │
│   └── requirements.txt
│
├── frontend/
│   ├── lib/
│   │   └── main.dart
│   │
│   ├── test/
│   │   └── widget_test.dart
│   │
│   └── pubspec.yaml
│
├── .github/
│   └── workflows/
│       └── studyflow-ci.yml
│
└── README.md
```

*The structure above shows the main project files. Additional files may exist in the actual repository.*

---

## Getting Started

Follow these steps to run StudyFlow locally.

### Prerequisites

Install the following software:

- Python 3.10 or later (use a version compatible with the project dependencies).
- Flutter SDK.
- Google Chrome.
- Git.

Verify your installations:

```bash
python --version
flutter --version
git --version
```

### 1. Clone the Repository

```bash
git clone YOUR_GITHUB_REPOSITORY_URL
```

Navigate to the project:

```bash
cd StudyFlow
```

### 2. Set Up the Backend

Navigate to the backend directory:

```bash
cd backend
```

Create a Python virtual environment:

```bash
python -m venv venv
```

Activate the environment.

**Windows:**

```powershell
venv\Scripts\activate
```

**Linux / macOS:**

```bash
source venv/bin/activate
```

Install the required dependencies:

```bash
pip install -r requirements.txt
```

### 3. Start the Backend Server

Run:

```bash
uvicorn app.main:app --reload
```

The backend will be available at:

```text
http://127.0.0.1:8000
```

Keep this terminal running while using the application.

### 4. Set Up the Frontend

Open another terminal and navigate to the frontend directory:

```bash
cd frontend
```

Install Flutter dependencies:

```bash
flutter pub get
```

### 5. Run the Frontend

Start the application in Chrome:

```bash
flutter run -d chrome
```

StudyFlow should now open in your browser.

---

## API Documentation

StudyFlow uses FastAPI to provide REST API endpoints.

FastAPI automatically generates interactive API documentation using the OpenAPI specification.

After starting the backend, open:

**Swagger UI:**

http://127.0.0.1:8000/docs

**ReDoc:**

http://127.0.0.1:8000/redoc

**OpenAPI JSON:**

http://127.0.0.1:8000/openapi.json

Swagger UI allows developers to:

- Explore available API endpoints.
- View HTTP methods and parameters.
- Inspect request and response schemas.
- Execute API requests using the Try it out feature.
- Observe response status codes and JSON data.

---

## Testing

Testing is performed on both the backend and frontend.

### 1. Backend Unit and API Tests

Navigate to the backend directory:

```bash
cd backend
```

Run the test suite:

```bash
pytest
```

### 2. Backend Test Coverage

Install the coverage package if it is not already included:

```bash
pip install pytest-cov
```

Run:

```bash
pytest --cov=app --cov-report=term-missing
```

This displays statement coverage and identifies lines that were not executed during testing.

### 3. Mocking

The backend tests use fake storage and mock objects to isolate components from external dependencies.

- `FakeStorage` provides temporary in-memory application data.
- `unittest.mock.Mock` is used to test event notifications.
- Pytest's `monkeypatch` replaces the actual storage dependency during API tests.

### 4. API Testing with Schemathesis

Start the backend server and run:

```bash
st run http://127.0.0.1:8000/openapi.json
```

Schemathesis generates API test cases from the OpenAPI specification and helps identify unexpected API behavior.

### 5. Frontend Widget Tests

Navigate to the frontend directory:

```bash
cd frontend
```

Run:

```bash
flutter test
```

### 6. Flutter Code Analysis

Run:

```bash
flutter analyze
```

This checks the Flutter source code for potential errors, warnings, and deprecated API usage.

### 7. Browser Testing with Selenium

Selenium can be used to automate browser-based checks of the StudyFlow frontend.

The frontend URL in the Selenium script must match the actual address where Flutter Web is running.

---

## Continuous Integration

StudyFlow uses **GitHub Actions** to automate backend and frontend checks.

Workflow file:

```text
.github/workflows/studyflow-ci.yml
```

The workflow is configured to run on:

- Pushes to the main branch.
- Pull Requests targeting the main branch.

### Backend CI Job

- Checks out the repository.
- Sets up Python.
- Installs backend dependencies.
- Runs Pytest.
- Generates a test coverage summary.

### Frontend CI Job

- Checks out the repository.
- Sets up Flutter.
- Installs Flutter dependencies.
- Runs Flutter analysis.
- Executes Flutter widget tests.

GitHub Actions helps identify errors automatically whenever new changes are pushed or submitted through a Pull Request.

---

## Configuration

The Flutter frontend communicates with the FastAPI backend through an API base URL configured in:

```text
frontend/lib/main.dart
```

For local development, the default backend URL is:

```dart
http://127.0.0.1:8000
```

If the backend is deployed separately, update the API base URL to the deployed backend address.

For example:

```dart
https://your-backend-url.onrender.com
```

Use the actual deployed URL when configuring the application.

---

## Limitations

- The application uses JSON file storage instead of a database server.
- JSON storage is intended for a simple student project and is not designed for concurrent production use.
- Authentication and multi-user account management are not included unless added separately.
- The application requires a running backend to access its API functionality.
- Additional validation and error handling may be needed for production use.

---

## Future Improvements

Possible future improvements include:

- Integrating MySQL or PostgreSQL.
- Adding user registration and authentication.
- Improving responsive layouts.
- Adding more detailed study statistics.
- Expanding automated frontend and backend test coverage.
- Improving API validation and error handling.
- Adding notifications for upcoming deadlines.
- Improving deployment and production configuration.

---

## Author

**Project:** StudyFlow – Student Planner  
**Course:** CSE 3206 – Software Engineering  
**Frontend:** Flutter Web  
**Backend:** FastAPI / Python

---

## License

This project was developed as an academic software engineering sessional project.
