#lang racket

(require
  rackunit
  "../orm/model.rkt")

(let
  ([name "mymodel"])

  (test-case
    "Init a new model with an empty schema"
    (define it (model name))
    (define schema (it 'schema))
    (check-equal? (hash-keys (schema 'get-schema)) '(id)))

  (test-case
    "Basic crud operations"
    (define it (model name))
    (define schema (it 'schema))
    (check-equal? (hash-ref (schema 'get-schema) 'id) null )
    (schema 'set-schema (list 'firstname 'lastname))
    (check-equal? (hash-ref (schema 'get-schema) 'firstname) null )
    (check-equal? (hash-ref (schema 'get-schema) 'lastname) null )

    ; Modification
    (it 'set 'firstname "Mario")
    (it 'set 'lastname "Bros")

    ; Retrieval
    (let ([current (it 'get)])
      (check-equal? (hash-ref current 'firstname) "Mario")
      (check-equal? (hash-ref current 'lastname) "Bros"))
    (check-equal? (it 'get 'lastname) "Bros")
    (check-equal? (it 'get 'someotherkey) null)
    (check-equal? 0 0))

  (test-case
    "Find by field"
    (define it (model name))
    (it 'find 'firstname "Mario")
    (check-equal? (it 'get 'lastname) "Bros")
    (check-equal? 0 0))

  (test-case
    "Find multiple objects" ; TODO temporary, replace with collection
    ; Create a second object
    (define it (model name))
    (it 'set 'firstname "Luigi")
    (it 'set 'lastname "Bros")
    (it 'findall
        (lambda (results)
          (check-equal? (length results) 2)
          (check-equal? (hash-ref (list-ref results 0) 'lastname) "Bros")
          ))
    (check-equal? 0 0))

  (test-case
    "Delete database object"
    (define it (model name))
    (it 'find 'firstname "Mario")
    (it 'remove)
    (it 'find 'firstname "Mario")
    (check-equal? (it 'get 'lastname) null)
    (check-equal? 0 0))

  (test-case
    "Tear down - drop the current schema"
    (define it (model name))
    (define schema (it 'schema))
    (schema 'del-schema))

  )
