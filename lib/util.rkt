#lang racket

(provide (all-defined-out))

(define (strip-other-slashes it)
  (regexp-replace* #rx"/+" it "/"))