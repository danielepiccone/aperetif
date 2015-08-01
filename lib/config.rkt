#lang racket

(provide (all-defined-out))

(define
  server-timeout 30)

(define
  base-path (find-system-path 'orig-dir))

(displayln (~a "started on " (system-type) " in " base-path))

