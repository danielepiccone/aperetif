#lang racket/base

(require racket/class)
(require net/url)
(require json)
(require "parsers.rkt")

(provide request%)

(define request%
  (class object%
    (init-field in-port)
    (super-new)
    (define in in-port)

    ; Get an header if present otherwise return false
    (define/public (get-header header all-headers)
      (cdr
        (or
          (findf (lambda (it) (equal? header (car it))) all-headers)
          (cons #f #f))))

    ;; Here the order matters as were consuming a port

    ; Fetch the request line
    (define request-line
      (parse-request-line (read-line in)))

    ; Fetch the headers
    (define request-headers
      (let loop ()
        (let ((header (read-line in)))
          (if (or (eof-object? header) (string=? header "\r"))
            null
            (list* (parse-header header) (loop))))))

    ; Fetch the body if there is content length
    (define request-body
      (when (get-header 'content-length request-headers)
        (let ([size (string->number (get-header 'content-length request-headers))])
          ; TODO not true for binary
          (bytes->string/utf-8
            (read-bytes size in)))))

    (init-field
      ;; Request parameters populated by the parsers
      [params (make-immutable-hash)]
      ;; The route this request has been dispatched to
      [route ""]
      ;; The request object
      [line (hash-ref request-line 'line)]
      [verb (hash-ref request-line 'verb)]
      [path (hash-ref request-line 'path)]
      [headers request-headers]
      [body request-body]
      [json (if (void? request-body) (make-hash) (string->jsexpr request-body) )])))





