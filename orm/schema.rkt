#lang racket

(require
  db
  "config.rkt")

(define (schema name)

  ; Initialize
  (define schema (make-hash))

  (define (schema-get-from-table)
    (let ([db-schema (query sqlc (~a "PRAGMA table_info(" name ")"))])
      (for-each
        (lambda (it)
          (hash-set! schema (string->symbol (vector-ref it 1)) null))
        (rows-result-rows db-schema))
      #f))

  (define (schema-init)
    (hash-set! schema 'id null)
    (query-exec sqlc (~a "CREATE TABLE " name " (id INTEGER PRIMARY KEY ASC)")))

  (define (schema-del)
    (query-exec sqlc (~a "DROP TABLE " name))
    (set! schema (make-hash))
    ;(schema-init)
    )

  (if (table-exists? sqlc name)
    (schema-get-from-table)
    (schema-init))

  (define (field-get args)
    (if (empty? args)
      schema
      (let ([field (car args)])
        (hash-ref schema field))))

  (define (field-set args)
    (let ([field (car args)]
          [value (list-ref args 1)])
      (hash-set! schema field value)))

  (define (schema-set args)
    (let ([new-schema (car args)])
      ; TODO validate
      (for-each
        (lambda (it)
          ; TODO if table is already there change format
          ; Otherwise create
          (hash-set! schema it null)
          (query-exec sqlc (~a "ALTER TABLE '" name "' ADD " it " TEXT"))) new-schema)

      ; TODO match types
      ; TODO for now only strings and integers
      ;
      ))

  (lambda (method . args)
    (cond
      [(equal? method 'del-schema) (schema-del)]
      [(equal? method 'set-schema) (schema-set args)]
      [(equal? method 'get-schema) schema]
      [(equal? method 'get) (field-get args)]
      [(equal? method 'set) (field-set args)]
      [else (error "Method not defined")])
    ))

(provide schema)
