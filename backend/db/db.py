from uuid import UUID, uuid4
import json

import sqlite3

from schemas.schema import EventModel, EventsPayload

database_path = "events.db"

def create_db():
    print("Initializing database...")

    conn = sqlite3.connect(database_path)
    cursor = conn.cursor()

    cursor.execute(
        """
        CREATE TABLE IF NOT EXISTS events (
            id TEXT PRIMARY KEY,
            json TEXT NOT NULL
        )
        """
    )

    conn.commit()
    conn.close()

    print("Database initialized successfully.")

def insert_events_payload(id: str, events: EventsPayload):
    conn = sqlite3.connect(database_path)
    cursor = conn.cursor()

    json_string = str(events.model_dump_json())

    cursor.execute(
        "INSERT INTO events (id, json) VALUES (?, ?)",
        (id, json_string)
    )

    conn.commit()
    conn.close()

def get_events_payload(event_id: UUID) -> EventsPayload | None:
    row = sqlite3.connect(database_path).execute(
        "SELECT id, json FROM events WHERE id = ?",
        (str(event_id),)
    ).fetchone()

    if row:
        json_string = row[1]

        return EventsPayload.model_validate_json(json_string)
    else:
        return None

def delete_events_payload(event_id: UUID):
    conn = sqlite3.connect(database_path)
    cursor = conn.cursor()

    cursor.execute(
        "DELETE FROM events WHERE id = ?",
        (str(event_id),)
    )

    conn.commit()
    conn.close()

if __name__ == "__main__":
    uuid = "3e84bcef-4639-41cb-abf5-3843161221f0"

    create_db()

    raw_events = [
        EventModel(**item) for item in [
                {
                    "title": "Home Evening - 2026",
                    "description": None,
                    "start_time": "2026-10-20T01:00:00Z",
                    "end_time": "2026-10-20T03:00:00Z"
                },
                {
                    "title": "Home Evening Laser Tag",
                    "description": None,
                    "start_time": "2026-10-20T01:00:00Z",
                    "end_time": "2026-10-20T04:00:00Z"
                }
        ]
    ]

    events = EventsPayload(events=raw_events)

    insert_events_payload(
        uuid,
        events
    )

    fetched_events = get_events_payload(UUID(uuid))
    print(fetched_events.model_dump() if fetched_events else "Event not found.")

    delete_events_payload(UUID(uuid))

    selected_event = get_events_payload(UUID(uuid))
    print(selected_event.model_dump() if selected_event else "Event not found.")