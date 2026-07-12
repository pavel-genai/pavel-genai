# parseql (port 8085): error branches, ORDER BY / LIMIT.
# Uses its own table (hurl_err) so it can run in parallel with
# query-flow.hurl, which owns hurl_smoke.

# cleanup from any earlier aborted run — no asserts on purpose
POST http://localhost:8085/query
`DROP TABLE hurl_err`

POST http://localhost:8085/query
`CREATE TABLE hurl_err (id INT, name TEXT)`
HTTP 200

POST http://localhost:8085/query
`INSERT INTO hurl_err VALUES (1, 'alpha')`
HTTP 200

POST http://localhost:8085/query
`INSERT INTO hurl_err VALUES (2, 'beta')`
HTTP 200

POST http://localhost:8085/query
`INSERT INTO hurl_err VALUES (3, 'gamma')`
HTTP 200

# ORDER BY ... DESC with LIMIT
POST http://localhost:8085/query
`SELECT id, name FROM hurl_err ORDER BY id DESC LIMIT 2`
HTTP 200
[Asserts]
jsonpath "$.row_count" == 2
jsonpath "$.rows[0][0]" == 3
jsonpath "$.rows[0][1]" == "gamma"
jsonpath "$.rows[1][0]" == 2

# the type checker validates INSERT arity
POST http://localhost:8085/query
`INSERT INTO hurl_err VALUES (4)`
HTTP 400
[Asserts]
jsonpath "$.status" == "error"
jsonpath "$.error" contains "expected 2 values"

# querying a table that does not exist
POST http://localhost:8085/query
`SELECT id FROM hurl_no_such_table`
HTTP 400
[Asserts]
jsonpath "$.status" == "error"

POST http://localhost:8085/query
`DROP TABLE hurl_err`
HTTP 200

# empty request body
POST http://localhost:8085/query
``
HTTP 400
[Asserts]
jsonpath "$.error" contains "empty request body"

# /query only accepts POST
GET http://localhost:8085/query
HTTP 405

# unknown routes are 404
GET http://localhost:8085/definitely-not-a-route
HTTP 404
