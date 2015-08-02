#lang racket

(require
  json
  net/url
  racket/date
  "errors.rkt")

(provide response%)

; Move to util
(define get-rfc2822-date
  (parameterize
    ([date-display-format 'rfc2822]) (date->string (current-date) #t)))

(define response%
  (class object%
    (init-field out-port)
    (super-new)

    (define out out-port)

    (define current-headers (make-hash))

    ; Set default headers
    (hash-set! current-headers 'Server "Racket")
    (hash-set! current-headers 'Content-type "text/html")
    (hash-set! current-headers 'Accept "*/*")
    (hash-set! current-headers 'Date (~a get-rfc2822-date " GMT"))

    (define/public (set-header key value)
      (hash-set! current-headers key value))

    (define/public (send-headers [code 200])
      (display (~a "HTTP/1.0 " code " " (code->message code)"\r\n") out)
      (for ([key (hash-keys current-headers)])
        (display (~a key ": " (hash-ref current-headers key) "\r\n") out))
      (display "\r\n" out))

    (define/public (send-raw data [code 200])
      (send-headers code)
      (display data out))

    (define/public (send-json data [code 200])
      (hash-set! current-headers 'Content-type "application/json")
      (send-headers code)
      (display (jsexpr->string data) out))

    (define/public (send-error [code 500])
      (hash-set! current-headers 'Content-type "application/json")
      (send-headers code)
      (define data (hash 'Status (~a (code->message code))))
      (display (jsexpr->string data) out))

    (define/public (send-file filepath [code 200])
      (define fport (open-input-file filepath))
      (send-headers code)
      (define (port-drain in-port fn)
        (let ([chunk (read-string 10 in-port)])
          (unless (eof-object? chunk)
          (fn chunk)
          (port-drain in-port fn)))
        )

      (port-drain fport (lambda (chunk) (display chunk out))))

    (field
      [headers current-headers])

    ))
