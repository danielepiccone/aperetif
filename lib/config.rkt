#lang racket/base

(require racket/string)

(provide (all-defined-out))

(define
  server-timeout 30)

(define
  ; TODO deprecated
  ; http://docs.racket-lang.org/reference/collects.html?q=collection-path#%28def._%28%28lib._racket%2Fprivate%2Fbase..rkt%29._collection-path%29%29
  base-path (collection-path "aperetif"))

(define
  http-pub (build-path base-path "../public"))

(define mime-types
  (let ([fin (open-input-file (build-path base-path "lib/config/mime.types"))])
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

