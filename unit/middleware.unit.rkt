#lang racket/base

(require racket/class)

(require
  "../lib/config.rkt"
  "../lib/request.rkt"
  "../lib/response.rkt"
  "../lib/dispatcher.rkt"
  "../lib/middleware.rkt")

(require rackunit)

(define
  http-pub (build-path base-path "./public"))

(define static (static-middleware http-pub))

(test-case
  "Static middleware should serve files from filesystem"
  (define test-out (open-output-string))
  (define incoming-tcp
    (open-input-bytes #"GET /static/sample.html HTTP/1.1\r\n\r\n"))
  (define req (new request% [in-port incoming-tcp]))
  (define res (new response% [out-port test-out]))
  ; Assume this has been dispatched to /static
  ; TODO write a test in dispatcher for this field
  (set-field! route req "/static")
  (static req res)
  (define output (get-output-string test-out))
  (check-regexp-match "text/html" output)
  (check-regexp-match "DOCTYPE" output)
  (check-regexp-match "<body>" output)
  (check-regexp-match "Hello" output)
  (check-equal? 0 0))

(test-case
    "Static middleware should serve files from filesystem"
    (define test-out (open-output-string))
    (define incoming-tcp
      (open-input-bytes #"GET /static/sample.png HTTP/1.1\r\n\r\n"))
    (define req (new request% [in-port incoming-tcp]))
    (define res (new response% [out-port test-out]))
    (set-field! route req "/static")
    (static req res)
    (define output (get-output-string test-out))
    (check-regexp-match "image/png" output)
    (check-equal? 0 0))


