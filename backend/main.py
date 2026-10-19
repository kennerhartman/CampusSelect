import asyncio
import json
from pydantic import BaseModel
from google.adk.agents import Agent
from google.adk.models.lite_llm import LiteLlm
from google.adk.runners import Runner
from google.adk.sessions import InMemorySessionService
from google.genai import types
from fastapi import FastAPI
from icalendar import Calendar

import agents.scraper_agent as scraper_agent

app = FastAPI()

@app.get("/scrape")
async def greet_endpoint():
    return await scraper_agent.execute()

if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, port=8000)