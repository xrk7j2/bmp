(define-syntax upto
  (syntax-rules ()
    ((_ counter limit exp1 exp2 ...)
     (let ((limit-name limit))
       (let loop ((counter 0))
         (if (>= counter limit-name)
             'done
             (begin
               exp1 exp2 ...
               (loop (+ counter 1)))))))))

(define-syntax when
  (syntax-rules ()
    ((_ condition exp1 exp2 ...)
     (cond (condition exp1 exp2 ...)))))