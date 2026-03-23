#!/bin/bash
# Sync process code back to the Rev-Ops platform.
# Can be run from the terminal or by the AI assistant.

set -e

CONFIG_FILE="$HOME/.revops.config"
if [ ! -f "$CONFIG_FILE" ]; then
    echo "ERROR: $CONFIG_FILE not found. Use the Sync Code button in the VS Code extension instead."
    exit 1
fi

BACKEND_URL=$(python3 -c "import json; print(json.load(open('$CONFIG_FILE'))['backendUrl'])")
AUTH_TOKEN=$(python3 -c "import json; print(json.load(open('$CONFIG_FILE'))['authToken'])")
USER_ID=$(python3 -c "import json; print(json.load(open('$CONFIG_FILE'))['userId'])")

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "Syncing process code to Rev-Ops..."

python3 -c "
import json, os, sys, urllib.request

script_dir = sys.argv[1]
backend_url = sys.argv[2]
auth_token = sys.argv[3]
user_id = sys.argv[4]

# Read pre and post process code
pre_code = None
post_code = None

pre_path = os.path.join(script_dir, 'pre_process', 'main.py')
if os.path.isfile(pre_path):
    with open(pre_path, 'r') as f:
        pre_code = f.read()

post_path = os.path.join(script_dir, 'post_process', 'main.py')
if os.path.isfile(post_path):
    with open(post_path, 'r') as f:
        post_code = f.read()

if not pre_code and not post_code:
    print('ERROR: No process code found in pre_process/ or post_process/')
    sys.exit(1)

payload = json.dumps({
    'runner_id': '',
    'user_id': user_id,
    'project_type': 'process',
    'pre_process_code': pre_code,
    'post_process_code': post_code,
}).encode()

req = urllib.request.Request(
    f'{backend_url}/api/admin/cde/sync-code',
    data=payload,
    headers={
        'Authorization': f'Bearer {auth_token}',
        'Content-Type': 'application/json',
    },
)

try:
    with urllib.request.urlopen(req, timeout=30) as resp:
        result = json.loads(resp.read().decode())
        synced = []
        if pre_code: synced.append('pre_process')
        if post_code: synced.append('post_process')
        print(f'Synced {', '.join(synced)} at {result.get(\"synced_at\", \"now\")}')
except Exception as e:
    print(f'ERROR: Sync failed: {e}', file=sys.stderr)
    sys.exit(1)
" "$SCRIPT_DIR" "$BACKEND_URL" "$AUTH_TOKEN" "$USER_ID"

echo "Done! You can now proceed to Review & Create in the wizard."
