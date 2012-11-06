(include "syntax.scm")

(define (f x)
  (sin (/ x 500.0)))

(define (grey-pixel intensity)
  (let ((i (inexact->exact (floor (* 256. intensity)))))
    (pixel i i i)))

(define (sine-image w h)
  (let ((image (make-image w h)))
    (upto x w
      (upto y h
        (set-pixel! image x y (grey-pixel (f x)))))
    image))

(define (test)
  (load "bmp.scm")
  (let ((image (make-image 10 10)))
    (set-pixel! image 2 2 (pixel 255 0 0))
    (write-bmp-file "a.bmp" image)))
