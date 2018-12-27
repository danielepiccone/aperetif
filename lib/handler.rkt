#lang racket/base

(require racket/class)
(require racket/format)
(require json)

(require
  "dispatcher.rkt"
  "request.rkt"
  "response.rkt"
  "errors.rkt")

(provide handle route use)

(define dispatch-tables
  (hash
    'HEAD (make-hash)
    'OPTIONS (make-hash)
    'GET (make-hash)
    'POST (make-hash)
    'PUT (make-hash)
    'PATCH (make-hash)
    'DELETE (make-hash)))

(define (handle in out)
  (define req (new request% [in-port in]))
  (define res (new response% [out-port out]))

  (when (get-field line req)

    ; Log
    (log-debug (~a (get-field line req)))

    (define handler
      (dispatch req dispatch-tables))

    ; if a handler has been registered
    (if handler
        ; Call handler
        (handler req res)
        ; Respond with a 404
        ((lambda (req res) (send res send-error 404)) req res))))

;; Define a route
(define (route verb route-path handler)
  (hash-set! (hash-ref dispatch-tables verb) route-path handler))

;; Apply a transform to the request/response before sending
(define (use fn-middleware [fn-handler void])
  (lambda (req res)
    (fn-middleware req res fn-handler)))


