#lang racket

; TODO change fields to string instead of symbols
;
(require
  db
  "config.rkt"
  "schema.rkt")


(define (model name)

  (define model-schema (schema name))

  (define model-data (make-hash))

  ; TODO pick last from DB
  (define id (current-milliseconds))
  (hash-set! model-data 'id id)

  ; Write instantly to the DB
  ; TODO modify this in the future
  (query-exec sqlc (~a "INSERT INTO " name " (id) VALUES (" id ")"))

  (define (model-set args)
    (let ([key (car args)]
          [value (car (cdr args))])

      (define assignment (~a "'" key "' = '" value "'"))
      (hash-set! model-data key value)
      (query-exec sqlc (~a "UPDATE " name " SET " assignment " WHERE id=" id))))

  ; Import a rows-result into the object
  (define (model-populate query-result)
    (if (empty? (rows-result-rows query-result))
      ; Empty the model
      (set! model-data (make-hash))

      ; Populate it
      ; this is made for only 1 result
      (let ([headers (rows-result-headers query-result)]
            [rows (rows-result-rows query-result)]
            [row (car (rows-result-rows query-result))])
        ;(displayln headers)
        (set! model-data (make-hash))
        (for ([header headers]
              [value (vector->list row)])
          (hash-set! model-data (string->symbol (cdar header)) value)))))


  (define (find args)
    (let ([key (car args)]
          [value (car (cdr args))])
      (define where-cond
        (~a key " = '" value "'"))
      (define result
        (query sqlc (~a "SELECT * FROM " name " WHERE " where-cond " LIMIT 1")))
      (model-populate result)))

  (define (findall args)
    (if (procedure? (car args))
      (let ([callback (car args)])
        (define query-result
          (query sqlc (~a "SELECT * FROM " name)))
        (define headers
          (list->vector (map (lambda (it) (cdar it)) (rows-result-headers query-result))))

        ; TODO leave out this and build a type safe json encoder
        (define transformed
          (map
            (lambda (it)
              (define result (make-hash))
              (for ([h headers]
                    [v (cdr it)])
                (define (fvalue v)
                  (cond
                    [(symbol? v) (symbol->string v)]
                    [else v]))
                (hash-set! result (string->symbol h) (fvalue v)))
              result)
            (hash->list
              (rows->dict
                query-result
                #:key "id"
                #:value headers
                ))))

        (callback transformed))

      #f))

  (define (model-get args)
    (if (null? args)
      model-data
      (let ([key (car args)])
        (if (hash-has-key? model-data key)
          (hash-ref model-data key)
          null))))

  (define (model-remove args)
    ;TODO expand this with a query
    ; for now remove only the current model
    (define where-cond (~a "id = " (hash-ref model-data 'id)))
    (query-exec sqlc (~a "DELETE FROM " name " WHERE " where-cond)))


  (lambda (method . args)
    (cond
      ;[(equal? method 'query) (field-get args)]
      [(equal? method 'findall) (findall args)]
      [(equal? method 'find) (find args)]
      [(equal? method 'remove) (model-remove args)]
      [(equal? method 'get) (model-get args)]
      [(equal? method 'set) (model-set args)]
      [(equal? method 'schema) model-schema]
      [else (error "Method not defined")]))
  )

(provide model)
