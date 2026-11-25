# StudyFlow Backend

## Run
```bash
python -m venv venv
# Windows: venv\\Scripts\\activate
# macOS/Linux: source venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload
```
Open http://127.0.0.1:8000/docs for Swagger UI.

## Tests
```bash
pytest
```
JSON file storage is used instead of a database. Data is stored in `data.json`.
