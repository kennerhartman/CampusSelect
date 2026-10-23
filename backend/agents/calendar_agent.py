import json
from typing import Any
import uuid

from google.adk.agents import Agent
from google.adk.models.lite_llm import LiteLlm
from google.adk.runners import Runner
from google.adk.sessions import InMemorySessionService
from google.genai import types

from schemas.schema import EventModel, FetchEventsPayload

calendar_agent = Agent(
    name="calendar_agent",
    description="An agent that extracts events from BYU-I calendar and society web pages and reconciles it with a user's calendar.",
    model=LiteLlm(
        model="ollama/qwen2.5",
        api_base="http://localhost:11434",
        model_info={"format": "json"},
        extra_body={
            "options": {
                "num_predict": 4096,
                "temperature": 0.0
            }
        }
    ),
    instruction="""
    You are a Personal Scheduling Assistant. Your task is to look at a newly scraped list of campus activities,
    compare them against the user's calendar, and build a tailored recommendation matrix.

    CRITICAL FILTERING RULES:
    1. Evaluate every single event in the scraped list against both the User's Fixed Calendar and the provided `UserProfile` data (`name`, `about`, `gender`).
    2. Exclude any event that overlaps with an item in the User's Fixed Calendar. Note: An event starting right after a calendar task finishes is considered back-to-back and is safe to recommend.
    3. STRICT DEMOGRAPHIC & AFFINITY FILTER: Exclude any gender-specific or identity-exclusive organization events (such as the "Society of Women Engineers", women's/men's specific clubs, fraternities, or sororities) unless the event name and description explicitly align with `UserProfile.gender`. If a club targets a specific gender that does not match `UserProfile.gender`, you MUST exclude it.
    4. Exclude any event that directly contradicts the user's personal preferences, background, or stated interests outlined in `UserProfile.about`.
    5. If an event passes both the calendar availability check and the profile/gender filter, you MUST include it in the output. Do not arbitrarily omit valid non-conflicting events.

    CRITICAL OUTPUT RULE:
    You must respond ONLY with a raw JSON array of events.
    Do not wrap your output in markdown code blocks. Do not write any conversational text.
    
    EXPECTED OBJECT FORMAT:
    [
        {
            "title": "Event Title",
            "description": "Description text or null",
            "start_time": "YYYY-MM-DDTHH:MM:SS-06:00",
            "end_time": "YYYY-MM-DDTHH:MM:SS-06:00"
        }
    ]
    """,
    tools=[]
)

session_service = InMemorySessionService()

runner = Runner(
    agent=calendar_agent,
    app_name="CampusSelect",
    session_service=session_service
)

USER_ID = "user_123"

async def execute(events: list[EventModel], client_payload: FetchEventsPayload):
    session_id = f"session_{uuid.uuid4()}"
    
    await session_service.create_session(
        app_name="CampusSelect",
        user_id=USER_ID, 
        session_id=session_id,
    )

    profile = client_payload.profile.model_dump()
    calendar = client_payload.calendar.model_dump()
    serialized_events = [event.model_dump() for event in events]

    prompt = f"""
    USER'S PROFILE INFORMATION:
    {json.dumps(profile, indent=2)}

    USER'S EXISTING FIXED CALENDAR EVENTS:
    {json.dumps(calendar, indent=2)}
    
    NEWLY SCRAPED CAMPUS EVENTS TO CHOOSE FROM:
    {json.dumps(serialized_events, indent=2)}
    """

    message = types.Content(role="user", parts=[types.Part(text=prompt)])

    async for event in runner.run_async(user_id=USER_ID, session_id=session_id, new_message=message):
        if event.is_final_response:
            response_text = event.content.parts[0].text
            
            try:
                parsed = json.loads(response_text)

                return [EventModel(**item) for item in parsed]
            except (json.JSONDecodeError, TypeError, KeyError) as e:
                print(f"Failed to parse output payload schema: {str(e)}")

                return []
