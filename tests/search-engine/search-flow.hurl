# search-engine (port 8080): index a document, find it, check stats.
# Note: the index persists inside the container, so re-runs accumulate
# duplicate documents — asserts use >= and token-based lookups.

GET http://localhost:8080/health
HTTP 200
[Asserts]
jsonpath "$.status" == "ok"
jsonpath "$.service" == "search-engine"

POST http://localhost:8080/index
Content-Type: application/json
{
  "title": "Hurl Smoke Test",
  "text": "hurlsmoketoken appears in this integration test document about inverted indexes"
}
HTTP 200
[Asserts]
jsonpath "$.docId" isInteger
jsonpath "$.message" == "Document indexed successfully"

# text is required
POST http://localhost:8080/index
Content-Type: application/json
{
  "title": "No Text"
}
HTTP 400
[Asserts]
jsonpath "$.error" exists

GET http://localhost:8080/search?q=hurlsmoketoken
HTTP 200
[Asserts]
jsonpath "$.totalResults" >= 1
jsonpath "$.results[0].title" == "Hurl Smoke Test"
jsonpath "$.results[0].score" > 0

# blank query is rejected
GET http://localhost:8080/search?q=
HTTP 400
[Asserts]
jsonpath "$.error" exists

GET http://localhost:8080/stats
HTTP 200
[Asserts]
jsonpath "$.totalDocuments" >= 1
jsonpath "$.totalTerms" >= 1
