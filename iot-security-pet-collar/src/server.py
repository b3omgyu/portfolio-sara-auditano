from flask import Flask, request, jsonify
from datetime import datetime, timezone
import os

# ==============================
# CONFIGURAZIONE
# ==============================

MODE = "secure"  
# MODE = "insicure/secure"

API_KEY = "super-secret-key"
ALLOWED_DEVICES = {"collar-001"}
MAX_SKEW_SECONDS = 30  # finestra anti-replay

LOG_FILE = os.path.join("logs", "server.log")

app = Flask(__name__)


# ==============================
# LOGGING
# ==============================

def log_line(line: str):
    os.makedirs("logs", exist_ok=True)
    with open(LOG_FILE, "a", encoding="utf-8") as f:
        f.write(line + "\n")

def is_valid_device(device_id: str) -> bool:
    return device_id in ALLOWED_DEVICES


def is_fresh_timestamp(ts: str) -> bool:
    try:
        msg_time = datetime.fromisoformat(ts.replace("Z", ""))
        now = datetime.utcnow()
        delta = abs((now - msg_time).total_seconds())
        return delta <= MAX_SKEW_SECONDS
    except Exception:
        return False


# ==============================
# UTILITY SICUREZZA (FASE 2)
# ==============================

seen_timestamps = set()


def check_api_key(req):
    return req.headers.get("X-API-Key") == API_KEY


def check_device(device_id: str):
    return device_id in ALLOWED_DEVICES


def check_replay(timestamp_str: str):
    try:
        ts = datetime.fromisoformat(timestamp_str.replace("Z", "+00:00"))
    except Exception:
        return False, "timestamp not valid"

    now = datetime.now(timezone.utc)
    delta = abs((now - ts).total_seconds())

    if delta > MAX_SKEW_SECONDS:
        return False, "timestamp out of window"

    if timestamp_str in seen_timestamps:
        return False, "replay detected"

    seen_timestamps.add(timestamp_str)
    return True, None


def validate_payload(data: dict):
    required = ["device_id", "timestamp", "temperature_c", "position"]

    for field in required:
        if field not in data:
            return False, f"missing field: {field}"

    if not isinstance(data["temperature_c"], (int, float)):
        return False, "temperature not valid"

    pos = data["position"]
    if not isinstance(pos, dict):
        return False, "position not valid"

    if not isinstance(pos.get("lat"), (int, float)):
        return False, "lat not valid"

    if not isinstance(pos.get("lon"), (int, float)):
        return False, "lon not valid"

    return True, None

def validate_payload(data: dict):
    required_fields = ["device_id", "timestamp", "temperature_c", "position"]

    for field in required_fields:
        if field not in data:
            return False, f"missing field:: {field}"

    if not isinstance(data["device_id"], str):
        return False, "device_id not valid"

    try:
        datetime.fromisoformat(data["timestamp"].replace("Z", "+00:00"))
    except Exception:
        return False, "timestamp not valid"

    if not isinstance(data["temperature_c"], (int, float)):
        return False, "temperature not valid"

    pos = data["position"]
    if not isinstance(pos, dict):
        return False, "position not valid"

    if not isinstance(pos.get("lat"), (int, float)):
        return False, "lat not valid"

    if not isinstance(pos.get("lon"), (int, float)):
        return False, "lon not valid"

    return True, None

# ==============================
# ENDPOINT PRINCIPALE
# ==============================

@app.route("/data", methods=["POST"])
def receive_data():

    # -------- FASE 1: NON SICURA --------
    if MODE == "insecure":
        try:
            data = request.get_json(force=True)
        except Exception:
            return jsonify({"status": "error", "message": "Invalid JSON"}), 400

        now = datetime.now().isoformat(timespec="seconds")
        line = f"[{now}] RECEIVED (INSECURE): {data}"
        print(line)
        log_line(line)

        return jsonify({"status": "ok", "received_at": now}), 200

    # -------- FASE 2: SICURA --------
    if MODE == "secure":

        # 1) API KEY
        if not check_api_key(request):
            return jsonify({"ok": False, "error": "Missing or invalid API key"}), 401

        # 2) JSON valido
        try:
            data = request.get_json(force=True)
        except Exception:
            return jsonify({"ok": False, "error": "Invalid JSON"}), 400

        # 3) Validazione payload
        valid, error = validate_payload(data)
        if not valid:
            return jsonify({"ok": False, "error": error}), 400

        # 4) Device autorizzato
        if not check_device(data["device_id"]):
            return jsonify({"ok": False, "error": "device not authorized"}), 403
        # 5) Anti-replay
        ok, error = check_replay(data["timestamp"])
        if not ok:
            return jsonify({"ok": False, "error": error}), 401

        now = datetime.now().isoformat(timespec="seconds")
        line = f"[{now}] RECEIVED (SECURE): {data}"
        print(line)
        log_line(line)

        return jsonify({"ok": True}), 200


@app.route("/", methods=["GET"])
def home():
    return f"Gateway IoT running (MODE={MODE})", 200


# ==============================
# AVVIO SERVER
# ==============================

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)

# =========================
# FASE 2 - SICUREZZA
# =========================

API_KEY = "super-secret-key"
ALLOWED_DEVICES = {"collar-001"}
MAX_SKEW_SECONDS = 30  # finestra anti-replay (30s)

# =========================
# ALTRO ENDPOINT 
# =========================

@app.route("/data-secure", methods=["POST"])
def receive_data_secure():

    # 1. API KEY
    api_key = request.headers.get("X-API-Key")
    if api_key != API_KEY:
        return jsonify({"error": "Invalid API key", "ok": False}), 401

    # 2. JSON
    try:
        data = request.get_json(force=True)
    except Exception:
        return jsonify({"error": "Invalid JSON", "ok": False}), 400

    # 3. VALIDAZIONE CAMPI
    required = {"device_id", "timestamp", "temperature_c", "position"}
    if not required.issubset(data):
        return jsonify({"error": "Missing fields", "ok": False}), 400

    # 4. DEVICE WHITELIST
    if not is_valid_device(data["device_id"]):
        return jsonify({"error": "Unauthorized device", "ok": False}), 403

    # 5. ANTI-REPLAY
    if not is_fresh_timestamp(data["timestamp"]):
        return jsonify({"error": "Replay detected", "ok": False}), 409

    now = datetime.utcnow().isoformat(timespec="seconds")
    line = f"[SECURE {now}] RECEIVED: {data}"
    print(line)
    log_line(line)

    return jsonify({"ok": True, "received_at": now}), 200
