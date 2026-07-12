# rate-limiter-service: the real API is gRPC on port 50051 (Hurl is
# HTTP-only — use grpcurl for that surface). This covers the HTTP
# health endpoint on port 8082.

GET http://localhost:8082/health
HTTP 200
[Asserts]
jsonpath "$.status" == "ok"
jsonpath "$.service" == "rate-limiter-service"
