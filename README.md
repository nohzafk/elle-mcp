# Elle MCP Server

[MCP](https://modelcontextprotocol.io/) server for Elle semantic analysis,
backed by an RDF knowledge graph (oxigraph) and program transformation tools.

## Requirements

- [Elle](https://github.com/elle-lisp/elle) binary on PATH
- Plugins: `elle-oxigraph`, `elle-syn` (from [elle-lisp/plugins](https://github.com/elle-lisp/plugins))

## Usage

```sh
elle mcp-server.lisp
```

The server communicates via JSON-RPC 2.0 on stdin/stdout.

### Shared daemon

Every stdio client starts its own server, and every server rebuilds the
knowledge graph at startup. To let several MCP clients share one process
and one graph, listen on a socket instead:

```sh
elle mcp-server.lisp --listen unix:///tmp/elle-mcp.sock
elle mcp-server.lisp --listen tcp://127.0.0.1:7331
```

Each connection gets the same JSON-RPC line protocol as stdio, served in
its own fiber; requests on one connection never see another's answers, and
a client closing does not stop the server. A stale unix socket path is
unlinked on start. `tcp://` has no authentication, so bind it to the
loopback address only.

`--listen` and its value are stripped from the argument list before the
store path is read, so `elle mcp-server.lisp --listen unix:///run/e.sock -- ./store`
works as before.

## Tools exposed

| Tool | Purpose |
|------|---------|
| `ping` | Health check |
| `sparql_query` | SPARQL SELECT / ASK / CONSTRUCT |
| `sparql_update` | SPARQL UPDATE (INSERT DATA, DELETE, etc.) |
| `load_rdf` | Load RDF data (turtle/ntriples/nquads/rdfxml) |
| `dump_rdf` | Serialize the store |
| `analyze_file` | Extract RDF triples from Elle/Rust source |
| `portrait` | Symbol portrait (what is this symbol?) |
| `signal_query` | Signal analysis (what properties does this have?) |
| `impact` | Impact analysis (what breaks if I change this?) |
| `verify_invariants` | Invariant verification |
| `compile_rename` | Rename refactoring |
| `compile_extract` | Extract refactoring |
| `compile_parallelize` | Parallelize refactoring |
| `trace` | Runtime trace |

## Testing

```sh
elle test-mcp.lisp [path-to-elle-binary]
```

## Graph extraction

```sh
# Extract Elle source graph
elle elle-graph.lisp path/to/file.lisp

# Extract Rust source graph (requires elle-syn plugin)
elle rust-graph.lisp path/to/file.rs

# Load both into oxigraph store
elle load-all.lisp
```
