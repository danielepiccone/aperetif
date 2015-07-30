#lang racket

(require "server.rkt")
(require "handler.rkt")

(provide (all-from-out "server.rkt"))
(provide (all-from-out "handler.rkt"))


;; Provide shorthand method as well

(define (get path handler)
  (route 'GET path handler))

(define (post path handler)
  (route 'POST path handler))

(define (put path handler)
  (route 'PUT path handler))

(define (delete path handler)
  (route 'DELETE path handler))

(provide get post put delete)