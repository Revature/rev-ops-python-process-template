# Rev-Ops Process Template

Template repository for rev-ops process code. Cloned into CDE (code-server) when an admin creates a new process.

## Structure

```
pre_process/
  main.py    — runs before user fills the form
post_process/
  main.py    — runs after user submits the form
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `FORM_DATA` | JSON string of form data (empty for pre-process) |
| `CONTEXT` | JSON with `record_id`, `phase`, `process_api_name`, `pre_result` (post only) |
| `<secret_name>` | Any secrets assigned to the process phase |

## Output

Print a JSON object on the **last line** of stdout. The executor parses this as the result.

- **Pre-process**: Keys matching field `api_name`s will auto-fill the form
- **Post-process**: Stored as the execution's `post_result`
