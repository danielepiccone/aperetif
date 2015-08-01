#lang racket

(require db)

(provide (all-defined-out))

(define
  base-path (find-system-path 'orig-dir))

(define
  db-name "sqlite/database.sqlite3")

(define
  db-path (build-path base-path db-name))

(displayln (~a "orm using sqlite in " db-path))

(define sqlc
  (sqlite3-connect
    #:database db-path
    #:mode 'create))


