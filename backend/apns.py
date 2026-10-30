import os
from pathlib import Path
from uuid import uuid4

import certifi

from aioapns import APNs, NotificationRequest

KEY_PEM = Path(__file__).resolve().parent / "key.pem"

async def send_apn(device_token: str, events_id: str):
    os.environ["SSL_CERT_FILE"] = certifi.where()

    cert_client = APNs(
        client_cert=str(KEY_PEM),
        use_sandbox=True
    )

    request = NotificationRequest(
        device_token=device_token,
        message = {
            "aps": {
                "alert": "You have new events waiting for you to view",
                "badge": "1",
            },
            "events_id": events_id
        },
        apns_topic="com.kennerhartman.CampusSelect"
    )

    await cert_client.send_notification(request)