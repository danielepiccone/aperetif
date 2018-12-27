#!/usr/bin/racket

#lang racket

(require racket/system)
(require racket/string)

; don't run this file for testing:
(module test racket/base)

(require "../lib/main.rkt")

;; Define some controller here

(define (ctrl-json req res)
  (send res send-json (hasheq 'test "ok")))

(define ctrl-file
  (lambda (req res)
    (send res send-file "./public/sample.html")))

;; Application routing

(route
  'GET
  "/whoami"
  (lambda (req res)
    (let ([me (string-trim (with-output-to-string (lambda () (system "whoami"))))])
      (send res send-json (hash 'whoami  me)))))

(route
  'GET
  "/static"
  (use (static-middleware "./public")))

(route
  'GET
  "/html-file"
  ctrl-file)

(route
  'GET
  "/json"
  ctrl-json)

(serve 3000)

