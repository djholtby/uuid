#lang racket/base

(require "main.rkt")
(provide post-installer)

(define (post-installer collect-dir dir)
  (with-output-to-file (build-path dir "node.rktd")
    (lambda () (writeln (random-node)))))
