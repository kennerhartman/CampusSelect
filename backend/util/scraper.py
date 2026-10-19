import json
import requests
from bs4 import BeautifulSoup

def strip_html(html):
    soup = BeautifulSoup(html, "html.parser")

    for element in soup([
        "script", 
        "style", 
        "nav", 
        "header", 
        "footer", 
        "aside",
        "ps-header"
    ]):
        element.decompose()

    text = [
        line.strip() for line in soup.get_text().splitlines() if line.strip()
    ]

    return "\n".join(text)

def scrape_url(url: str) -> str:
    headers = {
        "User-Agent": "kennerhartman/CampusSelect (BYU-I Calendar Event Scraper) (https://github.com/kennerhartman/CampusSelect)"
    }

    response = requests.get(url, headers=headers)

    if response.status_code != 200:
        return f"Error fetching page: HTTP {response.status_code}"

    return strip_html(response.content)

if __name__ == "__main__":
    weekly_activities = scrape_url("https://www.byui.edu/calendar/categories/weekly-activities")
    society_events = scrape_url("https://www.byui.edu/computer-science-engineering/student-resources/societies")

    print(weekly_activities)