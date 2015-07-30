#lang racket

(require
  json
  "dispatcher.rkt"
  "request.rkt"
  "response.rkt"
  "errors.rkt")

(provide handle route)

(define dispatch-tables
  (hash
    'GET (make-hash)
    'POST (make-hash)
    'PUT (make-hash)
    'DELETE (make-hash)))

(define (handle in out)

  (define req (new request% [in-port in]))
  (define res (new response% [out-port out]))

  (when (get-field line req)

    ; Log
    (log-debug (~a (get-field line req)))

    (define handler
      (dispatch req dispatch-tables))

    (if handler
        ; Call handler
        (handler req res)
        ; Respond with a 404
        ((lambda (req res) (send res send-error 404)) req res))
    ))

(define (route verb route-path handler)
  (hash-set! (hash-ref dispatch-tables verb) route-path handler))


