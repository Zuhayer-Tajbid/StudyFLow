from unittest.mock import Mock
from app.factory import TaskFactory
from app.models import TaskCreate
from app.events import TaskEvents

def test_factory_creates_task_with_trimmed_title():
    task = TaskFactory.create(1, TaskCreate(title="  Read chapter  ", kind="study"))
    assert task.id == 1
    assert task.title == "Read chapter"
    assert task.kind == "study"
    assert task.completed is False

def test_observer_notifies_listener():
    listener = Mock()
    events = TaskEvents()
    events.subscribe(listener)
    events.notify()
    listener.assert_called_once()
