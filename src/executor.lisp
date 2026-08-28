(in-package #:cl-stack-executors)

;;; Library type — concurrent.futures.Executor / Java Executor.
;;; Not part of event-protocol. :executor there is a function of one thunk;
;;; EXECUTOR-RUNNER adapts an EXECUTOR to that.

(defclass executor () ())

(defun executor-p (x) (typep x 'executor))

(defgeneric executor-submit (executor thunk)
  (:documentation "Run THUNK on EXECUTOR. Fire-and-forget."))

(defgeneric executor-shutdown (executor &key wait)
  (:documentation "Stop accepting work. WAIT T joins workers."))

(defgeneric executor-running-p (executor)
  (:documentation "True until EXECUTOR-SHUTDOWN."))

(defgeneric executor-length (executor)
  (:documentation "Queued jobs (not running). NIL if unknown."))

(defun executor-runner (executor)
  "Function of one thunk for event-protocol :executor / any thunk-runner slot."
  (check-type executor executor)
  (lambda (thunk)
    (executor-submit executor thunk)))
