import json
import uuid

from google.adk.agents import Agent
from google.adk.models.lite_llm import LiteLlm
from google.adk.runners import Runner
from google.adk.sessions import InMemorySessionService
from google.genai import types

from agents.scraper_agent import EventModel, EventPayload

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
    1. Evaluate every single event in the scraped list. 
    2. If an event does NOT overlap with an item in the User's Fixed Calendar and does not match dislikes, you MUST include it in the output. Do not arbitrarily omit valid non-conflicting events.
    3. If an event starts right after a calendar task finishes, it's safe to recommend.

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

async def execute(events: list[EventModel], users_calendar: list[EventPayload]):
    session_id = f"session_{uuid.uuid4()}"
    
    await session_service.create_session(
        app_name="CampusSelect",
        user_id=USER_ID, 
        session_id=session_id,
    )

    prompt = f"""
    USER'S EXISTING FIXED CALENDAR EVENTS:
    {json.dumps(users_calendar, indent=2)}
    
    NEWLY SCRAPED CAMPUS EVENTS TO CHOOSE FROM:
    {json.dumps(events, indent=2)}
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
