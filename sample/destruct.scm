

(define-macro destruct
  (lambda (pattern target . code)

    (define accessor
      (lambda (ls target)
        (let loop ((ls (reverse ls))
                   (result target))
          (if (null? ls)
              result
              (loop (cdr ls)
                    (list (car ls)
                          result))))))

    (define bindings
      (lambda (pattern target)
        (let ((result '()))
          (let walk ((pattern pattern)
                     (acc-list '()))
            (define (note! name ls)
              (set! result (cons (list name (accessor ls target))
                                 result)))
            (cond
             ((symbol? (car pattern))
              (note! (car pattern)
                     (cons 'car acc-list)))
             ((pair? (car pattern))
              (walk (car pattern)
                    (cons 'car acc-list))))
            (cond
             ((symbol? (cdr pattern))
              (note! (cdr pattern)
                     (cons 'cdr acc-list)))
             ((pair? (cdr pattern))
              (walk (cdr pattern)
                    (cons 'cdr acc-list))))
            (reverse result)))))

    (let ((name (gensym)))
      `(let ((,name ,target))
         ,(if (pair? pattern)
              `(let ,(bindings pattern name)
                 ,@code)
              `(let ((,pattern ,name))
                 ,@code))))))


(define-macro match
  (lambda (what . clauses)
    (let ((nam (gensym))
          (cdrnam (gensym)))
      `(let ((,nam ,what))
         (let ((,cdrnam (cdr ,nam)))
           (case (car ,nam)
             ,@(map (lambda (clause)
                      (let ((pattern (car clause))
                            (body (cdr clause)))
                        (cond
                          ((eq? pattern 'else)
                           clause)
                          ((and (pair? pattern)
                                (null? (cdr pattern)))
                           clause)
                          (else
                           `((,(car pattern))
                             (destruct ,(cdr pattern) ,cdrnam ,@body))))))
                    clauses)))))))