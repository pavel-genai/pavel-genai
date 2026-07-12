# block-indexer (port 8081): the Docker image ships without block JSON
# files, so the index is empty — these tests pin the API contract
# (health + 404 semantics for unknown resources).

GET http://localhost:8081/health
HTTP 200
[Asserts]
jsonpath "$.status" == "ok"
jsonpath "$.service" == "block-indexer"

GET http://localhost:8081/blocks/999999
HTTP 404

GET http://localhost:8081/transactions/0xdoesnotexist
HTTP 404

GET http://localhost:8081/address/0xnobody/transactions
HTTP 404

# block number must be numeric ({number} is a long)
GET http://localhost:8081/blocks/notanumber
HTTP 400
