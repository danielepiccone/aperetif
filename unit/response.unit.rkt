#lang racket

(require
  rackunit
  "../lib/config.rkt"
  "../lib/response.rkt")

  (test-case
    "Init a new response"
    (define test-out (open-output-string))
    (define it (new response% [out-port test-out]))
    (define headers (get-field headers it))
    (check-equal? (hash-ref headers 'Server) "Racket")
    ;(displayln (send it send-error 400))
    (check-equal? 0 0))

  (test-case
    "Send something out"
    (define test-out (open-output-string))
    (define it (new response% [out-port test-out]))
    (send it send-raw "Hello World")
    (check-regexp-match "Hello World" (get-output-string test-out))
    (check-equal? 0 0))

  (test-case
    "Send a raw html file"
    (define test-out (open-output-string))
    (define it (new response% [out-port test-out]))
    (send it send-file (~a base-path "public/sample.html"))
    ;(displayln (get-output-string test-out))
    (define output (get-output-string test-out))
    (check-regexp-match "text/html" output)
    (check-regexp-match "DOCTYPE" output)
    (check-regexp-match "<body>" output)
    (check-regexp-match "Hello" output)
    (check-equal? 0 0))

