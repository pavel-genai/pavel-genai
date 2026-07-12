# Integration tests

Black-box HTTP integration tests for the services in `docker-compose.yml`,
written as [Hurl](https://hurl.dev) files — one directory per service, each
suite self-contained (no shared state between services or files).

## Setup

```bash
brew install hurl   # single binary, no runtime dependencies
```

## Running

```bash
make up                # start the stack (wait for healthchecks to go green)
make test              # run all suites
make test-sql-parser   # run one service's suite (test-<service-dir>)
```

Or directly, without make:

```bash
hurl --test tests/*/*.hurl
hurl --test tests/markdown-cms/*.hurl
```

Useful flags: `--report-html <dir>` or `--report-junit <file>` for CI
reports, `--verbose` to see full requests/responses on failure.

## Conventions

- Tests hit the host ports published in `docker-compose.yml`
  (e.g. search-engine on 8080, markdown-cms on 3000).
- Each `.hurl` file is a self-contained scenario; entries within a file run
  in order, and captures (`[Captures]`) carry values between steps.
- Suites are written to be idempotent: they clean up what they create
  (kvstore keys, scheduler jobs, SQL tables) or use tolerant asserts where
  service state accumulates across runs (search index, mempool, aggregates).

## Coverage notes

- **rate-limiter-service**: its real API is gRPC on 50051, which Hurl can't
  speak — only the HTTP health endpoint (8082) is covered. Use `grpcurl`
  for the gRPC surface.
- **block-indexer**: the Docker image ships no block data, so the suite
  pins health and 404 contract behavior only.
- **p2p-gossip-protocol**: the protocol runs over UDP; only the HTTP
  health endpoint (8083) is covered.
- **dns-resolver / raft-consensus**: one-shot CLI tools with no HTTP
  surface — not covered here.
