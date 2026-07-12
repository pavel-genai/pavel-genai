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

# deletes are tombstone writes, so deleting a missing key is idempotent
DELETE http://localhost:4001/kv/hurl-smoke
HTTP 200
[Asserts]
jsonpath "$.status" == "deleted"

# --- structured values and overwrites ---

PUT http://localhost:4001/kv/hurl-struct
Content-Type: application/json
{
  "value": {"nested": [1, 2, 3], "flag": true}
}
HTTP 200

GET http://localhost:4001/kv/hurl-struct
HTTP 200
[Asserts]
jsonpath "$.value.nested[2]" == 3
jsonpath "$.value.flag" == true

# last write wins
PUT http://localhost:4001/kv/hurl-struct
Content-Type: application/json
{
  "value": "overwritten"
}
HTTP 200

GET http://localhost:4001/kv/hurl-struct
HTTP 200
[Asserts]
jsonpath "$.value" == "overwritten"

DELETE http://localhost:4001/kv/hurl-struct
HTTP 200

# unknown routes fall through to 404
GET http://localhost:4001/definitely/not/a/route
HTTP 404
[Asserts]
jsonpath "$.error" == "not_found"
