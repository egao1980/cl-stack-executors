(in-package #:cl-stack-executors)

(define-condition executor-error (error)
  ((executor :initarg :executor :reader executor-error-executor :initform nil)
   (message :initarg :message :reader executor-error-message :initform nil))
  (:report (lambda (c s)
             (format s "~@[~A~%~]executor=~S"
                     (executor-error-message c)
                     (executor-error-executor c)))))

(define-condition executor-shutdown-error (executor-error) ())
