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

# wrong method gets a 405 with an Allow header
PUT http://localhost:8086/events
Content-Type: application/json
{
  "timestamp": 1000,
  "key": "x",
  "payload": 1.0
}
HTTP 405
[Asserts]
header "Allow" == "POST"

# --- watermark: late events are dropped ---
# The watermark is global and only advances, so this entry must stay last
# in the file: it pushes the watermark far ahead, which is also why the
# earlier low-timestamp entries assert `accepted isInteger` rather than a
# fixed count (on re-runs they arrive behind the watermark and count 0).

POST http://localhost:8086/events
Content-Type: application/json
{
  "timestamp": 9000000,
  "key": "hurl-watermark",
  "payload": 1.0
}
HTTP 202
[Asserts]
jsonpath "$.accepted" == 1

# 1000 is now far behind the watermark (9000000 - 5000ms lateness)
POST http://localhost:8086/events
Content-Type: application/json
{
  "timestamp": 1000,
  "key": "hurl-watermark",
  "payload": 2.0
}
HTTP 202
[Asserts]
jsonpath "$.accepted" == 0
