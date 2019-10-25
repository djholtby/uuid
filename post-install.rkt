#lang racket/base

(require "main.rkt")
(provide post-installer)

(define (post-installer collect-dir dir)
  (let ([f (open-output-file (build-path dir "node.rktd") #:exists 'replace)])
    (writeln (random-node) f)
    (close-output-port f)))
