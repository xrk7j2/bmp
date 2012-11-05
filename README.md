bmp
===

Windows Bitmap Generator for Gambit-C.


Sample interaction with the interpreter
=======================================

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
