#!/usr/bin/env bash
set -euo pipefail

TASK_ID="${1:?task id required}"
LANE="${2:?lane required}"
REGISTRY="${3:-.runtime/allocations.json}"
BASE_APP="${BASE_APP_PORT:-4100}"
BASE_API="${BASE_API_PORT:-5100}"
BASE_DB="${BASE_DB_PORT:-6100}"

mkdir -p "$(dirname "$REGISTRY")"
LOCK="${REGISTRY%.json}.lock"

python3 - "$TASK_ID" "$LANE" "$REGISTRY" "$LOCK" "$BASE_APP" "$BASE_API" "$BASE_DB" <<'PY'
import json, os, sys, time, pathlib
task_id, lane, registry_path, lock_path, base_app, base_api, base_db = sys.argv[1], sys.argv[2], sys.argv[3], sys.argv[4], int(sys.argv[5]), int(sys.argv[6]), int(sys.argv[7])

pathlib.Path(os.path.dirname(registry_path) or ".").mkdir(parents=True, exist_ok=True)
for _ in range(50):
    try:
        fd = os.open(lock_path, os.O_CREAT | os.O_EXCL | os.O_WRONLY)
        os.close(fd)
        break
    except FileExistsError:
        time.sleep(0.1)
else:
    raise SystemExit("Failed to acquire runtime allocation lock")

try:
    if not os.path.exists(registry_path):
        with open(registry_path, "w", encoding="utf-8") as f:
            json.dump({"version": 1, "allocations": []}, f, indent=2)
    with open(registry_path, "r", encoding="utf-8") as f:
        registry = json.load(f)

    for entry in registry["allocations"]:
        if entry["task_id"] == task_id and entry["lane"] == lane:
            print(json.dumps(entry, indent=2))
            raise SystemExit(0)

    idx = 0
    while idx <= 500:
        app, api, db = base_app + idx, base_api + idx, base_db + idx
        used = {(e["app_port"], e["api_port"], e["db_port"]) for e in registry["allocations"]}
        if (app, api, db) not in used:
            safe = f"{task_id}_{lane}"
            entry = {
                "task_id": task_id,
                "lane": lane,
                "app_port": app,
                "api_port": api,
                "db_port": db,
                "app_instance_id": f"{task_id}-{lane}",
                "user_data_dir": f".runtime/userdata/{safe}",
                "log_dir": f".runtime/logs/{safe}",
                "tmp_dir": f".runtime/tmp/{safe}",
                "allocated_at": time.strftime("%Y-%m-%dT%H:%M:%S"),
            }
            for d in [entry["user_data_dir"], entry["log_dir"], entry["tmp_dir"]]:
                pathlib.Path(d).mkdir(parents=True, exist_ok=True)
            registry["allocations"].append(entry)
            with open(registry_path, "w", encoding="utf-8") as f:
                json.dump(registry, f, indent=2)
            print(json.dumps(entry, indent=2))
            raise SystemExit(0)
        idx += 1
    raise SystemExit("No runtime port allocation available")
finally:
    if os.path.exists(lock_path):
        os.remove(lock_path)
PY
