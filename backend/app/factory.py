from .models import Task, TaskCreate

class TaskFactory:
    """Factory Method: creates task records based on the selected task kind."""
    @staticmethod
    def create(task_id: int, data: TaskCreate) -> Task:
        return Task(id=task_id, title=data.title.strip(), course=data.course, due_date=data.due_date,
                   priority=data.priority, kind=data.kind, completed=False)
