# distributed-kvstore (port 4001): put/get/delete round-trip plus ring
# status. Deletes its key at the end, so re-runs are clean.

GET http://localhost:4001/health
HTTP 200
[Asserts]
jsonpath "$.status" == "ok"
jsonpath "$.service" == "distributed-kvstore"

GET http://localhost:4001/ring
HTTP 200
[Asserts]
jsonpath "$.total" >= 1
jsonpath "$.nodes" count >= 1

PUT http://localhost:4001/kv/hurl-smoke
Content-Type: application/json
{
  "value": "hello from hurl"
}
HTTP 200
[Asserts]
jsonpath "$.status" == "ok"
jsonpath "$.key" == "hurl-smoke"

GET http://localhost:4001/kv/hurl-smoke
HTTP 200
[Asserts]
jsonpath "$.value" == "hello from hurl"

# missing "value" in body is rejected
PUT http://localhost:4001/kv/hurl-smoke
Content-Type: application/json
{
  "wrong_field": true
}
HTTP 400
[Asserts]
jsonpath "$.error" exists

DELETE http://localhost:4001/kv/hurl-smoke
HTTP 200
[Asserts]
jsonpath "$.status" == "deleted"

GET http://localhost:4001/kv/hurl-smoke
HTTP 404
[Asserts]
jsonpath "$.error" == "not_found"
