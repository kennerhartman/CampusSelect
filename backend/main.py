import asyncio
import json
from pydantic import BaseModel
from google.adk.agents import Agent
from google.adk.models.lite_llm import LiteLlm
from google.adk.runners import Runner
from google.adk.sessions import InMemorySessionService
from google.genai import types
from fastapi import FastAPI

USER_ID = "user_greeter"
SESSION_ID = "session_greeter"

local_llm = LiteLlm(
    model="ollama/qwen2.5",
    api_base="http://localhost:11434",
    format="json"
)


class GreetingModel(BaseModel):
    message: str

class ResponseModel(BaseModel):
    status: int
    data: dict

greeter_agent = Agent(
    name="Greeter",
    model=local_llm,
    tools=[],
    instruction="""
    You must respond ONLY with a raw JSON object matching this schema: {"message": "string"}.
    Do not wrap your output in markdown code blocks (like ```json). Do not write any conversational text before or after the JSON payload.
    You are only to say, 'Hello, World!' in the message field of the JSON object.
    """,
)

session_service = InMemorySessionService()

runner = Runner(
    agent=greeter_agent, 
    app_name="HelloWorld",
    session_service=session_service
)

async def greet(payload: GreetingModel):
    await session_service.create_session(
        app_name="HelloWorld",
        user_id=USER_ID,
        session_id=SESSION_ID
    )

    prompt = payload.message

    message = types.Content(role="user", parts=[types.Part(text=prompt)])

    async for event in runner.run_async(user_id=USER_ID, session_id=SESSION_ID, new_message=message):
        if event.is_final_response():
            response_text = event.content.parts[0].text

            try:
                json_data = json.loads(response_text)

                print("Raw Text Output:", response_text)
                print("Extracted Message:", json_data.get("message"))

                return ResponseModel(status=200, data=json_data)
            except json.JSONDecodeError:
                print("Raw Text Output (Failed to parse JSON):", response_text)

if __name__ == "__main__":
    app = FastAPI()

    @app.post("/greet", response_model=ResponseModel)
    async def greet_endpoint(payload: GreetingModel):
        return await greet(payload)
    
    import uvicorn

    uvicorn.run(app, port=8000)