# job-scheduler (port 4000): full CRUD flow — create, list, get,
# delete — plus cron validation. Cleans up after itself.

GET http://localhost:4000/health
HTTP 200
[Asserts]
jsonpath "$.status" == "ok"
jsonpath "$.service" == "job-scheduler"

POST http://localhost:4000/jobs
Content-Type: application/json
{
  "name": "hurl-smoke-test"
}
HTTP 201
[Captures]
job_id: jsonpath "$.job.id"
[Asserts]
jsonpath "$.ok" == true
jsonpath "$.job.name" == "hurl-smoke-test"

GET http://localhost:4000/jobs
HTTP 200
[Asserts]
jsonpath "$.count" >= 1

GET http://localhost:4000/jobs/{{job_id}}
HTTP 200
[Asserts]
jsonpath "$.job.id" == "{{job_id}}"
jsonpath "$.job.name" == "hurl-smoke-test"

GET http://localhost:4000/status
HTTP 200
[Asserts]
jsonpath "$.status" == "running"
jsonpath "$.total_jobs" >= 1

# invalid cron expressions are rejected (and not stored)
POST http://localhost:4000/jobs
Content-Type: application/json
{
  "name": "hurl-bad-cron",
  "cron": "not a cron"
}
HTTP 400
[Asserts]
jsonpath "$.error" contains "Invalid cron"

DELETE http://localhost:4000/jobs/{{job_id}}
HTTP 200
[Asserts]
jsonpath "$.ok" == true

GET http://localhost:4000/jobs/{{job_id}}
HTTP 404
[Asserts]
jsonpath "$.error" == "Job not found"

# --- DAG cycle detection ---

# first job depends on a not-yet-existing second job — allowed
POST http://localhost:4000/jobs
Content-Type: application/json
{
  "id": "hurl-dag-a",
  "name": "hurl-dag-a",
  "deps": ["hurl-dag-b"]
}
HTTP 201
[Asserts]
jsonpath "$.ok" == true

# closing the loop is rejected
POST http://localhost:4000/jobs
Content-Type: application/json
{
  "id": "hurl-dag-b",
  "name": "hurl-dag-b",
  "deps": ["hurl-dag-a"]
}
HTTP 400
[Asserts]
jsonpath "$.error" contains "would create a cycle"

DELETE http://localhost:4000/jobs/hurl-dag-a
HTTP 200

# --- retry policy is stored on the job ---

POST http://localhost:4000/jobs
Content-Type: application/json
{
  "name": "hurl-retry",
  "retry_policy": {"max_retries": 2, "backoff_ms": 100}
}
HTTP 201
[Captures]
retry_job_id: jsonpath "$.job.id"
[Asserts]
jsonpath "$.job.max_retries" == 2
jsonpath "$.job.backoff_ms" == 100

DELETE http://localhost:4000/jobs/{{retry_job_id}}
HTTP 200
