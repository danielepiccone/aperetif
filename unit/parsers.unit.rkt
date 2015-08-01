#lang racket

(require rackunit
         net/url
         "../lib/request.rkt"
         "../lib/parsers.rkt")

; Parsers take a string and return immutable hashes

(test-case
  "Parse query string parameters"
  (define input "GET /hello?foo=bar&baz=foo HTTP/1.1\r\n\r\n\r\n")
  (define parsed-line (parse-request-line input))
  (check-equal? (hash-ref parsed-line 'verb) 'GET)
  (check-equal? (hash-ref parsed-line 'path) "/hello")
  (define parameters (hash-ref parsed-line 'parameters))
  (check-equal? (hash-ref parameters 'foo) "bar")
  (check-equal? (hash-ref parameters 'baz) "foo")
  (check-equal? 0 0))

