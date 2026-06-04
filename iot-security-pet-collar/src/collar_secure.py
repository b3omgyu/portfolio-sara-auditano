import time
import random
import requests
from datetime import datetime, timezone

SERVER_URL = "http://127.0.0.1:5000/data"
API_KEY = "super-secret-key"
DEVICE_ID = "collar-001"
SEND_EVERY_SECONDS = 3


def generate_payload():
    temperature = round(random.uniform(36.0, 39.5), 2)

    base_lat, base_lon = 40.8518, 14.2681
    lat = round(base_lat + random.uniform(-0.01, 0.01), 6)
    lon = round(base_lon + random.uniform(-0.01, 0.01), 6)

    timestamp = datetime.now(timezone.utc).isoformat(timespec="seconds")

    return {
        "device_id": DEVICE_ID,
        "timestamp": timestamp,
        "temperature_c": temperature,
        "position": {"lat": lat, "lon": lon},
    }


def main():
    print("[Collar SECURE] Sending secure data")

    headers = {
        "X-API-Key": API_KEY
    }

    while True:
        payload = generate_payload()
        try:
            r = requests.post(
                SERVER_URL,
                json=payload,
                headers=headers,
                timeout=3,
                proxies={"http": None, "https": None}
            )
            print(f"[SECURE] status = {r.status_code} | response = {r.text}")
        except requests.RequestException as e:
            print(f"[SECURE] ERROR: {e}")

        time.sleep(SEND_EVERY_SECONDS)


if __name__ == "__main__":
    main()
