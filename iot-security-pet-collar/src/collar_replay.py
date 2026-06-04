import time
import requests
from datetime import datetime, timezone

SERVER_URL = "http://127.0.0.1:5000/data"
DEVICE_ID = "collar-001"
API_KEY = "super-secret-key"
SEND_EVERY_SECONDS = 3

# TIMESTAMP
FIXED_TIMESTAMP = datetime.now(timezone.utc).isoformat(timespec="seconds")


def generate_payload():
    return {
        "device_id": DEVICE_ID,
        "timestamp": FIXED_TIMESTAMP,
        "temperature_c": 38.5,
        "position": {"lat": 40.8518, "lon": 14.2681},
    }

def main():
    print("[Replay] Sending SAME payload twice (replay attack demo)")
    payload = generate_payload()

    headers = {
        "X-API-KEY": API_KEY
    }

    # PRIMO INVIO (valido)
    r1 = requests.post(
        SERVER_URL,
        json=payload,
        headers=headers,
        proxies={"http": None, "https": None}
    )
    print(f"[Replay] First send | status = {r1.status_code} | response = {r1.text}")

    time.sleep(SEND_EVERY_SECONDS)

    # SECONDO INVIO (replay)
    r2 = requests.post(
        SERVER_URL,
        json=payload,
        headers=headers,
        proxies={"http": None, "https": None}
    )
    print(f"[Replay] Second send (REPLAY) | status = {r2.status_code} | response = {r2.text}")


if __name__ == "__main__":
    main()
