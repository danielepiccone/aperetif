#!/usr/bin/racket

#lang racket

; don't run this file for testing:
(module test racket/base)

(require "../lib/main.rkt")
(require (prefix-in config: "../lib/config.rkt"))


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
    (send res send-json '#hash((whoareyou: . "imfine")))))

(route
  'GET
  "/static"
  (use (static-middleware config:http-pub)))

(route
  'GET
  "/html-file"
  ctrl-file)

(route
  'GET
  "/json"
  ctrl-json)

(serve 3000)

