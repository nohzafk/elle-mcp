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
