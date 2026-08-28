(in-package #:cl-stack-executors)

;;; Bounded worker count, unbounded FIFO queue. Per-instance — not process-global.

(defclass thread-pool (executor)
  ((lock :initform (bt:make-lock "thread-pool") :reader %pool-lock)
   (cvar :initform (bt:make-condition-variable :name "thread-pool")
         :reader %pool-cvar)
   (queue :initform nil :accessor %pool-queue)
   (threads :initform nil :accessor %pool-threads)
   (running :initform t :accessor %pool-running-p)
   (workers :initarg :workers :reader thread-pool-workers)
   (name :initarg :name :reader %pool-name)))

(defun thread-pool-p (x) (typep x 'thread-pool))

(defun make-thread-pool (&key (workers 4) (name "thread-pool"))
  (check-type workers (integer 1))
  (let ((pool (make-instance 'thread-pool :workers workers :name name)))
    (setf (%pool-threads pool)
          (loop for i from 1 to workers
                collect (bt:make-thread (lambda () (%pool-worker pool))
                                        :name (format nil "~A-~D" name i))))
    pool))

(defun %pool-worker (pool)
  (loop
    (let ((job (bt:with-lock-held ((%pool-lock pool))
                 (loop
                   (unless (%pool-running-p pool)
                     (return-from %pool-worker nil))
                   (let ((q (%pool-queue pool)))
                     (when q
                       (setf (%pool-queue pool) (cdr q))
                       (return (car q))))
                   (bt:condition-wait (%pool-cvar pool)
                                      (%pool-lock pool))))))
      (handler-case (funcall job)
        (error (e)
          (warn "cl-stack-executors worker: ~A" e))))))

(defmethod executor-running-p ((executor thread-pool))
  (%pool-running-p executor))

(defmethod executor-length ((executor thread-pool))
  (bt:with-lock-held ((%pool-lock executor))
    (length (%pool-queue executor))))

(defmethod executor-submit ((executor thread-pool) thunk)
  (check-type thunk function)
  (bt:with-lock-held ((%pool-lock executor))
    (unless (%pool-running-p executor)
      (error 'executor-shutdown-error
             :executor executor
             :message "thread pool is shut down"))
    (setf (%pool-queue executor)
          (nconc (%pool-queue executor) (list thunk)))
    (bt:condition-notify (%pool-cvar executor)))
  (values))

(defmethod executor-shutdown ((executor thread-pool) &key (wait t))
  (bt:with-lock-held ((%pool-lock executor))
    (setf (%pool-running-p executor) nil)
    (dotimes (i (max 1 (thread-pool-workers executor)))
      (bt:condition-notify (%pool-cvar executor))))
  (when wait
    (dolist (th (%pool-threads executor))
      (when (bt:thread-alive-p th)
        (bt:join-thread th))))
  (setf (%pool-threads executor) nil)
  executor)
