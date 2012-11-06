(include "/home/flo/src/mac.scm")
(include "destruct.scm")

(define (read-string s)
  (call-with-input-string s read))

(define (list-head ls n)
  (if (or (zero? n)
          (null? ls))
      '()
      (cons (car ls)
            (list-head (cdr ls) (- n 1)))))

(define (usage self)
  (cout "Copyright Florian Spitzer 2012" nl)
  (cout "Usage:" nl)
  (cout self " <path> <width> <height> <x-min> <x-max> <y-min> <y-max>" nl)
  (cout "    width, height:               must be integer" nl)
  (cout "    x-min, x-max, y-min, y-max:  must be real" nl nl)
  (cout "To create a BMP file, say:" nl)
  (cout "    " self " 500 500 -1.8 .7 -1.2 1.2 > mandelbrot.bmp" nl nl)
  (cout "To create a PNG file, say:" nl)
  (cout "    " self " 500 500 -1.8 .7 -1.2 1.2 | bmptopnm | pnmtopng > mandelbrot.png" nl)
  )

(define (convert-xaos ls)
  (destruct (ax ay delta-x delta-y) ls
    (let ((result (list (- ax (/ delta-x 2))
                        (+ ax (/ delta-x 2))
                        (- ay (/ delta-y 2))
                        (+ ay (/ delta-y 2)))))
      (cerr result nl)
      result)))

(let ((cmdline (command-line)))
  (call/cc
   (lambda (return)
     (let ((xaos? #f)
           (verbose? #t))
       (cond
        ((null? (cdr cmdline))
         (usage (car cmdline))
         (return 0))
        ((equal? (cadr cmdline) "-x")
         (set! xaos? #t)
         (set-cdr! cmdline (cddr cmdline))))
       (let ((args (map read-string (cdr cmdline))))
         (let ((ints (list-head args 2))
               (reals (list-tail args 2)))
           (cond
             ((memv #f (map integer? ints))
              (usage (car cmdline)))
             ((or (not (= (length reals) 4))
                  (memv #f (map real? (list-tail args 2))))
              (usage (car cmdline)))
             (else
              (let ((calculate-image
                     (lambda ()
                       (apply mandelbrot
                              (append (if xaos?
                                          (append ints
                                                  (convert-xaos reals))
                                          args)
                                      (list verbose?))))))
                (let ((data (time (calculate-image))))
                  (time (write-bmp (current-output-port)
                                   data                     
                                   verbose?))))))
           (return 0)))))))