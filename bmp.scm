(declare
  (standard-bindings)
  (extended-bindings)
  (block)
  (not safe)
  (mostly-flonum-fixnum)
  (inline)
  (inline-primitives)
  (inlining-limit 300)
  )

(define (inc n) (fx+ n 1))
(define (dec n) (fx- n 1))


(define (cout . args)
  (for-each (lambda (arg) ((if (pair? arg) write display) arg))
            args))
(define cerr
  (let ((stderr (current-error-port)))
    (lambda args
      (for-each (lambda (arg) ((if (pair? arg)
                              (lambda (x) (write x stderr))
                              (lambda (x) (display x stderr)))
                          arg))
                args))))
(define nl #\newline)


(define (empty n)
  (make-string n #\nul))

(define (write-bmp-file path ls)
  (call-with-output-file path
    (lambda (port)
      (write-bmp port ls))))

(define (bytes . args)
  (apply string (map integer->char args)))

(define (int32 n)
  (bytes (extract-bit-field 8 0 n)
         (extract-bit-field 8 8 n)
         (extract-bit-field 8 16 n)
         (extract-bit-field 8 24 n)))

(define (int16 n)
  (bytes (extract-bit-field 8 0 n)
         (extract-bit-field 8 8 n)))

(define red car)
(define green cadr)
(define blue caddr)

(define (display-pixel pix pt)
  (display (string (integer->char (blue pix))
                   (integer->char (green pix))
                   (integer->char (red pix)))
           pt))

(define-macro (for counter start stop . exps)
  (let ((loop (gensym)))
    `(let ,loop ((,counter ,start))
       ,@exps
       (if (< ,counter ,stop)
           (,loop (fx+ ,counter 1))))))

(define (vector-for-each proc vec)
  (let ((len (vector-length vec)))
    (for i 0 (dec len)
      (proc (vector-ref vec i)))))

(define-macro (each nam exp . exps)
  `(vector-for-each (lambda (,nam) ,@exps)
                    ,exp))

(define (padding len)
  (let ((r (remainder len 4)))
    (if (zero? r) 0 (- 4 r))))

(define (display-line line pt)
  (let ((len (vector-length line)))
    (let loop ((i 0)
               (bytes 0))
      (if (fx>= i len)
          (display (empty (padding bytes)) pt)
          (begin
            (display-pixel (vector-ref line i) pt)
            (loop (inc i)
                  (+ bytes 3)))))))

(define (display-lines lines port)
  (let ((len (vector-length lines)))
    (for i 0 (dec len)
      (cerr "writing " (inc i) "/" len nl)
      (let ((line (vector-ref lines i)))
        (display-line line port)))))

(define (vector-reverse v)
  (let ((len (vector-length v)))
    (let ((new-v (make-vector len)))
      (for i 0 (dec len)
        (vector-set! new-v i (vector-ref v (fx- len 1 i))))
      new-v)))

(define (calculate-size lines)
  (let ((height (vector-length lines))
        (width (* 3 (vector-length (vector-ref lines 0)))))
    (let ((p (+ width (padding width))))
      (* p height))))

(define reverse-lines vector-reverse)

(define (image-width img)
  (vector-length (vector-ref img 0)))

(define (image-height img)
  (vector-length img))

(define (write-bmp port lines)
  (let ((width (image-width lines))
        (heigth (image-height lines))
        (size (calculate-size lines))
        (pr (lambda (x) (display x port))))
    (pr "BM")            ; bfType
    (pr (int32 (fx+ size 54)))  ; bfSize
    (pr (int32 0))       ; bfReserved
    (pr (int32 54))      ; bfOffBits
    (pr (int32 40))      ; biSize
    (pr (int32 width))   ; biWidth
    (pr (int32 heigth))  ; biHeight
    (pr (int16 1))       ; biPlanes
    (pr (int16 24))      ; biBitCount
    (pr (int32 0))       ; biCompression
    (pr (int32 size))  ; biSizeImage
    (pr (empty 16))       ; biXPelsPerMeter biYPelsPerMeter biClrUsed biClrImportant
    (display-lines lines port)
    ))



(define white (list 255 255 255))
(define black (list 0 0 0))


(define (make-image width height)
  (let ((image (make-vector height)))
    (for i 0 (dec height)
      (vector-set! image i (make-vector width white)))
    image))

(define (set-pixel! image x y val)
  (vector-set! (vector-ref image y) x val))

(define (image->list img)
  (map vector->list (vector->list img)))


(define (mandelbrot width height x-min x-max y-min y-max)
  (let ((image (make-image width height))
        (delta-x (- x-max x-min))
        (delta-y (- y-max y-min)))
    (let ((pixel-width (/ delta-x width 1.0))
          (pixel-height (/ delta-y height 1.0)))
      (for h 0 (dec height)
        (cerr (inc h) "/" height nl)
        (for w 0 (dec width)
          (check-pixel! image w h x-min y-min pixel-width pixel-height))))
    image))

(define (fl-square x) (fl* x x))              

(define (offset dim min pixel-dim)
  (fl+ min (fl* (fl+ (exact->inexact dim) 0.5) pixel-dim)))

(define make-gray-pixel
  (let ((tab (make-table)))
    (lambda (intensity)
      (or (table-ref tab intensity #f)
          (let ((pix (list intensity
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

(define (whole w h)
  (mandelbrot w h -1.8 .7 -1.2 1.2))