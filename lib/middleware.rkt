#lang racket/base

(require racket/class)
(require racket/port)
(require racket/string)
(require racket/list)
(require net/mime)

(require (prefix-in config: "config.rkt"))
(require (prefix-in util: "util.rkt"))

(provide (all-defined-out))

(define (static-middleware http-pub)
  (lambda (req res [next void])
    (let ([req-route (get-field route req)]
          [req-path (get-field path req)])

    ; This is the quicker way to get a relative path
    ; provided the dispatcher is formatting them correctly
    ; / at the beginning no / at the end
    ; + 1 will cut the / at the beginning
    (define relative-path (substring req-path (+ 1 (string-length req-route))))
    (define file-path (build-path http-pub relative-path))

    ; Get the correct mime-type
    (define file-name (path->string (last (explode-path file-path))))
    (define extension (last (string-split file-name ".")))
    (send res set-header 'Content-type (hash-ref config:mime-types extension))
    ; Send headers
    (send res send-headers)

    ; Send body
    (define file-in (open-input-file file-path))
    (copy-port file-in (get-field out-port res))
    (next req res))))
