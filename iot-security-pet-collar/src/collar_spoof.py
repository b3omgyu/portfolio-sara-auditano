import requests
from datetime import datetime, timezone

SERVER_URL = "http://127.0.0.1:5000/data"

# Device NON autorizzato
FAKE_DEVICE_ID = "collar-FAKE"

# API key errata o assente
API_KEY = "wrong-key"


def main():
    payload = {
        "device_id": FAKE_DEVICE_ID,
        "timestamp": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "temperature_c": 99.9,
        "position": {"lat": 0, "lon": 0},
    }

    headers = {
        "X-API-KEY": API_KEY
    }

    print("[Spoofing] Sending fake device data")

    r = requests.post(
        SERVER_URL,
        json=payload,
        headers=headers,
        proxies={"http": None, "https": None}
    )

    print(f"[Spoofing] status = {r.status_code} | response={r.text}")


if __name__ == "__main__":
    main()
