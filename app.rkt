#!/usr/bin/racket

#lang racket

(require "./lib/definitions.rkt")

;; This is using an unstable/sketchy orm
(require "./orm/definitions.rkt")

;; Define some controller here

(define (ctrl-test req res)
  (send res send-json (hasheq 'test "ok")))

(define (ctrl-get-all req res)
  ; TODO orm is to rewrite completely
  ; The current model implementation is creating a new entity
  ; before retrieving
  (define path (model "paths"))
    (path 'findall
          (lambda (them)
            (send res send-json them))))


(define (ctrl-insert-one req res)
  (define json (get-field json req))
  (define new-path (model "paths"))
  (new-path 'set 'base64 (hash-ref json 'base64))
  (new-path 'set 'timestamp (hash-ref json 'timestamp))
  (new-path 'set 'bufferdata (hash-ref json 'bufferdata))
  (send res send-json (new-path 'get)))

(define (ctrl-fake-insert req res)
  (define new-path (model "paths"))
  (new-path 'set 'base64 "This is base64")
  (new-path 'set 'timestamp 12345678)
  (new-path 'set 'bufferdata "[1,2,3,4,5]")
  (send res send-json (new-path 'get)))


(define ctrl-file
  (lambda (req res)
    (send res send-file "./public/sample.html")))

(route
  'GET
  "/whoami"
  (lambda (req res)
    (send res send-json '#hash((whoareyou: . "imfine")))))

(route
  'GET
  "/static/:file"
  (use middleware:static))

(route
  'GET
  "/somefile"
  ctrl-file)

(route
  'GET
  "/test"
  ctrl-test)

(route
  'GET
  "/paths"
  ctrl-get-all)

(route
  'GET
  "/foo/:id/"
  ctrl-test)

(route
  'GET
  "/bar/:id/foo"
  ctrl-test)

(route
  'POST
  "/new"
  ctrl-insert-one)

(route
  'GET
  "/insert"
  ctrl-fake-insert)

;; Start
(serve 8080)

