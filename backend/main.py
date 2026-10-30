import asyncio
import threading

from uuid import uuid4

from fastapi import FastAPI, Request
from sse_starlette import EventSourceResponse

import apns as apns
import db.db as db

import agents.scraper_agent as scraper_agent
import agents.calendar_agent as calendar_agent

from schemas.schema import EventModel, EventsPayload, SSEStreamResponsePayload, FetchEventsPayload

mock_data = [
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
        },
        {
            "title": "Roller Skating - 2026",
            "description": None,
            "start_time": "2026-10-20T02:30:00Z",
            "end_time": "2026-10-20T04:00:00Z"
        },
        {
            "title": "Hackathon",
            "description": "Build projects quickly and creatively in time-boxed coding challenges.",
            "start_time": "2026-10-20T22:00:00Z",
            "end_time": "2026-10-20T23:00:00Z"
        },
        {
            "title": "UAS/Drone Society",
            "description": "Hands-on drone building, programming, and flight control systems.",
            "start_time": "2026-10-20T22:30:00Z",
            "end_time": "2026-10-20T23:30:00Z"
        },
        {
            "title": "IEEE Student Branch Society",
            "description": "Connect with global engineering professionals and stay on the tech edge.",
            "start_time": "2026-10-20T23:30:00Z",
            "end_time": "2026-10-21T00:30:00Z"
        },
        {
            "title": "Formula Hybrid Electric Team",
            "description": "Design and build electric hybrid racecars for national competitions.",
            "start_time": "2026-10-21T00:00:00Z",
            "end_time": "2026-10-21T01:00:00Z"
        },
        {
            "title": "Speed Dating",
            "description": None,
            "start_time": "2026-10-21T01:00:00Z",
            "end_time": "2026-10-21T03:00:00Z"
        },
        {
            "title": "Open Mic",
            "description": None,
            "start_time": "2026-10-21T01:00:00Z",
            "end_time": "2026-10-21T04:00:00Z"
        },
        {
            "title": "Latin Dance",
            "description": None,
            "start_time": "2026-10-21T02:00:00Z",
            "end_time": "2026-10-21T05:00:00Z"
        },
        {
            "title": "Computing Society",
            "description": "The Computing Society is the official organization for students in Computer Science, Software Engineering, and related fields within the Computer Science and Engineering Department at BYU–Idaho. It prepares members for future careers, helps build their personal portfolios, fosters a social environment for networking, and encourages teamwork across a wide range of technical disciplines.",
            "start_time": "2026-10-21T23:00:00Z",
            "end_time": "2026-10-22T00:00:00Z"
        },
        {
            "title": "Amateur Radio Society",
            "description": "Explore the world of radio communication, licensing, and RF systems.",
            "start_time": "2026-10-21T23:30:00Z",
            "end_time": "2026-10-22T00:30:00Z"
        },
        {
            "title": "Society of Women Engineers",
            "description": "Support and empower women in engineering through networking and mentoring.",
            "start_time": "2026-10-21T23:30:00Z",
            "end_time": "2026-10-22T00:30:00Z"
        },
        {
            "title": "Society of Cybersecurity",
            "description": "Learn ethical hacking, penetration testing, and digital defense skills.",
            "start_time": "2026-10-21T23:30:00Z",
            "end_time": "2026-10-22T00:30:00Z"
        },
        {
            "title": "Web Society",
            "description": "Frontend, backend, and full-stack web development for all skill levels.",
            "start_time": "2026-10-21T23:30:00Z",
            "end_time": "2026-10-22T00:30:00Z"
        },
        {
            "title": "AI Society",
            "description": "Explore machine learning, data models, and the future of AI tech.",
            "start_time": "2026-10-21T23:30:00Z",
            "end_time": "2026-10-22T00:30:00Z"
        },
        {
            "title": "Video Game Design",
            "description": "Learn game engines, art, and coding while building your own games.",
            "start_time": "2026-10-21T23:30:00Z",
            "end_time": "2026-10-22T00:30:00Z"
        },
        {
            "title": "Data Science",
            "description": "Use data analysis, Python, and machine learning to solve real problems.",
            "start_time": "2026-10-22T00:00:00Z",
            "end_time": "2026-10-22T01:00:00Z"
        },
        {
            "title": "Country Dancing",
            "description": None,
            "start_time": "2026-10-22T01:00:00Z",
            "end_time": "2026-10-22T05:00:00Z"
        },
        {
            "title": "Cloud Solutions",
            "description": "Hands-on with AWS, Azure, and GCP to learn cloud architecture and scaling.",
            "start_time": "2026-10-22T23:00:00Z",
            "end_time": "2026-10-23T00:00:00Z"
        },
        {
            "title": "Linux and Open Source",
            "description": "Dive into Linux, shell scripting, and contributing to open-source tools.",
            "start_time": "2026-10-22T23:30:00Z",
            "end_time": "2026-10-23T00:30:00Z"
        },
        {
            "title": "AI Society",
            "description": "Explore machine learning, data models, and the future of AI tech.",
            "start_time": "2026-10-22T23:30:00Z",
            "end_time": "2026-10-23T00:30:00Z"
        },
        {
            "title": "Formula Hybrid Electric Team",
            "description": "Design and build electric hybrid racecars for national competitions.",
            "start_time": "2026-10-23T00:00:00Z",
            "end_time": "2026-10-23T01:00:00Z"
        },
        {
            "title": "Game Night - Dungeons and Dragons",
            "description": None,
            "start_time": "2026-10-23T00:00:00Z",
            "end_time": "2026-10-23T04:00:00Z"
        },
        {
            "title": "Game Night",
            "description": None,
            "start_time": "2026-10-23T01:00:00Z",
            "end_time": "2026-10-23T04:00:00Z"
        },
        {
            "title": "Roller Skating - 2026",
            "description": None,
            "start_time": "2026-10-23T02:30:00Z",
            "end_time": "2026-10-23T04:00:00Z"
        },
        {
            "title": "Video Game Design",
            "description": "Learn game engines, art, and coding while building your own games.",
            "start_time": "2026-10-23T23:30:00Z",
            "end_time": "2026-10-24T00:30:00Z"
        },
        {
            "title": "Mini Dates",
            "description": None,
            "start_time": "2026-10-24T01:00:00Z",
            "end_time": "2026-10-24T03:30:00Z"
        },
        {
            "title": "Laser Tag",
            "description": None,
            "start_time": "2026-10-24T02:00:00Z",
            "end_time": "2026-10-24T05:00:00Z"
        },
        {
            "title": "Roller Skating - 2026",
            "description": None,
            "start_time": "2026-10-25T00:30:00Z",
            "end_time": "2026-10-25T02:00:00Z"
        },
        {
            "title": "Roller Skating - 2026",
            "description": None,
            "start_time": "2026-10-25T02:30:00Z",
            "end_time": "2026-10-25T04:00:00Z"
        },
        {
            "title": "Stadium Singing - Spanish",
            "description": None,
            "start_time": "2026-10-26T02:00:00Z",
            "end_time": "2026-10-26T02:30:00Z"
        },
        {
            "title": "Stadium Singing - English",
            "description": None,
            "start_time": "2026-10-26T02:45:00Z",
            "end_time": "2026-10-26T03:15:00Z"
        },
        {
            "title": "Roller Skating - 2026",
            "description": None,
            "start_time": "2026-10-27T00:30:00Z",
            "end_time": "2026-10-27T02:00:00Z"
        },
        {
            "title": "Home Evening - 2026",
            "description": None,
            "start_time": "2026-10-27T01:00:00Z",
            "end_time": "2026-10-27T03:00:00Z"
        },
        {
            "title": "Home Evening Laser Tag",
            "description": None,
            "start_time": "2026-10-27T01:00:00Z",
            "end_time": "2026-10-27T04:00:00Z"
        },
        {
            "title": "Roller Skating - 2026",
            "description": None,
            "start_time": "2026-10-27T02:30:00Z",
            "end_time": "2026-10-27T04:00:00Z"
        }
    ]
]

app = FastAPI()

@app.post("/api/fetch-events")
async def fetch_events(request: Request, payload: FetchEventsPayload):
    queue = asyncio.Queue()

    async def fetch():
        try:
            await queue.put(
                SSEStreamResponsePayload(
                    event_type="progress",
                    message="Fetching events from BYU-I..."
                ).to_sse()
            )

            university_events = await scraper_agent.execute()
            # university_events = mock_data # for now, use data already scraped using Gemini to avoid hitting Gemini API limits during testing

            await queue.put(
                SSEStreamResponsePayload(
                    event_type="progress",
                    message="Matching events from BYU-I with interests and schedule..."
                ).to_sse()
            )

            final_events = await calendar_agent.execute(events=university_events, client_payload=payload)

            if final_events:
                events_id = str(uuid4())
                events_model = EventsPayload(events=final_events)

                db.insert_events_payload(events_id, events_model)
                
                await queue.put(
                    SSEStreamResponsePayload(
                        event_type="success",
                        message="Successfully fetched and matched events from BYU-I.",
                        events=final_events
                    ).to_sse()
                )

                await apns.send_apn(payload.device_token, events_id)
        except Exception as e:
            import traceback

            print(f"ERROR in fetch function: {str(e)}")
            traceback.print_exc()

            await queue.put(
                SSEStreamResponsePayload(
                    event_type="error",
                    message=f"Server error: {str(e)}"
                ).to_sse()
            )
        finally:
            await queue.put(None)

    asyncio.create_task(fetch())

    async def event_generator():
        try:
            while True:
                event = await queue.get()
                
                if event is None:
                    break

                yield event
        except asyncio.CancelledError:
            raise

    return EventSourceResponse(event_generator())

@app.get("/api/fetch-stored-events")
async def fetch_stored_events(id: str):
    from uuid import UUID

    try:
        events = db.get_events_payload(UUID(id))

        if events:
            return SSEStreamResponsePayload(
                event_type="success",
                message=f"Successfully fetched stored events for ID '{id}'.",
                events=events.events
            )
        else:
            return SSEStreamResponsePayload(
                event_type="error",
                message=f"No events found for the provided ID '{id}'."
            )
    except Exception as e:
        return {
            "status": "error",
            "message": f"Server error: {str(e)}"
        }

if __name__ == "__main__":
    import uvicorn

    db.create_db()

    uvicorn.run(app, port=8000)