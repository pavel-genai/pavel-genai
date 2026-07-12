# stream-processor (port 8086): POST events (stdin JSON-line format),
# then observe windowed aggregates. State accumulates for the process
# lifetime; asserts are written to hold on re-runs.

GET http://localhost:8086/health
HTTP 200
[Asserts]
jsonpath "$.status" == "ok"
jsonpath "$.service" == "stream-processor"

# single event
POST http://localhost:8086/events
Content-Type: application/json
{
  "timestamp": 1000,
  "key": "hurl-sensor",
  "payload": 10.5
}
HTTP 202
[Asserts]
jsonpath "$.accepted" isInteger

# batch of events
POST http://localhost:8086/events
Content-Type: application/json
[
  {"timestamp": 2000, "key": "hurl-sensor", "payload": 20.0},
  {"timestamp": 3000, "key": "hurl-sensor", "payload": 30.0}
]
HTTP 202
[Asserts]
jsonpath "$.accepted" isInteger

GET http://localhost:8086/aggregates
HTTP 200
[Asserts]
jsonpath "$" count >= 1
jsonpath "$[0].key" exists
jsonpath "$[0].window_start" exists
jsonpath "$[0].value" exists

# malformed event body is a 400
POST http://localhost:8086/events
Content-Type: application/json
{
  "not_an_event": true
}
HTTP 400
[Asserts]
jsonpath "$.error" exists
