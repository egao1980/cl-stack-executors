(in-package #:cl-stack-executors/tests)

(deftest inline-runs-on-caller
  (let ((ex (make-inline-executor))
        (seen nil))
    (executor-submit ex (lambda () (push :a seen)))
    (ok (equal seen '(:a)))
    (executor-shutdown ex)
    (ok (not (executor-running-p ex)))
    (ok (signals (executor-submit ex (lambda ()))
                 'executor-shutdown-error))))

(deftest thread-pool-runs-and-joins
  (let ((ex (make-thread-pool :workers 2 :name "test-pool"))
        (lock (bt:make-lock))
        (seen nil))
    (unwind-protect
         (progn
           (ok (executor-running-p ex))
           (ok (= 2 (thread-pool-workers ex)))
           (executor-submit ex (lambda ()
                                 (bt:with-lock-held (lock)
                                   (push 1 seen))))
           (executor-submit ex (lambda ()
                                 (bt:with-lock-held (lock)
                                   (push 2 seen))))
           (loop repeat 100
                 until (bt:with-lock-held (lock) (= 2 (length seen)))
                 do (sleep 0.01))
           (ok (null (set-exclusive-or seen '(1 2)))))
      (executor-shutdown ex :wait t))
    (ok (not (executor-running-p ex)))
    (ok (signals (executor-submit ex (lambda ()))
                 'executor-shutdown-error))))

(deftest executor-runner-adapts
  (let ((seen nil)
        (fn (executor-runner (make-inline-executor))))
    (funcall fn (lambda () (push :ok seen)))
    (ok (equal seen '(:ok)))
    (ok (functionp fn))))

(deftest thread-pool-queue-length
  (let* ((lock (bt:make-lock))
         (cvar (bt:make-condition-variable))
         (released nil)
         (ex (make-thread-pool :workers 1 :name "len-pool")))
    (unwind-protect
         (progn
           (executor-submit ex
                            (lambda ()
                              (bt:with-lock-held (lock)
                                (loop until released
                                      do (bt:condition-wait cvar lock)))))
           (executor-submit ex (lambda ()))
           (loop repeat 50
                 until (plusp (executor-length ex))
                 do (sleep 0.01))
           (ok (>= (executor-length ex) 1))
           (bt:with-lock-held (lock)
             (setf released t)
             (bt:condition-notify cvar)))
      (executor-shutdown ex :wait t))))
