---
title: "Articles"
date: 2026-03-13T18:30:42+08:00
menu:
  sidebar:
    name: "Articles"
    identifier: articles-recent-20260313
    weight: 10
tags: ["Links", "Kafka", "UNIX", "Postgres", "Go", "Context", "WASM"]
categories: ["Links", "Kafka", "UNIX", "Postgres", "Go", "Context", "WASM"]
---

- [You don't need Kafka: Building a message queue with only two UNIX signals](https://leandronsp.com/articles/you-dont-need-kafka-building-a-message-queue-with-only-two-unix-signals)
- [It's 2026, Just Use Postgres](https://www.tigerdata.com/blog/its-2026-just-use-postgres)
- [What canceled my Go context?](https://rednafi.com/go/context-cancellation-cause/)
- [Notes on Writing Wasm](https://notes.brooklynzelenka.com/Blog/Notes-on-Writing-Wasm)
- [Go 1.26 interactive tour](https://antonz.org/go-1-26/)

## It's 2026, Just Use Postgres

### The "Use the Right Tool" Trap

You've heard the advice: "Use the right tool for the right job."

Sounds wise. So you end up with:

1. Elasticsearch for search
2. Pinecone for vectors
3. Redis for caching
4. MongoDB for documents
5. Kafka for queues
6. InfluxDB for time-series
7. PostgreSQL for… the stuff that's left

Here's what most people don't realize: Postgres extensions use the same or better algorithms as specialized databases (in many cases).

| What You Need    | Specialized Tool | Postgres Extension       | Same Algorithm?                 |
| ---------------- | ---------------- | ------------------------ | ------------------------------- |
| Full-text search | Elasticsearch    | pg_textsearch            | ✅ Both use BM25                |
| Vector search    | Pinecone         | pgvector + pgvectorscale | ✅ Both use HNSW/DiskANN        |
| Time-series      | InfluxDB         | TimescaleDB              | ✅ Both use time partitioning   |
| Caching          | Redis            | UNLOGGED tables          | ✅ Both use in-memory storage   |
| Documents        | MongoDB          | JSONB                    | ✅ Both use document indexing   |
| Geospatial       | Specialized GIS  | PostGIS                  | ✅ Industry standard since 2001 |

### Quick Start: Add These Extensions

```sql
-- Full-text search with BM25
CREATE EXTENSION pg_textsearch;

-- Vector search for AI
CREATE EXTENSION vector;
CREATE EXTENSION vectorscale;

-- AI embeddings & RAG workflows
CREATE EXTENSION ai;

-- Time-series
CREATE EXTENSION timescaledb;

-- Message queues
CREATE EXTENSION pgmq;

-- Scheduled jobs
CREATE EXTENSION pg_cron;

-- Geospatial
CREATE EXTENSION postgis;
```

## What canceled my Go context?

### Attaching a cause with WithCancelCause

```go
func processOrder(ctx context.Context, orderID string) error {
    ctx, cancel := context.WithCancelCause(ctx)
    defer cancel(nil)  // (1)

    if err := checkInventory(ctx, orderID); err != nil {
        cancel(fmt.Errorf(
            "order %s: inventory check failed: %w", orderID, err,
        ))  // (2)
        return err
    }
    if err := chargePayment(ctx, orderID); err != nil {
        cancel(fmt.Errorf(
            "order %s: payment failed: %w", orderID, err,
        ))
        return err
    }
    return shipOrder(ctx, orderID)
}

```

`order ord-123: inventory check failed: connection refused`

## Go 1.26 interactive tour

### new(expr)

```go
p := new(42)
```

### Recursive type constraints

```go
type Ordered[T Ordered[T]] interface {
    Less(T) bool
}
```

### Type-safe error checking

```go
// go 1.26+
func AsType[E error](err error) (E, bool)

// using errors.As
var target *AppError
if errors.As(err, &target) {
    fmt.Println("application error:", target)
}

// using errors.AsType
if target, ok := errors.AsType[*AppError](err); ok {
    fmt.Println("application error:", target)
}

if connErr, ok := errors.AsType[*net.OpError](err); ok {
    fmt.Println("Network operation failed:", connErr.Op)
} else if dnsErr, ok := errors.AsType[*net.DNSError](err); ok {
    fmt.Println("DNS resolution failed:", dnsErr.Name)
} else {
    fmt.Println("Unknown error")
}
```

### Secret mode

> The current secret.Do implementation only supports Linux (amd64 and arm64). On unsupported platforms, Do invokes the function directly. Also, trying to start a goroutine within the function causes a panic (this will be fixed in Go 1.27).

```go
// DeriveSessionKey does an ephemeral key exchange to create a session key.
func DeriveSessionKey(peerPublicKey *ecdh.PublicKey) (*ecdh.PublicKey, []byte, error) {
    var pubKey *ecdh.PublicKey
    var sessionKey []byte
    var err error

    // Use secret.Do to contain the sensitive data during the handshake.
    // The ephemeral private key and the raw shared secret will be
    // wiped out when this function finishes.
    secret.Do(func() {
        // 1. Generate an ephemeral private key.
        // This is highly sensitive; if leaked later, forward secrecy is broken.
        privKey, e := ecdh.P256().GenerateKey(rand.Reader)
        if e != nil {
            err = e
            return
        }

        // 2. Compute the shared secret (ECDH).
        // This raw secret is also highly sensitive.
        sharedSecret, e := privKey.ECDH(peerPublicKey)
        if e != nil {
            err = e
            return
        }

        // 3. Derive the final session key (e.g., using HKDF).
        // We copy the result out; the inputs (privKey, sharedSecret)
        // will be destroyed by secret.Do when they become unreachable.
        sessionKey = performHKDF(sharedSecret)
        pubKey = privKey.PublicKey()
    })

    // The session key is returned for use, but the "recipe" to recreate it
    // is destroyed. Additionally, because the session key was allocated
    // inside the secret block, the runtime will automatically zero it out
    // when the application is finished using it.
    return pubKey, sessionKey, err
}
```

### Reader-less cryptography

```go
// Generate a new ECDSA private key for the specified curve.
key, _ := ecdsa.GenerateKey(elliptic.P256(), rand.Reader)
fmt.Println(key.D)

// Generate a 64-bit integer that is prime with high probability.
prim, _ := rand.Prime(rand.Reader, 64)
fmt.Println(prim)
```

```go
// The reader parameter is no longer used, so you can just pass nil.

// Generate a new ECDSA private key for the specified curve.
key, _ := ecdsa.GenerateKey(elliptic.P256(), nil)
fmt.Println(key.D)

// Generate a 64-bit integer that is prime with high probability.
prim, _ := rand.Prime(nil, 64)
fmt.Println(prim)
```

### Hybrid public key encryption

> The new `crypto/hpke` package implements Hybrid Public Key Encryption (HPKE) as specified in [RFC 9180](https://www.rfc-editor.org/rfc/rfc9180.html).

### Reflective iterators

```go
// List the fields of a struct type.
typ := reflect.TypeFor[http.Client]()
for f := range typ.Fields() {
    fmt.Println(f.Name, f.Type)
}

// List the methods of a struct type.
typ := reflect.TypeFor[*http.Client]()
for m := range typ.Methods() {
    fmt.Println(m.Name, m.Type)
}

typ := reflect.TypeFor[filepath.WalkFunc]()

fmt.Println("Inputs:")
for par := range typ.Ins() {
    fmt.Println("-", par.Name())
}

fmt.Println("Outputs:")
for par := range typ.Outs() {
    fmt.Println("-", par.Name())
}
```

### Peek into a buffer

```go
buf := bytes.NewBufferString("I love bytes")

sample, err := buf.Peek(1)
fmt.Printf("peek=%s err=%v\n", sample, err)

buf.Next(2)

sample, err = buf.Peek(4)
fmt.Printf("peek=%s err=%v\n", sample, err)
```

```shell
peek=I err=<nil>
peek=love err=<nil>
```

### Compare IP subnets

```go
prefixes := []netip.Prefix{
    netip.MustParsePrefix("10.1.0.0/16"),
    netip.MustParsePrefix("203.0.113.0/24"),
    netip.MustParsePrefix("10.0.0.0/16"),
    netip.MustParsePrefix("169.254.0.0/16"),
    netip.MustParsePrefix("203.0.113.0/8"),
}

slices.SortFunc(prefixes, netip.Prefix.Compare)
```

### Optimized fmt.Errorf

> https://go.dev/cl/708836

### Modernized `go fix`

```shell
# only enable the forvar analyzer
go fix -forvar .

# enable all analyzers except omitzero
go fix -omitzero=false .
```
