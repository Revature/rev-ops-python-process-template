"""
Pre-Process Script Template

This script runs BEFORE the user fills out the form.
Use it to auto-fill fields, validate preconditions, or fetch external data.

Available environment variables:
  FORM_DATA  — JSON string of form data (empty for pre-process)
  CONTEXT    — JSON string with: record_id, phase, process_api_name
  <secrets>  — Any secrets assigned to this phase are available by name

Output:
  Print a JSON object on the LAST line of stdout.
  Keys matching field api_names will auto-fill the form.

Example output:
  {"status": "Active", "company": "Fetched from API"}
"""
import os
import json

context = json.loads(os.environ.get("CONTEXT", "{}"))
record_id = context.get("record_id")

# --- Your pre-process logic here ---

# Example: output fields to auto-fill
result = {}

print(json.dumps(result))
