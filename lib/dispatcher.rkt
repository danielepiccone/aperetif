#lang racket/base

(require racket/string)
(require racket/class)
(require net/url)

(provide dispatch url-matcher url-parameters)

; Match an url with the ones registered in the dispatch table
(define (url-matcher location dispatch-table)
  (filter
    (lambda (url)
      (define req-tokens (string-split location "/"))
      (define cur-tokens (string-split url "/"))

      (define (match-url-tokens a b)
        (if (or (null? a) (null? b))
          #t
          ; if the next fragment matches or it is a parameter
          (if (or (equal? (car a) (car b))
                  (equal? (string-ref (car b) 0) #\:))
            ; process the rest
            (match-url-tokens (cdr a) (cdr b))
            #f)))

      ; Match only if the number of fragments is the same
      (if (equal? (length req-tokens) (length cur-tokens))
        (match-url-tokens req-tokens cur-tokens)
        #f))

    (hash-keys dispatch-table)))

; Extrct the parameters from an url given a pattern
(define (url-parameters url pat)
  (let ([req-tokens (string-split url "/")]
        [pat-tokens (string-split pat "/")])

    (define parameters (make-immutable-hash))

    (define (parse-param pat-tokens req-tokens)
      (define pat-token (car pat-tokens))
      (define req-token (car req-tokens))

      (when (equal? (string-ref pat-token 0) #\:)
        (define param-key (string->symbol (substring pat-token 1)))
        (set! parameters (hash-set parameters param-key req-token)))

      (unless (or (null? (cdr pat-tokens)) (null? (cdr req-tokens)))
        (parse-param (cdr pat-tokens) (cdr req-tokens))))

    (unless (null? req-tokens)
      (parse-param pat-tokens req-tokens))

    parameters))

(define (dispatch req dispatch-tables)
  (let ([verb (get-field verb req)]
        [location (get-field path req)]
        [dispatch-table (hash-ref dispatch-tables (get-field verb req))])

    ; Parse the request as a URL:
    (define url (string->url location))

    ; Extract the path part:
    (define path (map path/param-path (url-path url)))

    (define matching-url
      (let ([url (url-matcher location dispatch-table)])
        (if (null? url)
          #f
          (car url))))

    ; Extract parameters
    (when matching-url
      (set-field! params req (url-parameters location matching-url))
      (set-field! route req matching-url))

    ; Find a handler based on the path's first element:
    (define handler (hash-ref dispatch-table matching-url #f))

    ; Return the value or a void procedure
    (or handler #f)))

