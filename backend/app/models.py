from pydantic import BaseModel, Field
from typing import Literal

class Course(BaseModel):
    id: int
    name: str

class Task(BaseModel):
    id: int
    title: str
    course: str = "General"
    due_date: str = ""
    priority: Literal["Low", "Medium", "High"] = "Medium"
    completed: bool = False
    kind: Literal["assignment", "study", "exam"] = "assignment"

class TaskCreate(BaseModel):
    title: str = Field(min_length=1, max_length=100)
    course: str = "General"
    due_date: str = ""
    priority: Literal["Low", "Medium", "High"] = "Medium"
    kind: Literal["assignment", "study", "exam"] = "assignment"

class TaskUpdate(BaseModel):
    title: str | None = Field(default=None, min_length=1, max_length=100)
    course: str | None = None
    due_date: str | None = None
    priority: Literal["Low", "Medium", "High"] | None = None
    completed: bool | None = None
    kind: Literal["assignment", "study", "exam"] | None = None

class CourseCreate(BaseModel):
    name: str = Field(min_length=1, max_length=80)

class SessionCreate(BaseModel):
    topic: str = Field(min_length=1, max_length=100)
    course: str = "General"
    minutes: int = Field(gt=0, le=600)
