"""
Post-Process Script Template

This script runs AFTER the user submits the form.
Use it to send data to external APIs, update records, or trigger workflows.

Available environment variables:
  FORM_DATA   — JSON string of the submitted form data
  CONTEXT     — JSON string with: record_id, phase, process_api_name, pre_result
  <secrets>   — Any secrets assigned to this phase are available by name

Output:
  Print a JSON object on the LAST line of stdout.
  This will be stored as the post_result of the execution.

Example output:
  {"success": true, "message": "Record updated in Salesforce"}
"""
import os
import json

form_data = json.loads(os.environ.get("FORM_DATA", "{}"))
context = json.loads(os.environ.get("CONTEXT", "{}"))
record_id = context.get("record_id")
pre_result = context.get("pre_result", {})

# --- Your post-process logic here ---

# Example: output result
result = {"success": True, "message": "Process completed"}

print(json.dumps(result))
