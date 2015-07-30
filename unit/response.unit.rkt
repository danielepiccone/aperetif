#lang racket

(require rackunit "../lib/response.rkt")

(let
  ([test-out (current-output-port)])

  (test-case
    "Init a new response"
    (define it (new response% [out-port test-out]))
    (define headers (get-field headers it))
    (check-equal? (hash-ref headers 'Server) "Racket")
    ;(displayln (send it send-error 400))
    (check-equal? 0 0))
  )
