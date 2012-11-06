(define fx+ +)
(define fx- -)
(define fl+ +)
(define fl- -)
(define fx>= >=)
(define current-error-port current-output-port)

(define (include . args) 'do-nothing)

(define (error . args)
  (write args)
  (/ 1 0))

(define (correct num)
  (cond
    ((real? num) (inexact->exact (floor num)))
    ((rational? num) (floor num))
    ((integer? num) num)
    (else
     (error "correct: bad number:" num))))

(define (shift-left num bits)
  (* num (expt 2 bits)))

(define (shift-right num bits)
  (correct (/ num (expt 2 bits))))

(define (log2 x)
  (/ (log x)
     (log 2)))

(define (highest-bit num)
  (inexact->exact (floor (log2 num))))

(define (extract-bit num offset)
  (if (even? (shift-right num offset))
      0
      1))

(define (extract-bit-field len offs num)
  (let loop ((result 0)
             (i (+ len offs -1)))
    (if (< i offs)
        result
        (loop (+ (shift-left result 1)
                 (extract-bit num i))
              (- i 1)))))
