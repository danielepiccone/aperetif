#lang racket

(provide (all-defined-out))

; util
(define (strip-other-slashes it)
  (regexp-replace* #rx"/+" it "/"))

(define (parse-query-parameters data)
  (define parameters (make-hash))
  (define assignments (string-split data "&"))
  (foldl
    (lambda (a b)
      (let ([assignment (string-split a "=")])
        (hash-set b (string->symbol (car assignment)) (cadr assignment))))
    (make-immutable-hash)
    assignments))

(define (parse-request-line data)
  (define req-part (string-split data))
  (define req-verb (list-ref req-part 0))
  (define req-line (list-ref req-part 1))
  (define req-version (list-ref req-part 2))
  (define req-location (car (string-split req-line "?")))
  (define req-query-params
    (if (regexp-match? #rx"\\?" req-line)
      (cadr (string-split req-line "?"))
      ""))
  (hash
    'verb (string->symbol req-verb)
    'line req-line
    'path (strip-other-slashes req-location)
    'parameters (parse-query-parameters req-query-params)))


; Parse the header and return a cons
(define (parse-header header)
  (let ((header (regexp-split ": " header)))
    (cons (string->symbol (string-downcase (car header)))
          (let ((v (string-join (cdr header) ": ")))
            (if (string=? "" v)
              v
              (substring v 0 (sub1 (string-length v))))))))

