#lang racket/base

(require racket/class)
(require net/url)

(require
  "../lib/request.rkt"
  "../lib/dispatcher.rkt")

(require rackunit)

(define dispatch-table
  (hash
    "hello" (lambda (req res) (#t))
    "this/:param" void
    "that/:param/more" void
    "foo/:id/bar/:name" void
    ))

(define dispatch-tables
  (hash
    'GET dispatch-table))

(test-case
  "Match hello route"
  (define location "/hello")
  (check-equal? (url-matcher location dispatch-table) "hello")
  (check-equal? 0 0))

(test-case
  "Match route with params"
  (define location "/this/2340")
  (check-equal? (url-matcher location dispatch-table) "this/:param")
  (check-equal? 0 0))

(test-case
  "Match route with more params"
  (define location "/that/1234/more")
  (check-equal? (url-matcher location dispatch-table) "that/:param/more")
  (check-equal? 0 0))

(test-case
  "Do not match any route"
  (define location "/nothing")
  (check-equal? (url-matcher location dispatch-table) #f))

(test-case
  "Do not match the root if not registered"
  (define location "/")
  (check-equal? (url-matcher location dispatch-table) #f))

(test-case
  "Dispatch to the correct controller"
  (define incoming-tcp
    (open-input-bytes #"GET /hello HTTP/1.1\r\n\r\n"))
  (define req (new request% [in-port incoming-tcp]))
  (check-equal? (get-field path req) "/hello")
  (define handler (dispatch req dispatch-tables))
  (check-false (void? handler))
  (check-true (procedure? handler))
  (check-equal? 0 0))

(test-case
  "When nothing is found in the dispatch table"
  (define incoming-tcp
    (open-input-bytes #"GET /yabbayabba HTTP/1.1\r\n\r\n"))
  (define req (new request% [in-port incoming-tcp]))
  (check-equal? (get-field path req) "/yabbayabba")
  (define handler (dispatch req dispatch-tables))
  (check-false handler)
  (check-equal? 0 0))

(test-case
  "Dispatch also parameters"
  (define incoming-tcp
    (open-input-bytes #"GET /foo/123/bar/cisco HTTP/1.1\r\n\r\n"))
  (define req (new request% [in-port incoming-tcp]))
  (define handler (dispatch req dispatch-tables))
  (define params (get-field params req))
  (check-equal? (hash-ref params 'name) "cisco")
  (check-equal? (hash-ref params 'id) "123")
  (check-equal? 0 0))

(test-case
  "Should not match if requesting a shorter route"
  (define incoming-tcp
    (open-input-bytes #"GET /foo HTTP/1.1\r\n\r\n"))
  (define req (new request% [in-port incoming-tcp]))
  (define handler (dispatch req dispatch-tables))
  (define params (get-field params req))
  (check-equal? 0 0))
