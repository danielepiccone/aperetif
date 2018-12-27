#lang racket/base

(require racket/format)
(require racket/tcp)

(require
  "logger.rkt"
  "config.rkt"
  "handler.rkt")

(provide serve)

; Start the server loop
(define (serve port-no)
  (displayln (~a "started on " (system-type) " in " base-path))
  (define listener (tcp-listen port-no 5 #t))
  (displayln (~a "serving on port " port-no))
  (define (loop)
    ; Listen for connections
    (accept-and-handle listener)
    ; Listen for debug events
    (define v (sync console-receiver))
    (printf "[~a] ~a\n" (vector-ref v 0) (vector-ref v 1))
    (loop))
  (loop))

; Handle the connection in a new thread
(define (accept-and-handle listener)
  (define cust (make-custodian))
  (parameterize
    ([current-custodian cust])
    (define-values (in out) (tcp-accept listener))
    (thread
      (lambda ()
        ; Prevent empty request to be processed
        (unless (eof-object? (peek-bytes 1 0 in))
          (handle in out))
        (close-input-port in)
        (close-output-port out))))

  ; Watcher thread: 30 seconds timeout
  (thread
    (lambda ()
      (sleep server-timeout)
      (custodian-shutdown-all cust))))

