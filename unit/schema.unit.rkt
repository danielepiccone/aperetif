#lang racket

(require
  rackunit
  "../orm/schema.rkt")

(let
  ([name "test"])

  (test-case
    "Create an empty schema"
    (define it (schema name))
    (check-equal? (hash-keys (it 'get-schema)) '(id)))

  (test-case
    "Set a field"
    (define it (schema name))
    (it 'set 'test 10)
    (check-equal? (hash-ref (it 'get-schema) 'test) 10))

  (test-case
    "Get a field"
    (define it (schema name))
    (it 'set 'test 10)
    (check-equal? (it 'get 'test) 10))

  (test-case
    "Get all fields"
    (define it (schema name))
    (it 'set 'test 10)
    (check-equal? (hash-ref (it 'get) 'id) null)
    (check-equal? (hash-ref (it 'get) 'test) 10))

  (test-case
    "Set a schema"
    (define it (schema name))
    (define new-schema (list 'field 'field2 'field3))
    (it 'set-schema new-schema)
    (check-equal? (length (hash-keys (it 'get-schema))) 4))

  (test-case
    "Drop schema"
    (define it (schema name))
    (it 'del-schema)
    )

  )

