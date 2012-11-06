bmp
===

Portable Windows Bitmap Generator for R5RS scheme.

Testing in:

- Scheme48
- Gambit
- Chibi Scheme 0.4 with  #define SEXP_USE_UTF8_STRINGS 0


For use in any R5RS system:
===========================

> (load "bmp-r5rs.scm")
> (define image (make-image 10 10))
> (set-pixel! image 2 2 (pixel 255 0 0))
...
> (write-bmp-file "a.bmp" image)


For use in Gambit:
==================

> (load "bmp.scm")
> (define image (make-image 10 10))
> (set-pixel! image 2 2 (pixel 255 0 0))
...
> (write-bmp-file "a.bmp" image)


Coordinates
===========

+------------------------->
|                      x
|
|
| y
|
v
