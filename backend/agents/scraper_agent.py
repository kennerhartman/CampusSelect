import json
import os
from datetime import datetime
from google import genai
from google.genai import types
from pydantic import BaseModel, Field
from util.scraper import scrape_url

class EventModel(BaseModel):
    title: str = Field(description="The name of the event or academic society.")
    description: str | None = Field(None, description="The event summary, details, or theme.")
    start_time: str = Field(description="The event start time formatted strictly as an ISO 8601 string: YYYY-MM-DDTHH:MM:SSZ")
    end_time: str = Field(description="The event end time formatted strictly as an ISO 8601 string: YYYY-MM-DDTHH:MM:SSZ")

class EventPayload(BaseModel):
    events: list[EventModel]

async def execute():
    api_key = os.environ.get("GEMINI_API_KEY")
    client = genai.Client(api_key=api_key)

    current_time = datetime.now().strftime("%A, %B %d, %Y")
    
    activities_text = scrape_url("https://www.byui.edu/calendar/categories/weekly-activities")
    socitey_text = scrape_url("https://www.byui.edu/computer-science-engineering/student-resources/societies")

    scraped_text = f"""
    --- WEB DATA SOURCE A: WEEKLY ACTIVITIES ---
    {activities_text}
    
    --- WEB DATA SOURCE B: COMPUTER SCIENCE SOCIETY ---
    {socitey_text}
    """

    prompt = f"""
    You are an advanced calendar parsing engine. Analyze the provided text dumps from the university web pages.
    Your task is to identify and extract individual events or group meetings that take place within the next 7 days.
    
    CRITICAL CONTEXT PARAMETERS:
    - Today's current date reference is: {current_time}.
    - Extract ONLY events happening over the next 7 days starting from today. Ignore any entries that fall outside this window.
    - Carefully calculate the absolute dates for recurring items based on the reference day.
    - If a meeting entry does not list an explicit end time, default it to exactly 1 hour after the start_time.
    - "Get Involved" IS NOT a valid description for an event. If you encounter this phrase, replace it with a more descriptive summary of the event or meeting, or null if there is no description to attach to the event.
    
    RAW SCRAPED CONTENT TO PARSE:
    {scraped_text}
    """

    response = client.models.generate_content(
        model='models/gemini-flash-latest',
        contents=prompt,
        config=types.GenerateContentConfig(
            response_mime_type="application/json",
            response_schema=EventPayload,
            temperature=0.0,
        ),
    )

    try:
        data = json.loads(response.text.strip())
        events_list = data.get("events", [])

        return [EventModel(**item) for item in events_list]
    except (json.JSONDecodeError, TypeError, KeyError) as e:
        print(f"Failed to parse output payload schema: {str(e)}")

        return []
