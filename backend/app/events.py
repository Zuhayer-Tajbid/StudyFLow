from typing import Callable

class TaskEvents:
    """Tiny Observer implementation: listeners are notified after task changes."""
    def __init__(self):
        self.listeners: list[Callable[[], None]] = []

    def subscribe(self, listener: Callable[[], None]) -> None:
        self.listeners.append(listener)

    def notify(self) -> None:
        for listener in self.listeners:
            listener()
