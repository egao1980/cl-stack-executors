(in-package #:cl-stack-executors)

;;; Tests / deterministic: run on the calling thread.

(defclass inline-executor (executor)
  ((running :initform t :accessor %inline-running-p)))

(defun inline-executor-p (x) (typep x 'inline-executor))

(defun make-inline-executor ()
  (make-instance 'inline-executor))

(defmethod executor-running-p ((executor inline-executor))
  (%inline-running-p executor))

(defmethod executor-length ((executor inline-executor))
  0)

(defmethod executor-submit ((executor inline-executor) thunk)
  (unless (%inline-running-p executor)
    (error 'executor-shutdown-error
           :executor executor
           :message "inline executor is shut down"))
  (funcall thunk)
  (values))

(defmethod executor-shutdown ((executor inline-executor) &key wait)
  (declare (ignore wait))
  (setf (%inline-running-p executor) nil)
  executor)
