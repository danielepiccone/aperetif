#lang racket

(require net/url)

(provide dispatch url-matcher url-parameters)

(define (url-matcher location dispatch-table)
  (filter
    (lambda (url)
      (define req-tokens (string-split location "/"))
      (define cur-tokens (string-split url "/"))

      (define (match-tokens a b)
        (if (or (null? a) (null? b))
          #t
          (if (or (equal? (car a) (car b))
                  (equal? (string-ref (car b) 0) #\:))
            (match-tokens (cdr a) (cdr b))
            #f)))

      (match-tokens req-tokens cur-tokens))

    (hash-keys dispatch-table)))

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

