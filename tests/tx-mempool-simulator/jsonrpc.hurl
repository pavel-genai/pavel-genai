# tx-mempool-simulator (port 8545): JSON-RPC 2.0 API.
# The pool rejects duplicate sender+nonce pairs and persists for the
# container's lifetime, so the sendTransaction entry only asserts a
# well-formed JSON-RPC envelope (first run: accepted; re-runs: duplicate
# error — both are valid pool behavior). The negative tests and
# getPendingByAddress are deterministic on every run.

POST http://localhost:8545
Content-Type: application/json
{
  "jsonrpc": "2.0",
  "method": "sendTransaction",
  "params": {"sender": "0xHurlSmoke", "nonce": 0, "gasPrice": 50, "size": 200},
  "id": 1
}
HTTP 200
[Asserts]
jsonpath "$.jsonrpc" == "2.0"
jsonpath "$.id" == 1

# sender is required
POST http://localhost:8545
Content-Type: application/json
{
  "jsonrpc": "2.0",
  "method": "sendTransaction",
  "params": {"nonce": 0, "gasPrice": 50},
  "id": 2
}
HTTP 200
[Asserts]
jsonpath "$.error.code" == -32602
jsonpath "$.error.message" contains "sender is required"

# jsonrpc version must be 2.0
POST http://localhost:8545
Content-Type: application/json
{
  "jsonrpc": "1.0",
  "method": "getPoolStatus",
  "params": {},
  "id": 3
}
HTTP 200
[Asserts]
jsonpath "$.error.code" == -32600

GET http://localhost:8545/health
HTTP 200

POST http://localhost:8545
Content-Type: application/json
{
  "jsonrpc": "2.0",
  "method": "getPendingByAddress",
  "params": {"address": "0xHurlSmoke"},
  "id": 4
}
HTTP 200
[Asserts]
jsonpath "$.result" count >= 1
jsonpath "$.result[0].sender" == "0xHurlSmoke"

POST http://localhost:8545
Content-Type: application/json
{
  "jsonrpc": "2.0",
  "method": "getPoolStatus",
  "params": {},
  "id": 5
}
HTTP 200
[Asserts]
jsonpath "$.result" exists
jsonpath "$.error" not exists
