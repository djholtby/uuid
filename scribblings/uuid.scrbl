#lang scribble/manual

@title{@racketmodname[uuid]: Universally Unique Identifiers}
@author[(author+email @elem{Philip M@superscript{c}Grath}
                      "philip@philipmcgrath.com"
                      #:obfuscate? #t)]
@defmodule[uuid]

@(require scribble/example
          (for-label uuid
                     racket
                     racket/random))

The @racketmodname[uuid] library provides functions for generating
@deftech{UUIDs} (Universally Unique Identifiers),
implemented in pure Racket.

Specifically, @racket[uuid-symbol] and @racket[uuid-string]
generate @hyperlink["https://en.wikipedia.org/wiki/Universally_unique_identifier#Version_4_(random)"]{
 version 4} UUIDs based on @racket[crypto-random-bytes],
which obtains cryptographic-quality randomness from the operating system.

@(define make-uuid-eval
   (make-eval-factory '(uuid)))

@deftogether[
 (@defproc[(uuid-symbol) uuid-symbol?]
   @defproc[(uuid-string) (and/c strict-uuid-string? immutable?)])]{
 Returns a new, randomly-generated @tech{UUID} as a symbol
 or string, respectively.
 The returned UUID is guaranteed to use lowercase characters 
 for any hexidecimal digits from @litchar{a} to @litchar{f},
 as specified by
 @hyperlink["https://tools.ietf.org/html/rfc4122#section-3"]{RFC 4122}.

 Symbols are often an ideal way to represent UUIDs in Racket,
 since they are always immutable and can be compared cheaply
 with @racket[eq?].
 On the other hand, strings are often needed to interoperate
 with external systems like databases, so in some circumstances
 @racket[uuid-string] may be more convienient.
 To consistently convert UUID strings to symbols,
 use @racket[uuid-string->symbol].

  @examples[
 #:eval (make-uuid-eval)
 (uuid-symbol)
 (uuid-string)
 ]}


@deftogether[
 (@defproc[(uuid-symbol/name [namespace (or/c uuid-string? uuid-symbol? bytes?)] [name (or/c string? bytes?)]) uuid-symbol?]
   @defproc[(uuid-string/name [namespace (or/c uuid-string? uuid-symbol? bytes?)] [name (or/c string? bytes?)])
            (and/c strict-uuid-string? immutable?)])]{
  Returns a new @tech{UUID} (Version 5) based on @tech{UUID} @racket[namespace] and text @racket[name], as a symbol or string, respectively.

  Namespace can be given as a @racket[uuid-string?] or @racket[uuid-symbol?], or as a byte string.  In this case the byte string should
  represent the bytes of a valid UUID (but this is not checked by the contract).
                
  @examples[
 #:eval (make-uuid-eval)
 (uuid-symbol/name '879f917a-4578-4f2f-8a83-c243e89f3999 "example")
 (uuid-string/name '879f917a-4578-4f2f-8a83-c243e89f3999 "example")
 ]}

@deftogether[
 (@defproc[(uuid-symbol/time) uuid-symbol?]
   @defproc[(uuid-string/time)
            (and/c strict-uuid-string? immutable?)])]{
  Returns a new @tech{UUID} (Version 1) based on the current system time.  Note that the node is randomly generated at install time,
                rather than using the system's MAC address.

                The clock_seq value is randomly generated when the module is loaded, and incremented each time a clock adjustment is detected.
                
 @examples[
 #:eval (make-uuid-eval)
 (uuid-symbol/time)
 (uuid-string/time)
 ]}

@defproc[(make-uuid-v1-generator [node uuid-node? (random-node)])
         (-> (and/c strict-uuid-string? immutable?))]{
  Returns a procedure identical to @racket[uuid-string/time], but using @racket[node] rather than the system node.
  If the node is not the system MAC address, the multicast bit should be set to 1 to avoid colissions with an existing MAC address.
  @examples[
  #:eval (make-uuid-eval)
  (let ([generator (make-uuid-v1-generator (make-bytes 6 0))])
    (generator))]}

@defproc[(random-node) uuid-node?]{Returns a randomly generator node, with the multicast bit set to 1.  Suitable for use with @racket[make-uuid-v1-generator].}

@defproc[(uuid-node? [v any/c]) boolean?]{Predicate for 6 byte sequence, suitable for use as a node for a Version 1 UUID.  Equivalent to @racket[(and (bytes? v) (= 6 (bytes-length v)))]}

@defproc[(strict-uuid-string? [v any/c]) boolean?]{
 Recognizes @tech{UUIDs} in canonical string form:
 that is, strings matching the regular expression:
 @(racketblock
   #px"^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$")

 @examples[
 #:eval (make-uuid-eval)
 (eval:check (strict-uuid-string? "f81d4fae-7dec-11d0-a765-00a0c91e6bf6") #t)
 (eval:check (strict-uuid-string? "F81D4FAE-7DEC-11D0-A765-00A0C91E6BF6") #f)
 (eval:check (strict-uuid-string? "f81D4fAE-7dec-11D0-A765-00a0C91e6bf6") #f)
 ]}


@defproc[(uuid-symbol? [v any/c]) boolean?]{
 Recognizes @tech{UUIDs} represented as symbols.
 Equivalent to:
 @(racketblock
   (λ (v)
     (and (symbol? v)
          (strict-uuid-string? (symbol->string v)))))

 @examples[
 #:eval (make-uuid-eval)
 (eval:check (uuid-symbol? 'f81d4fae-7dec-11d0-a765-00a0c91e6bf6) #t)
 (eval:check (uuid-symbol? 'F81D4FAE-7DEC-11D0-A765-00A0C91E6BF6) #f)
 (eval:check (uuid-symbol? 'f81D4fAE-7dec-11D0-A765-00a0C91e6bf6) #f)
 ]}


@defproc[(uuid-string? [v any/c]) boolean?]{
 Like @racket[strict-uuid-string?], but case-insensitive.

 @examples[
 #:eval (make-uuid-eval)
 (eval:check (uuid-string? "f81d4fae-7dec-11d0-a765-00a0c91e6bf6") #t)
 (eval:check (uuid-string? "F81D4FAE-7DEC-11D0-A765-00A0C91E6BF6") #t)
 (eval:check (uuid-string? "f81D4fAE-7dec-11D0-A765-00a0C91e6bf6") #t)
 ]}


@defproc[(uuid-string->symbol [uuid uuid-string?])
         uuid-symbol?]{
 Converts a @tech{UUID} given as a string to a symbol.
 To ensure that equivalent UUID strings always
 produce @racket[eq?] symbols, any upper-case hexidecimal
 digits in @racket[uuid] are converted to lower-case.

 @examples[
 #:eval (make-uuid-eval)
 (eval:check (uuid-string->symbol "f81d4fae-7dec-11d0-a765-00a0c91e6bf6")
             'f81d4fae-7dec-11d0-a765-00a0c91e6bf6)
 (eval:check (uuid-string->symbol "F81D4FAE-7DEC-11D0-A765-00A0C91E6BF6")
             'f81d4fae-7dec-11d0-a765-00a0c91e6bf6)
 (eval:check (uuid-string->symbol "f81D4fAE-7dec-11D0-A765-00a0C91e6bf6")
             'f81d4fae-7dec-11d0-a765-00a0c91e6bf6)
 ]}


