(require :sb-cover)
(declaim (optimize sb-cover:store-coverage-data))
(asdf:load-system :cl-cffi-glib :force t)
(declaim (optimize (sb-cover:store-coverage-data 0)))
(asdf:test-system :cl-cffi-glib)
(sb-cover:report (glib-sys:sys-path "test/report/"))