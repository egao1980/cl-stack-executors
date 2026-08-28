# cl-stack-executors

MIT. BT thread pools — Java `Executor` / Python `concurrent.futures`.

Package: `cl-stack-executors` (nick `stack-executors`).

**Not** part of [`event-protocol`](https://github.com/egao1980/event-protocol).
`event-protocol:submit` takes `:executor` as a **function of one thunk** (or
`nil` → backend default). This library is what backends *may* plug in for that
default — same relationship as `concurrent.futures` next to asyncio.

Per-instance pools. Do not share one process-global pool across event loops.

## API

```lisp
(make-thread-pool &key (workers 4) name)   ; bounded workers, unbounded FIFO
(make-inline-executor)                     ; caller thread (tests)

(executor-submit executor thunk)
(executor-shutdown executor &key (wait t))
(executor-running-p executor)
(executor-length executor)                 ; queued, not running; NIL if unknown

(executor-runner executor)                 ; → (lambda (thunk) (executor-submit …))
```

```lisp
;; event-protocol :executor
(event:submit backend loop thunk
              :callback #'on-loop
              :executor (stack-executors:executor-runner pool))
```

One BT pin: `bordeaux-threads` 0.9.4 (OCI via cl-stack-systems).

## Tests

```bash
sbcl --eval '(asdf:load-asd "cl-stack-executors.asd")' \
     --eval '(asdf:test-system "cl-stack-executors")'
```

## Publish

```bash
gh workflow run publish-checkout.yml -R egao1980/cl-stack-executors
```
