import os
from pathlib import Path
import certifi

from aioapns import APNs, NotificationRequest

KEY_PEM = Path(__file__).resolve().parent / "key.pem"

async def send_apn(device_token: str, final_events):
    os.environ["SSL_CERT_FILE"] = certifi.where()

    cert_client = APNs(
        client_cert=str(KEY_PEM),
        use_sandbox=True
    )

    # TODO: Store the final_events in a database to retrieve them later when the user opens the app. 
    # The notification should then include a UUID to these events that the client is sent.

    request = NotificationRequest(
        device_token=device_token,
        message = {
            "aps": {
                "alert": "Test",
                "badge": "1",
            }
        },
        apns_topic="com.kennerhartman.CampusSelect"
    )

    await cert_client.send_notification(request)