import time
import random
import requests
from datetime import datetime, timezone

SERVER_URL = "http://127.0.0.1:5000/data"
DEVICE_ID = "collar-001"
SEND_EVERY_SECONDS = 3

# === Proxy settings (per sniffing / MITM) ===
USE_PROXY = True            # True solo se usi ZAP / Burp
PROXY_URL = "http://127.0.0.1:8090"

proxies = {
    "http": PROXY_URL,
    "https": PROXY_URL
}


def generate_payload():
    temperature = round(random.uniform(36.0, 39.5), 2)

    # posizione simulata (Napoli-ish)
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
    print(f"[Collar] Sending data to {SERVER_URL} every {SEND_EVERY_SECONDS}s")

    if USE_PROXY:
        proxies = {"http": PROXY_URL, "https": PROXY_URL}
        print(f"[Collar] Proxy enabled: {PROXY_URL}")
    else:
        proxies = None
        print("[Collar] Proxy disabled")

    while True:
        payload = generate_payload()
        try:
            r = requests.post(
                SERVER_URL,
                json=payload,
                timeout=3,
                proxies=proxies
            )
            print(f"[Collar] Sent | status = {r.status_code} | response ={r.text}")
        except requests.RequestException as e:
            print(f"[Collar] ERROR sending data: {e}")

        time.sleep(SEND_EVERY_SECONDS)


if __name__ == "__main__":
    main()
