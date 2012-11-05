(define (dec n) (- n 1))

(define (show-bits n width)
    (let loop ((offs (dec width)))
      (if (< offs 0)
          'done
          (begin
            (display (if (zero? (extract-bit-field 1 offs n))
                         "0"
                         "1"))
            (loop (dec offs)))))
     (newline))

(define (repl)
  (display "repl> ")
  (let ((code (read)))
    (let ((val (eval code)))
      (if (integer? val)
          (begin
            (pp val)
            (show-bits val 16)
            (repl))
          (begin
            (pp val)
            (repl))))))