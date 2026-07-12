# p2p-gossip-protocol: the protocol itself runs over UDP (port 7946);
# the only HTTP surface is the health endpoint on port 8083.

GET http://localhost:8083/health
HTTP 200
[Asserts]
jsonpath "$.status" == "ok"
jsonpath "$.service" == "p2p-gossip-protocol"
