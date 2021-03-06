#lang racket/base

(require racket/string)
(require racket/runtime-path)

(provide (all-defined-out))

(define
  server-timeout 30)

(define-runtime-path base-path "../")

(define
  http-pub (build-path base-path "./public"))

(define mime-types
  (let ([fin (open-input-file (build-path base-path "./lib/config/mime.types"))])
    (define mime-types (make-hash))
    (define (parse-mime-types)
      (let ([line (read-line fin)])
        (unless (eof-object? line)
          (unless (equal? "#" (substring line 0 1))
            (define mime-type (string-split line))
            (hash-set! mime-types (cadr mime-type) (car mime-type)))
          (parse-mime-types))))
    (parse-mime-types)
    mime-types))

