(include "../syntax.scm")

(define (fl-square x) (fl* x x))              

(define (offset dim min pixel-dim)
  (fl+ min (fl* (fl+ (exact->inexact dim) 0.5) pixel-dim)))


(define (mandelbrot width height x-min x-max y-min y-max verbose?)
  (let ((image (make-image width height))
        (delta-x (- x-max x-min))
        (delta-y (- y-max y-min)))
    (let ((pixel-width (/ delta-x width 1.0))
          (pixel-height (/ delta-y height 1.0)))
      (for h 0 (dec height)
        (when verbose?
          (cerr (inc h) "/" height return))
        (for w 0 (dec width)
          (check-pixel! image w h x-min y-min pixel-width pixel-height))))
    image))



(define make-gray-pixel
  (let ((tab (make-table)))
    (lambda (intensity)
      (or (table-ref tab intensity #f)
          (let ((pix (pixel intensity
                            (* intensity 3)
                            (* intensity 4))))
            (table-set! tab intensity pix)
            pix)))))

(define (check-pixel! image w h x-min y-min pixel-width pixel-height)
  (let ((cx (offset w x-min pixel-width))
        (cy (offset h y-min pixel-height)))
    (let loop ((zx 0.)
               (zy 0.)
               (counter 0))
      (if (fx> counter 63)
          (set-pixel! image w h black)
          (let ((zx (fl+ (fl- (fl-square zx) (fl-square zy)) cx))
                (zy (fl+ (fl* 2. zx zy) cy)))
            (if (fl> (fl+ (fl-square zx) (fl-square zy)) 4.)
                (set-pixel! image w h
                            (make-gray-pixel counter))
                (loop zx zy (inc counter))))))))


(define (whole-mandelbrot w h)
  (mandelbrot w h -1.8 .7 -1.2 1.2))