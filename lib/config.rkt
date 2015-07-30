#lang racket

(require db)

(provide (all-defined-out))

(define
  server-timeout 30)

(define
  base-path "/home/daniele/Documents/dev/racket/")

(displayln (~a "started on " (system-type) " in " base-path))

