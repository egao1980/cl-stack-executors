(defpackage #:cl-stack-executors
  (:use #:cl)
  (:nicknames #:stack-executors)
  (:local-nicknames (#:bt #:bordeaux-threads))
  (:export
   #:executor
   #:executor-p
   #:executor-submit
   #:executor-shutdown
   #:executor-running-p
   #:executor-length
   #:executor-runner
   #:make-thread-pool
   #:thread-pool
   #:thread-pool-p
   #:thread-pool-workers
   #:make-inline-executor
   #:inline-executor
   #:inline-executor-p
   #:executor-error
   #:executor-error-executor
   #:executor-error-message
   #:executor-shutdown-error))

(in-package #:cl-stack-executors)
