import requests
from datetime import datetime, timezone

SERVER_URL = "http://127.0.0.1:5000/data"
API_KEY = "super-secret-key"

def main():
    print("[Invalid Input] Sending malformed payload")

    payload = {
        "device_id": "collar-001",
        "timestamp": datetime.now(timezone.utc).isoformat(timespec="seconds"),
        "temperature_c": "temp",      
        "position": {
            "lat": 14.6745 ,            
            "lon": 15.3456
        }
    }

    headers = {
        "X-API-KEY": API_KEY
    }

    r = requests.post(
        SERVER_URL,
        json=payload,
        headers=headers,
        proxies={"http": None, "https": None}
    )

    print(f"[Invalid Input] status = {r.status_code} | response={r.text}")

if __name__ == "__main__":
    main()
