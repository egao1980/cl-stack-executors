(defsystem "cl-stack-executors"
  :version "0.1.0"
  :description "BT thread pools (Java Executor / Python concurrent.futures)"
  :author "egao1980"
  :license "MIT"
  :depends-on ("bordeaux-threads")
  :serial t
  :pathname "src"
  :components ((:file "package")
               (:file "conditions")
               (:file "executor")
               (:file "inline")
               (:file "thread-pool"))
  :in-order-to ((test-op (test-op "cl-stack-executors/tests")))
  :properties
  (:cl-repo (:provides ("cl-stack-executors"))))

(defsystem "cl-stack-executors/tests"
  :depends-on ("cl-stack-executors" "rove")
  :pathname "tests"
  :serial t
  :components ((:file "package")
               (:file "executor-test"))
  :perform (test-op (o c)
             (unless (symbol-call :rove :run c)
               (error "tests failed for ~A" (component-name c)))))
