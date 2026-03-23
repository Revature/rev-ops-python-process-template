# Rev-Ops Process Script Development Rules

You are helping an admin build **Python process scripts** for the Rev-Ops platform. Process scripts run in a sandboxed executor (Docker container) with a 30-second timeout.

## Project Structure

```
pre_process/
  main.py    — Runs BEFORE the user fills the form
post_process/
  main.py    — Runs AFTER the user submits the form
```

## How It Works

1. Admin triggers a process on a record
2. **Pre-process** runs → output auto-fills form fields
3. User fills out / edits the form (React component)
4. **Post-process** runs → can call external APIs, update records, etc.

## Environment Variables

Scripts receive data via environment variables:

- `FORM_DATA` — JSON string of form data (empty `{}` for pre-process, submitted data for post-process)
- `CONTEXT` — JSON string with execution metadata:
  - `record_id` — ID of the record being processed
  - `phase` — `"pre"` or `"post"`
  - `process_api_name` — API name of the process
  - `pre_result` — (post-process only) result from pre-process script
- `<secret_name>` — Any secrets assigned to this phase are available as env vars by name

## Output Contract

Print a **single JSON object on the last line of stdout**. The executor parses only the last line.

**Pre-process output:** Keys matching field `api_name`s will auto-fill the form.
```python
print(json.dumps({"status": "Active", "company": "Fetched from API"}))
```

**Post-process output:** Stored as the execution's `post_result`.
```python
print(json.dumps({"success": True, "message": "Synced to Salesforce"}))
```

## Rules

1. **Python 3.11+** — Use modern Python syntax.
2. **JSON output only** — The last line of stdout MUST be valid JSON. Everything else is logged but ignored.
3. **Use `os.environ`** — All input comes from environment variables, not function arguments.
4. **Handle errors gracefully** — Catch exceptions, print a JSON error result, don't let the script crash silently.
5. **30-second timeout** — Scripts that exceed this are killed. Keep external API calls fast.
6. **No file system persistence** — The container is ephemeral. Don't write files expecting them to persist.
7. **Secrets are env vars** — Access them with `os.environ.get("SECRET_NAME")`. Never hardcode API keys.
8. **Standard library + pip packages** — `requests`, `json`, `os`, `datetime` are available. Add dependencies to `requirements.txt` if needed.
9. **Print debugging to stderr** — Use `print("debug info", file=sys.stderr)` for logs that won't interfere with the JSON output.

## Common Patterns

### Call an external API with a secret

```python
import os, json, requests

api_key = os.environ.get("SALESFORCE_API_KEY")
context = json.loads(os.environ.get("CONTEXT", "{}"))

response = requests.get(
    "https://api.example.com/data",
    headers={"Authorization": f"Bearer {api_key}"},
    timeout=10,
)
response.raise_for_status()

print(json.dumps(response.json()))
```

### Use pre-process result in post-process

```python
import os, json

context = json.loads(os.environ.get("CONTEXT", "{}"))
pre_result = context.get("pre_result", {})
form_data = json.loads(os.environ.get("FORM_DATA", "{}"))

# pre_result has data from the pre-process script
enriched_id = pre_result.get("external_id")

print(json.dumps({"success": True, "external_id": enriched_id}))
```

### Error handling

```python
import os, json, sys

try:
    # ... your logic ...
    print(json.dumps({"success": True}))
except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    print(json.dumps({"success": False, "error": str(e)}))
```

## Wizard Workflow

You are inside a **cloud IDE** that is part of a wizard for building processes. Here's how the overall flow works:

1. **Step 0 — Metadata**: Admin sets the process name, selects object, component, and toggles pre/post-process
2. **Step 1 — Secrets** (optional): Admin selects which secrets each phase can access
3. **Step 2 — Code Editor** (you are here): Admin writes pre-process and/or post-process scripts
4. **Step 3 — Review & Create**: Admin reviews and saves the process

### How to sync code back to the platform

After writing or editing code, the admin must **sync** it back to the Rev-Ops platform:

Click the **"Sync Code"** button in the Rev-Ops sidebar panel (left side of the IDE).

**Note:** You (the AI) cannot sync code. Always tell the admin to click the Sync Code button.

### Important workflow notes

- Both `pre_process/main.py` and `post_process/main.py` are synced together
- Code changes are NOT automatically synced — the admin must explicitly sync
- Secrets are injected as environment variables at runtime, not in this IDE
- If the admin asks you to "sync" or "save", remind them to click the **Sync Code** button in the Rev-Ops sidebar panel (left side). You cannot do this for them.
