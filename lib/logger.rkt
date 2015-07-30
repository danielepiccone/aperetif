#lang racket

(provide console-receiver)

;; Logger

(define logger (make-logger 'console))
(define console-receiver (make-log-receiver logger 'debug))
(current-logger logger)

