(include "syntax.scm")

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

(define (output-function port)
  (lambda args
    (for-each (lambda (arg) ((if (pair? arg) write display) arg port))
              args)))

(define cout (output-function (current-output-port)))
(define cerr (output-function (current-error-port)))                       
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

(define pixel-red car)
(define pixel-green cadr)
(define pixel-blue caddr)

(define (display-pixel pix pt)
  (display (string (integer->char (pixel-blue pix))
                   (integer->char (pixel-green pix))
                   (integer->char (pixel-red pix)))
           pt))

(define (vector-for-each proc vec)
  (let ((len (vector-length vec)))
    (for i 0 (dec len)
      (proc (vector-ref vec i)))))

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

(define (display-lines lines port verbose?)
  (let ((len (vector-length lines)))
    (for i 0 (dec len)
      (when verbose?
        (cerr "writing " (inc i) "/" len nl))
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

(define (write-bmp port lines verbose?)
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
    (pr (int32 size))    ; biSizeImage
    (pr (empty 16))      ; biXPelsPerMeter biYPelsPerMeter biClrUsed biClrImportant
    (display-lines lines port verbose?)
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
