(define-macro (for counter start stop . exps)
  (let ((loop (gensym)))
    `(let ,loop ((,counter ,start))
       ,@exps
       (if (< ,counter ,stop)
           (,loop (fx+ ,counter 1))))))

(define-macro (each nam exp . exps)
  `(vector-for-each (lambda (,nam) ,@exps)
                    ,exp))

(define-macro (upto counter limit . exps)
  (let ((loop (gensym))
        (limit-name (gensym)))
    `(let ((,limit-name ,limit))
       (let ,loop ((,counter 0))
         (if (fx>= ,counter ,limit-name)
             'done
             (begin
               ,@exps
               (,loop (fx+ ,counter 1))))))))

(define-macro (when exp . body)
  `(cond (,exp ,@body)))
