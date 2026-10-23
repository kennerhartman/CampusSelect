from typing import Optional

from pydantic import BaseModel, Field
from sse_starlette import ServerSentEvent

class EventModel(BaseModel):
    """
    Represents a single event found from scraping BYU-I's events webpage.
    Attributes:
        title (str): The name of the event or academic society.
        description (Optional[str]): The event summary, details, or theme. Can be None if not provided.
        start_time (str): The event start time formatted as an ISO 8601 string with local offset: YYYY-MM-DDTHH:MM:SS-06:00
        end_time (str): The event end time formatted as an ISO 8601 string with local offset: YYYY-MM-DDTHH:MM:SS-06:00
    """

    title: str = Field(description="The name of the event or academic society.")
    description: str | None = Field(None, description="The event summary, details, or theme.")
    start_time: str = Field(description="The event start time formatted as an ISO 8601 string with local offset: YYYY-MM-DDTHH:MM:SS-06:00")
    end_time: str = Field(description="The event end time formatted as an ISO 8601 string with local offset: YYYY-MM-DDTHH:MM:SS-06:00")    

class EventsPayload(BaseModel):
    """
    Represents a collection of events found from scraping BYU-I's events webpage 
    and is used to send the data to the client in a structured format.
    Attributes:
        events (list[EventModel]): A list of EventModel instances representing individual events.
    """

    events: list[EventModel]

class ProfileModel(BaseModel):
    """
    Represents a user's profile information for matching events.
    Attributes:
        name (str): The user's name.
        gender (str): The user's gender.
        interests (str): The user's interests.
    """

    name: str = Field(description="The user's name.")
    gender: str = Field(description="The user's gender.")
    about: str = Field(description="The user's interests.")

class FetchEventsPayload(BaseModel):
    """
    Represents a collection of events found from scraping BYU-I's events webpage 
    and is used to send the data to the client in a structured format.
    Attributes:
        calender (list[EventModel]): A list of events in the user's calender that the AI will use to match with new events scraped from BYU-I's events webpage.
        profile (str): A descriptive summary of the user's name, gender, and interests used by the AI to match events with the user's preferences.
    """

    calendar: EventsPayload = Field(description="A list of events in the user's calender that the AI will use to match with new events scraped from BYU-I's events webpage.")
    profile: ProfileModel = Field(description="A descriptive summary of the user's name, gender, and interests used by the AI to match events with the user's preferences.")

class SSEStreamResponsePayload(BaseModel):
    """
    Represents the payload for a Server-Sent Events (SSE) stream response.
    This model is used to structure the data sent to the client in real-time via SSE.
    Attributes:
        event_type (str): The type of event being sent to the client.
        message (str): The data payload associated with the event, serialized as a JSON string.
        events (Optional[list[EventModel]]): An optional list of EventModel instances representing calendar events.
    """

    event_type: str = Field(description="The type of event being sent to the client.")
    message: str = Field(description="The data payload associated with the event, serialized as a JSON string.")
    events: Optional[list[EventModel]] = None

    def to_sse(self) -> ServerSentEvent:
        return ServerSentEvent(
            event=self.event_type,
            data=self.model_dump_json()
        )