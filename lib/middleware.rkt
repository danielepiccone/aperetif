#lang racket

(provide (all-defined-out))

(define http-pub "../public")

(define static
  (lambda (req res next)
    (displayln "Processing request... ")
    (next req res)))
