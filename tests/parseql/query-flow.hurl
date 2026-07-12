# parseql (port 8085): POST /query takes a raw SQL statement as the
# body; the database lives for the process lifetime. The suite creates
# its own table and drops it at the end.

GET http://localhost:8085/health
HTTP 200
[Asserts]
jsonpath "$.status" == "ok"
jsonpath "$.service" == "parseql"

# cleanup from any earlier aborted run — no asserts on purpose
POST http://localhost:8085/query
`DROP TABLE hurl_smoke`

POST http://localhost:8085/query
`CREATE TABLE hurl_smoke (id INT, name TEXT)`
HTTP 200
[Asserts]
jsonpath "$.status" == "ok"

POST http://localhost:8085/query
`INSERT INTO hurl_smoke VALUES (1, 'alice')`
HTTP 200
[Asserts]
jsonpath "$.status" == "ok"

POST http://localhost:8085/query
`INSERT INTO hurl_smoke VALUES (2, 'bob')`
HTTP 200
[Asserts]
jsonpath "$.status" == "ok"

POST http://localhost:8085/query
`SELECT name FROM hurl_smoke WHERE id = 2`
HTTP 200
[Asserts]
jsonpath "$.status" == "ok"
jsonpath "$.columns[0]" == "name"
jsonpath "$.rows[0][0]" == "bob"
jsonpath "$.row_count" == 1

POST http://localhost:8085/query
`DROP TABLE hurl_smoke`
HTTP 200
[Asserts]
jsonpath "$.status" == "ok"

# syntax errors come back as 400
POST http://localhost:8085/query
`SELEC oops FRM nowhere`
HTTP 400
[Asserts]
jsonpath "$.status" == "error"
jsonpath "$.error" exists
