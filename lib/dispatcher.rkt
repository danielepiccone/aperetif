#lang racket/base

(require racket/string)
(require racket/class)
(require net/url)

(provide dispatch url-matcher url-parameters)

(define (match-url-tokens req-tokens route-tokens)
  (if (or (null? req-tokens) (null? route-tokens))
    #t
    ; if the next fragment matches or it is a parameter
    (if (or (equal? (car req-tokens) (car route-tokens))
            (equal? (string-ref (car route-tokens) 0) #\:))
      ; process the rest
      (match-url-tokens (cdr req-tokens) (cdr route-tokens))
      #f)))

; Get an url from the dispatch table matching the request
(define (url-matcher location dispatch-table)
  (filter
    (lambda (url)
      (let ([req-tokens (string-split location "/")]
            [route-tokens (string-split url "/")])

        ; when the request has less fragments than the route it is never matched
        (if (> (length route-tokens) (length req-tokens))
          #f
          (match-url-tokens req-tokens route-tokens))
        ))
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

; Dispatches a request against the dispatch tables
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

