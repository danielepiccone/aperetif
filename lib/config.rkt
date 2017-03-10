#lang racket

(provide (all-defined-out))

(define
  server-timeout 30)

(define
  base-path (collection-path "aperetif"))

(define
  http-pub (build-path base-path "public"))

(displayln (~a "started on " (system-type) " in " base-path))

(define mime-types
  (let ([fin (open-input-file (build-path base-path "lib/conf/mime.types"))])
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

