(elle/epoch 8)
#!/usr/bin/env elle
## test-semantic.lisp — exercise the semantic MCP tools via subprocess
##
## Spawns the MCP server, sends requests, prints results.

(defn make-request [id method params]
  (json/serialize {:jsonrpc "2.0" :id id :method method :params params}))

(defn parse-response [line]
  (json/parse line))

(defn get-text [response]
  "Extract text content from an MCP tool result."
  (def @result (get response "result"))
  (when result
    (def @content (get result "content"))
    (when content
      (get (get content 0) "text"))))

# ── Spawn the server ────────────────────────────────────────────────────

(def @proc (subprocess/exec "tools/run-elle.sh"
  ["tools/mcp-server.lisp"]
  {:stdin :pipe :stdout :pipe :stderr :null}))

(def @pin (get proc :stdin))
(def @pout (get proc :stdout))

(defn send [id method params]
  (port/write pin (string (make-request id method params) "\n"))
  (port/flush pin))

(defn recv []
  (def @line (port/read-line pout))
  (when (not (nil? line))
    (parse-response line)))

# ── Initialize ──────────────────────────────────────────────────────────

(send 1 "initialize" {})
(def @init (recv))
(println "Server:" (get (get (get init "result") "serverInfo") "name")
         (get (get (get init "result") "serverInfo") "version"))
(println)

# ── Analyze a file ──────────────────────────────────────────────────────

(send 2 "tools/call" {"name" "analyze_file"
                       "arguments" {"path" "examples/signals.lisp"}})
(def @r2 (recv))
(println "── analyze_file ──")
(println (get-text r2))
(println)

# ── Module portrait ─────────────────────────────────────────────────────

(send 3 "tools/call" {"name" "portrait"
                       "arguments" {"path" "examples/signals.lisp"}})
(def @r3 (recv))
(println "── module portrait ──")
(println (get-text r3))
(println)

# ── Function portrait ───────────────────────────────────────────────────

(send 4 "tools/call" {"name" "portrait"
                       "arguments" {"path" "examples/signals.lisp"
                                    "function" "safe-map"}})
(def @r4 (recv))
(println "── portrait: safe-map ──")
(println (get-text r4))
(println)

# ── Signal query ────────────────────────────────────────────────────────

(send 5 "tools/call" {"name" "signal_query"
                       "arguments" {"path" "examples/signals.lisp"
                                    "query" "silent"}})
(def @r5 (recv))
(println "── signal_query: silent ──")
(println (get-text r5))
(println)

# ── Impact ──────────────────────────────────────────────────────────────

(send 6 "tools/call" {"name" "impact"
                       "arguments" {"path" "examples/functions.lisp"
                                    "function" "letter-grade"}})
(def @r6 (recv))
(println "── impact: letter-grade ──")
(println (get-text r6))

# ── Cleanup ─────────────────────────────────────────────────────────────

(subprocess/kill proc)
(println)
(println "done")
