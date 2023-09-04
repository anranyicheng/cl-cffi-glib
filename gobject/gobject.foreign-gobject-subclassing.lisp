;;; ----------------------------------------------------------------------------
;;; gobject.foreign-gobject-subclassing.lisp
;;;
;;; Copyright (C) 2011 - 2023 Dieter Kaiser
;;;
;;; Permission is hereby granted, free of charge, to any person obtaining a
;;; copy of this software and associated documentation files (the "Software"),
;;; to deal in the Software without restriction, including without limitation
;;; the rights to use, copy, modify, merge, publish, distribute, sublicense,
;;; and/or sell copies of the Software, and to permit persons to whom the
;;; Software is furnished to do so, subject to the following conditions:
;;;
;;; The above copyright notice and this permission notice shall be included in
;;; all copies or substantial portions of the Software.
;;;
;;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
;;; THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
;;; FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
;;; DEALINGS IN THE SOFTWARE.
;;; ----------------------------------------------------------------------------

(in-package :gobject)

(defvar *registered-types* (make-hash-table :test 'equal))

(defstruct %object-type
  name
  class
  parent
  interfaces
  properties)

;;; ----------------------------------------------------------------------------

(defun instance-init (instance class)
  (log-for :subclass
           ":subclass INSTANCE-INIT for ~A for type ~A (creating ~A)~%"
           instance
           (glib:gtype-name (cffi:foreign-slot-value class
                                                     '(:struct type-class) :type))
           *current-creating-object*)
  (unless (or *current-creating-object*
              *currently-making-object-p*
              (gethash (cffi:pointer-address instance) *foreign-gobjects-strong*)
              (gethash (cffi:pointer-address instance) *foreign-gobjects-weak*))
    (log-for :subclass "Proceeding with initialization...~%")
    (let* ((gtype (cffi:foreign-slot-value class '(:struct type-class) :type))
           (type-name (glib:gtype-name gtype))
           (lisp-type-info (gethash type-name *registered-types*))
           (lisp-class (%object-type-class lisp-type-info)))
      (make-instance lisp-class :pointer instance))))

(cffi:defcallback instance-init-cb :void ((instance :pointer) (class :pointer))
  (instance-init instance class))

;;; ----------------------------------------------------------------------------

(defun class-init (class data)
  (declare (ignore data))
  (log-for :subclass
           ":subclass CLASS-INIT for ~A~%"
           (glib:gtype-name (type-from-class class)))
  (let* ((type-name (glib:gtype-name (type-from-class class)))
         (lisp-type-info (gethash type-name *registered-types*))
         (lisp-class (%object-type-class lisp-type-info)))
    (setf (glib:symbol-for-gtype type-name) lisp-class))
  (setf (cffi:foreign-slot-value class '(:struct object-class) :get-property)
        (cffi:callback c-object-property-get)
        (cffi:foreign-slot-value class '(:struct object-class) :set-property)
        (cffi:callback c-object-property-set))
  (install-properties class))

(cffi:defcallback class-init-cb :void ((class :pointer) (data :pointer))
  (class-init class data))

;;; ----------------------------------------------------------------------------

(defun install-properties (class)
  (let* ((name (glib:gtype-name (cffi:foreign-slot-value class
                                                         '(:struct type-class)
                                                         :type)))
         (lisp-type-info (gethash name *registered-types*)))
    (iter (for property in (%object-type-properties lisp-type-info))
          (for param-spec = (property->param-spec property))
          (for property-id from 123) ; FIXME: ???
          (log-for :subclass
                   ":subclass INSTALL-PROPERTIES installing ~A~%"
                   property)
          (%object-class-install-property class property-id param-spec))))

;;; ----------------------------------------------------------------------------

(defun minimum-foreign-integer (type &optional (signed t))
  (if signed
      (- (ash 1 (1- (* 8 (cffi:foreign-type-size type)))))
      0))

(defun maximum-foreign-integer (type &optional (signed t))
  (if signed
      (1- (ash 1 (1- (* 8 (cffi:foreign-type-size type)))))
      (1- (ash 1 (* 8 (cffi:foreign-type-size type))))))

;;; ----------------------------------------------------------------------------

(defun property->param-spec (property)
  (destructuring-bind (property-name
                       property-type
                       accessor
                       property-get-fn
                       property-set-fn)
      property
    (declare (ignore accessor))
    (let ((property-g-type (glib:gtype property-type))
          (flags (append (when property-get-fn (list :readable))
                         (when property-set-fn (list :writable)))))
      (ev-case (type-fundamental property-g-type)
        ((glib:gtype +g-type-invalid+)
         (error "GValue is of invalid type ~A (~A)"
                property-g-type (glib:gtype-name property-g-type)))
        ((glib:gtype +g-type-none+) nil)
        ((glib:gtype +g-type-char+)
         (param-spec-char property-name
                          property-name
                          property-name
                          (minimum-foreign-integer :char)
                          (maximum-foreign-integer :char)
                          0
                          flags))
        ((glib:gtype +g-type-uchar+)
         (param-spec-uchar property-name
                           property-name
                           property-name
                           (minimum-foreign-integer :uchar nil)
                           (maximum-foreign-integer :uchar nil)
                           0
                           flags))
        ((glib:gtype +g-type-boolean+)
         (param-spec-boolean property-name
                             property-name
                             property-name
                             nil
                             flags))
        ((glib:gtype +g-type-int+)
         (param-spec-int property-name
                         property-name
                         property-name
                         (minimum-foreign-integer :int)
                         (maximum-foreign-integer :int)
                         0
                         flags))
        ((glib:gtype +g-type-uint+)
         (param-spec-uint property-name
                          property-name
                          property-name
                          (minimum-foreign-integer :uint nil)
                          (maximum-foreign-integer :uint nil)
                          0
                          flags))
        ((glib:gtype +g-type-long+)
         (param-spec-long property-name
                          property-name
                          property-name
                          (minimum-foreign-integer :long)
                          (maximum-foreign-integer :long)
                          0
                          flags))
        ((glib:gtype +g-type-ulong+)
         (param-spec-ulong property-name
                           property-name
                           property-name
                           (minimum-foreign-integer :ulong nil)
                           (maximum-foreign-integer :ulong nil)
                           0
                           flags))
        ((glib:gtype +g-type-int64+)
         (param-spec-int64 property-name
                           property-name
                           property-name
                           (minimum-foreign-integer :int64)
                           (maximum-foreign-integer :int64)
                           0
                           flags))
        ((glib:gtype +g-type-uint64+)
         (param-spec-uint64 property-name
                            property-name
                            property-name
                            (minimum-foreign-integer :uint64 nil)
                            (maximum-foreign-integer :uint64 t)
                            0
                            flags))
        ((glib:gtype +g-type-enum+)
         (param-spec-enum property-name
                          property-name
                          property-name
                          property-g-type
                          (enum-item-value
                            (first (get-enum-items property-g-type)))
                          flags))
        ((glib:gtype +g-type-flags+)
         (param-spec-enum property-name
                          property-name
                          property-name
                          property-g-type
                          (flags-item-value
                            (first (get-flags-items property-g-type)))
                          flags))
        ((glib:gtype +g-type-float+)
         (param-spec-float property-name
                           property-name
                           property-name
                           most-negative-single-float
                           most-positive-single-float
                           0.0
                           flags))
        ((glib:gtype +g-type-double+)
         (param-spec-double property-name
                            property-name
                            property-name
                            most-negative-double-float
                            most-positive-double-float
                            0.0d0
                            flags))
        ((glib:gtype +g-type-string+)
         (param-spec-string property-name
                            property-name
                            property-name
                            ""
                            flags))
        ((glib:gtype +g-type-pointer+)
         (param-spec-pointer property-name
                             property-name
                             property-name
                             flags))
        ((glib:gtype +g-type-boxed+)
         (param-spec-boxed property-name
                           property-name
                           property-name
                           property-g-type
                           flags))
        ((glib:gtype +g-type-object+)
         (param-spec-object property-name
                            property-name
                            property-name
                            property-g-type
                            flags))
        (t
         (error "Unknown type: ~A (~A)"
                property-g-type (glib:gtype-name property-g-type)))))))

;;; ----------------------------------------------------------------------------

(defun vtable-item->cstruct-item (item)
  (if (eq :skip (first item))
      (rest item)
      (list (first item) :pointer)))

(defstruct vtable-method-info
  slot-name
  name
  return-type
  args
  callback-name
  impl-call)

(defmethod make-load-form ((object vtable-method-info) &optional environment)
  (declare (ignore environment))
  `(make-vtable-method-info :slot-name ',(vtable-method-info-slot-name object)
                            :name ',(vtable-method-info-name object)
                            :return-type
                            ',(vtable-method-info-return-type object)
                            :args ',(vtable-method-info-args object)
                            :callback-name
                            ',(vtable-method-info-callback-name object)))

(defun vtable-methods (iface-name items)
  (iter (for item in items)
        (when (eq :skip (first item)) (next-iteration))
        (destructuring-bind (name (return-type &rest args) &key impl-call) item
          (for method-name = (intern (format nil "~A-~A-IMPL"
                                             (symbol-name iface-name)
                                             (symbol-name name))))
          (for callback-name = (intern (format nil "~A-~A-CALLBACK"
                                               (symbol-name iface-name)
                                               (symbol-name name))))
          (collect (make-vtable-method-info :slot-name name
                                            :name method-name
                                            :return-type return-type
                                            :args args
                                            :callback-name callback-name
                                            :impl-call impl-call)))))

(defvar *vtables* (make-hash-table :test 'equal))

(defstruct vtable-description
  type-name
  cstruct-name
  methods)

(defmacro define-vtable ((type-name name) &body items)
  (let ((cstruct-name (intern (format nil "~A-VTABLE" (symbol-name name))))
        (methods (vtable-methods name items)))
    `(progn
       (cffi:defcstruct ,cstruct-name
                        ,@(mapcar #'vtable-item->cstruct-item items))
       (setf (gethash ,type-name *vtables*)
             (make-vtable-description :type-name ,type-name
                                      :cstruct-name ',cstruct-name
                                      :methods
                                      (list ,@(mapcar #'make-load-form methods))))
       ,@(iter (for method in methods)
               (for args =
                    (if (vtable-method-info-impl-call method)
                        (first (vtable-method-info-impl-call method))
                        (mapcar #'first (vtable-method-info-args method))))
               (collect `(defgeneric ,(vtable-method-info-name method) (,@args)))
               (collect `(glib-defcallback
                            ,(vtable-method-info-callback-name method)
                            ,(vtable-method-info-return-type method)
                             (,@(vtable-method-info-args method))
                             (restart-case
                               ,(if (vtable-method-info-impl-call method)
                                    `(progn
                                       ,@(rest (vtable-method-info-impl-call method)))
                                    `(,(vtable-method-info-name method)
                                       ,@(mapcar #'first
                                                 (vtable-method-info-args method))))
                               (return-from-interface-method-implementation
                                 (v)
                                 :interactive
                                 (lambda () (list (eval (read)))) v))))))))

;;; ----------------------------------------------------------------------------

(defun interface-init (iface data)
  (destructuring-bind (class-name interface-name)
      (prog1
        (glib::get-stable-pointer-value data)
        (glib::free-stable-pointer data))
    (declare (ignorable class-name))
    (let* ((vtable (gethash interface-name *vtables*))
           (vtable-cstruct (vtable-description-cstruct-name vtable)))
      (log-for :subclass "interface-init for class ~A and interface ~A~%"
               class-name
               interface-name)
      (iter (for method in (vtable-description-methods vtable))
            (for cb = (cffi:get-callback (vtable-method-info-callback-name method)))
            (for slot-name = (vtable-method-info-slot-name method))
            (log-for :subclass "->setting method ~A to ~A~%" method cb)
            (setf (cffi:foreign-slot-value iface vtable-cstruct slot-name) cb)))))

(cffi:defcallback c-interface-init :void ((iface :pointer) (data :pointer))
  (interface-init iface data))

;;; ----------------------------------------------------------------------------

(defun add-interface (name interface)
  (let* ((interface-info (list name interface))
         (interface-info-ptr (glib::allocate-stable-pointer interface-info)))
    (cffi:with-foreign-object (info '(:struct interface-info))
      (setf (cffi:foreign-slot-value info
                                     '(:struct interface-info) :interface-init)
            (cffi:callback c-interface-init)
            (cffi:foreign-slot-value info
                                     '(:struct interface-info) :interface-data)
            interface-info-ptr)
      (type-add-interface-static (glib:gtype name)
                                 (glib:gtype interface) info))))

(defun add-interfaces (name)
  (let* ((lisp-type-info (gethash name *registered-types*))
         (interfaces (%object-type-interfaces lisp-type-info)))
    (iter (for interface in interfaces)
          (add-interface name interface))))

;;; ----------------------------------------------------------------------------

(defun object-property-get (object property-id g-value pspec)
  (declare (ignore property-id))
  (let* ((lisp-object (or (gethash (cffi:pointer-address object)
                                   *foreign-gobjects-strong*)
                          (gethash (cffi:pointer-address object)
                                   *foreign-gobjects-weak*)))
         (property-name (cffi:foreign-slot-value pspec
                                                 '(:struct param-spec)
                                                 :name))
         (property-type (cffi:foreign-slot-value pspec
                                                 '(:struct param-spec)
                                                 :value-type))
         (type-name (glib:gtype-name
                        (cffi:foreign-slot-value pspec
                                                 '(:struct param-spec)
                                                 :owner-type)))
         (lisp-type-info (gethash type-name *registered-types*))
         (property-info (find property-name
                              (%object-type-properties lisp-type-info)
                              :test 'string= :key 'first))
         (property-get-fn (third property-info)))
    (assert (fourth property-info))
    (let ((value (restart-case
                   (funcall property-get-fn lisp-object)
                   (return-from-property-getter (value)
                                                :interactive
                                                (lambda ()
                                                  (format t "Enter new value: ")
                                                  (list (eval (read))))
                                                value))))
      (set-g-value g-value value property-type))))

(cffi:defcallback c-object-property-get :void
    ((object :pointer) (property-id :uint) (value :pointer) (pspec :pointer))
  (object-property-get object property-id value pspec))

;;; ----------------------------------------------------------------------------

(defun object-property-set (object property-id value pspec)
  (declare (ignore property-id))
  (let* ((lisp-object (or (gethash (cffi:pointer-address object)
                                   *foreign-gobjects-strong*)
                          (gethash (cffi:pointer-address object)
                                   *foreign-gobjects-weak*)))
         (property-name (cffi:foreign-slot-value pspec
                                                 '(:struct param-spec) :name))
         (type-name (glib:gtype-name
                        (cffi:foreign-slot-value pspec
                                                 '(:struct param-spec)
                                                 :owner-type)))
         (lisp-type-info (gethash type-name *registered-types*))
         (property-info (find property-name
                              (%object-type-properties lisp-type-info)
                              :test 'string= :key 'first))
         (property-set-fn (third property-info))
         (new-value (parse-g-value value)))
    (assert (fifth property-info))
    (restart-case
      (funcall (fdefinition (list 'setf property-set-fn)) new-value lisp-object)
      (return-without-error-from-property-setter () nil))))

(cffi:defcallback c-object-property-set :void
    ((object :pointer) (property-id :uint) (value :pointer) (pspec :pointer))
  (object-property-set object property-id value pspec))

;;; ----------------------------------------------------------------------------

(defmacro register-object-type-implementation (name class parent interfaces properties)
  (let ((glib:*warn-unknown-gtype* nil))
    (unless (stringp parent)
      (setf parent (glib:gtype-name (glib:gtype parent)))))

  `(progn
     (setf (gethash ,name *registered-types*)
           (make-%object-type :name ,name
                             :class ',class
                             :parent ,parent
                             :interfaces ',interfaces
                             :properties ',properties))
     (glib-init:at-init (',class)
       (log-for :subclass
                "Registering GObject type implementation ~A for type ~A~%"
                ',class ,name)
       (cffi:with-foreign-object (query '(:struct type-query))
         (type-query (glib:gtype ,parent) query)
         (type-register-static-simple
             (glib:gtype ,parent)
             ,name
             (cffi:foreign-slot-value query '(:struct type-query) :class-size)
             (cffi:callback class-init-cb)
             (cffi:foreign-slot-value query '(:struct type-query) :instance-size)
             (cffi:callback instance-init-cb) nil))
       (add-interfaces ,name))
     (defmethod initialize-instance :before ((object ,class) &key pointer)
       (log-for :subclass
                ":subclass INITIAlIZE-INSTANCE :before ~A :pointer ~A~%"
                object pointer)
       (unless (or pointer
                   (and (slot-boundp object 'pointer)
                        (object-pointer object)))
         (log-for :subclass "calling g-object-constructor~%")
         (setf (object-pointer object)
               (call-gobject-constructor ,name nil nil)
               (object-has-reference object) t)))
     #+nil
     (progn
       ,@(iter (for (prop-name prop-type prop-accessor prop-reader prop-writer)
                    in properties)
               (declare (ignorable prop-type))
               (when prop-reader
                 (collect `(defun ,prop-accessor (object)
                             (object-property object ,prop-name))))
               (when prop-writer
                 (collect `(defun (setf ,prop-accessor) (new-value object)
                             (setf (object-property object ,prop-name)
                                   new-value))))))
     ,name))

;;; ----------------------------------------------------------------------------

;; This is a hack to transform the list of properties in an new order for
;; the functions which register a foreign class. Consider to reimplement this
;; to avoid different orders of property lists.

(defun properties-to-new-list (properties)
  (loop for property in properties
        collect (list (third property)
                      (fourth property)
                      (second property)
                      (fifth property)
                      (sixth property))))

(defmacro define-foreign-g-object-class (g-type-name name
                                 (&key (superclass 'g-object)
                                       (export t)
                                       interfaces
                                       type-initializer)
                                 (&rest properties))

  (declare (ignore export type-initializer))

;  (setf properties (mapcar #'parse-property properties))

  (let ((props (mapcar #'parse-property properties))
        (parent (if (stringp superclass)
                    superclass
                    (gobject-class-gname (find-class superclass)))))

    (setf properties (properties-to-new-list properties))

  `(progn

     (setf (gethash ,g-type-name *registered-types*)
           (make-%object-type :name ,g-type-name
                             :class ',name
                             :parent ,parent
                             :interfaces ',interfaces
                             :properties ',properties))

     (glib-init::at-init (',name)
       (log-for :subclass
                "Debug sublcass: Registering GObject type ~A for type ~A~%"
                ',name ,g-type-name)
       (cffi:with-foreign-object (query '(:struct type-query))
         (type-query (glib:gtype ,parent) query)
         (type-register-static-simple
             (glib:gtype ,parent)
             ,g-type-name
             (cffi:foreign-slot-value query '(:struct type-query):class-size)
             (cffi:callback class-init-cb)
             (cffi:foreign-slot-value query '(:struct type-query) :instance-size)
             (cffi:callback instance-init-cb) nil))
       (add-interfaces ,g-type-name))

     (defclass ,name (,@(when (and superclass
                                   (not (eq superclass 'object)))
                          (list superclass))
                      ,@(mapcar #'interface->lisp-class-name interfaces))
       ;; Generate the slot definitions from the given properties
       (,@(mapcar (lambda (property)
                     (meta-property->slot name property))
                   props))
       (:metaclass gobject-class)
;       (:g-type-name . ,g-type-name)
;       ,@(when type-initializer
;           (list `(:g-type-initializer . ,type-initializer)))
)


     (defmethod initialize-instance :before ((object ,name) &key pointer)
       (log-for :subclass
                ":subclass INITIAlIZE-INSTANCE :before ~A :pointer ~A~%"
                object pointer)
       (unless (or pointer
                   (and (slot-boundp object 'pointer)
                        (object-pointer object)))
         (log-for :subclass ":subclass calling g-object-constructor~%")
         (setf (object-pointer object)
               (call-gobject-constructor ,g-type-name nil nil)
               (object-has-reference object) t)))

     (progn
       ,@(iter (for (prop-name prop-type prop-accessor prop-reader prop-writer)
                    in properties)
               (declare (ignorable prop-type))
               (when prop-reader
                 (collect `(defun ,prop-accessor (object)
                             (object-property object ,prop-name))))
               (when prop-writer
                 (collect `(defun (setf ,prop-accessor) (new-value object)
                             (setf (object-property object ,prop-name)
                                   new-value))))))


;     ,@(when export
;         (cons `(export ',name
;                         (find-package
;                           ,(package-name (symbol-package name))))
;               (mapcar (lambda (property)
;                         `(export ',(intern (format nil "~A-~A"
;                                                       (symbol-name name)
;                                                       (property-name property))
;                                              (symbol-package name))
;                                   (find-package
;                                     ,(package-name (symbol-package name)))))
;                        props)))

)))

(export 'define-foreign-g-object-class)

;;; --- End of file gobject.foreign-gobject-subclassing.lisp -------------------
