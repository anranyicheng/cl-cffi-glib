(in-package :glib-test)

(def-suite gobject-type-info :in gobject-suite)
(in-suite gobject-type-info)

;;; --- Types and Values -------------------------------------------------------

(test g-type-constants.1
  (is (= (ash  0 2) gobject:+g-type-invalid+))
  (is (= (ash  1 2) gobject:+g-type-none+))
  (is (= (ash  2 2) gobject:+g-type-interface+))
  (is (= (ash  3 2) gobject:+g-type-char+))
  (is (= (ash  4 2) gobject:+g-type-uchar+))
  (is (= (ash  5 2) gobject:+g-type-boolean+))
  (is (= (ash  6 2) gobject:+g-type-int+))
  (is (= (ash  7 2) gobject:+g-type-uint+))
  (is (= (ash  8 2) gobject:+g-type-long+))
  (is (= (ash  9 2) gobject:+g-type-ulong+))
  (is (= (ash 10 2) gobject:+g-type-int64+))
  (is (= (ash 11 2) gobject:+g-type-uint64+))
  (is (= (ash 12 2) gobject:+g-type-enum+))
  (is (= (ash 13 2) gobject:+g-type-flags+))
  (is (= (ash 14 2) gobject:+g-type-float+))
  (is (= (ash 15 2) gobject:+g-type-double+))
  (is (= (ash 16 2) gobject:+g-type-string+))
  (is (= (ash 17 2) gobject:+g-type-pointer+))
  (is (= (ash 18 2) gobject:+g-type-boxed+))
  (is (= (ash 19 2) gobject:+g-type-param+))
  (is (= (ash 20 2) gobject:+g-type-object+))
  (is (= (ash 21 2) gobject:+g-type-variant+)))

(test g-type-constants.2
  (is (eq (g:gtype "void") (g:gtype gobject:+g-type-none+)))
  (is (eq (g:gtype "GInterface") (g:gtype gobject:+g-type-interface+)))
  (is (eq (g:gtype "gchar") (g:gtype gobject:+g-type-char+)))
  (is (eq (g:gtype "guchar") (g:gtype gobject:+g-type-uchar+)))
  (is (eq (g:gtype "gboolean") (g:gtype gobject:+g-type-boolean+)))
  (is (eq (g:gtype "gint") (g:gtype gobject:+g-type-int+)))
  (is (eq (g:gtype "guint") (g:gtype gobject:+g-type-uint+)))
  (is (eq (g:gtype "glong") (g:gtype gobject:+g-type-long+)))
  (is (eq (g:gtype "gulong") (g:gtype gobject:+g-type-ulong+)))
  (is (eq (g:gtype "gint64") (g:gtype gobject:+g-type-int64+)))
  (is (eq (g:gtype "guint64") (g:gtype gobject:+g-type-uint64+)))
  (is (eq (g:gtype "GEnum") (g:gtype gobject:+g-type-enum+)))
  (is (eq (g:gtype "GFlags") (g:gtype gobject:+g-type-flags+)))
  (is (eq (g:gtype "gfloat") (g:gtype gobject:+g-type-float+)))
  (is (eq (g:gtype "gdouble") (g:gtype gobject:+g-type-double+)))
  (is (eq (g:gtype "gchararray") (g:gtype gobject:+g-type-string+)))
  (is (eq (g:gtype "gpointer") (g:gtype gobject:+g-type-pointer+)))
  (is (eq (g:gtype "GBoxed") (g:gtype gobject:+g-type-boxed+)))
  (is (eq (g:gtype "GParam") (g:gtype gobject:+g-type-param+)))
  (is (eq (g:gtype "GObject") (g:gtype gobject:+g-type-object+)))
  (is (eq (g:gtype "GType") (g:gtype gobject:+g-type-gtype+)))
  (is (eq (g:gtype "GVariant") (g:gtype gobject:+g-type-variant+)))
  (is (eq (g:gtype "GChecksum") (g:gtype gobject:+g-type-checksum+))))

;;;     GType

;;;     GTypeInterface

(test g-type-interface-structure
  (let ((interface (g:type-default-interface-ref "GAction")))
    (is (= 16 (cffi:foreign-type-size '(:struct g:type-interface))))
    (is (equal '(:instance-type :type)
               (sort (cffi:foreign-slot-names '(:struct g:type-interface))
                     #'string-lessp)))
    (is (eq (g:gtype "GAction")
            (cffi:foreign-slot-value interface
                                     '(:struct g:type-interface) :type)))
    (is-false (cffi:foreign-slot-value interface
                                       '(:struct g:type-interface)
                                       :instance-type))))

;;;     GTypeInstance

(test g-type-instance-structure
  (let* ((button (make-instance 'g:simple-action))
         (class (cffi:foreign-slot-value (gobject::pointer button)
                                         '(:struct g:type-instance) :class)))
    (is (= 8 (cffi:foreign-type-size '(:struct g:type-instance))))
    (is (equal '(:class) (cffi:foreign-slot-names '(:struct g:type-instance))))
    (is (eq (g:gtype "GSimpleAction") (g:type-from-class class)))))

;;;     GTypeClass

(test g-type-class-structure
  (let ((class (g:type-class-ref "GSimpleAction")))
    (is (= 8 (cffi:foreign-type-size '(:struct g:type-class))))
    (is (equal '(:type) (cffi:foreign-slot-names '(:struct g:type-class))))
    (is (eq (g:gtype "GSimpleAction")
            (cffi:foreign-slot-value class '(:struct g:type-class) :type)))))

;;;     GTypeInfo
;;;     GTypeFundamentalInfo
;;;     GInterfaceInfo
;;;     GTypeValueTable
;;;     GTypeDebugFlags                                    not implemented
;;;     GTypeQuery
;;;     GTypeFlags
;;;     GTypeFundamentalFlags

;;; --- Functions --------------------------------------------------------------

;;;   g_type_fundamental

(test g-type-fundamental
  (is (eq (g:gtype "GObject") (g:type-fundamental "GApplication")))
  (is (eq (g:gtype "GObject") (g:type-fundamental "GSimpleAction")))
  (is (eq (g:gtype "GInterface") (g:type-fundamental "GAction")))
  (is (eq (g:gtype "GFlags") (g:type-fundamental "GApplicationFlags")))
  (is (eq (g:gtype "GEnum") (g:type-fundamental "GEmblemOrigin")))
  (is (eq (g:gtype "GBoxed") (g:type-fundamental "GVariantType"))))

;;;   g_type_make_fundamental                              not exported

;;;   g_type_is_abstract

(test g-type-is-abstract
  (is-false (g:type-is-abstract gobject:+g-type-invalid+))
  (is-false (g:type-is-abstract gobject:+g-type-none+))
  (is-false (g:type-is-abstract gobject:+g-type-interface+))
  (is-false (g:type-is-abstract gobject:+g-type-char+))
  (is-false (g:type-is-abstract gobject:+g-type-uchar+))
  (is-false (g:type-is-abstract gobject:+g-type-boolean+))
  (is-false (g:type-is-abstract gobject:+g-type-int+))
  (is-false (g:type-is-abstract gobject:+g-type-uint+))
  (is-false (g:type-is-abstract gobject:+g-type-long+))
  (is-false (g:type-is-abstract gobject:+g-type-ulong+))
  (is-false (g:type-is-abstract gobject:+g-type-int64+))
  (is-false (g:type-is-abstract gobject:+g-type-uint64+))
  (is-true  (g:type-is-abstract gobject:+g-type-enum+))
  (is-true  (g:type-is-abstract gobject:+g-type-flags+))
  (is-false (g:type-is-abstract gobject:+g-type-float+))
  (is-false (g:type-is-abstract gobject:+g-type-double+))
  (is-false (g:type-is-abstract gobject:+g-type-string+))
  (is-false (g:type-is-abstract gobject:+g-type-pointer+))
  (is-true  (g:type-is-abstract gobject:+g-type-boxed+))
  (is-true  (g:type-is-abstract gobject:+g-type-param+))
  (is-false (g:type-is-abstract gobject:+g-type-object+))
  (is-false (g:type-is-abstract gobject:+g-type-gtype+))
  (is-false (g:type-is-abstract gobject:+g-type-variant+))
  (is-false (g:type-is-abstract gobject:+g-type-checksum+))
  (is-false (g:type-is-abstract "GApplication"))
  (is-false (g:type-is-abstract "GAction"))
  (is-false (g:type-is-abstract "GSimpleAction"))
  (is-false (g:type-is-abstract "GApplicationFlags"))
  (is-false (g:type-is-abstract "GEmblemOrigin"))
  (is-false (g:type-is-abstract "GVariantType")))

;;;   g_type_is_dervied

(test g-type-is-derived
  (is-false (g:type-is-derived gobject:+g-type-invalid+))
  (is-false (g:type-is-derived gobject:+g-type-none+))
  (is-false (g:type-is-derived gobject:+g-type-interface+))
  (is-false (g:type-is-derived gobject:+g-type-char+))
  (is-false (g:type-is-derived gobject:+g-type-uchar+))
  (is-false (g:type-is-derived gobject:+g-type-boolean+))
  (is-false (g:type-is-derived gobject:+g-type-int+))
  (is-false (g:type-is-derived gobject:+g-type-uint+))
  (is-false (g:type-is-derived gobject:+g-type-long+))
  (is-false (g:type-is-derived gobject:+g-type-ulong+))
  (is-false (g:type-is-derived gobject:+g-type-int64+))
  (is-false (g:type-is-derived gobject:+g-type-uint64+))
  (is-false (g:type-is-derived gobject:+g-type-enum+))
  (is-false (g:type-is-derived gobject:+g-type-flags+))
  (is-false (g:type-is-derived gobject:+g-type-float+))
  (is-false (g:type-is-derived gobject:+g-type-double+))
  (is-false (g:type-is-derived gobject:+g-type-string+))
  (is-false (g:type-is-derived gobject:+g-type-pointer+))
  (is-false (g:type-is-derived gobject:+g-type-boxed+))
  (is-false (g:type-is-derived gobject:+g-type-param+))
  (is-false (g:type-is-derived gobject:+g-type-object+))
  (is-true  (g:type-is-derived gobject:+g-type-gtype+))
  (is-false (g:type-is-derived gobject:+g-type-variant+))
  (is-true  (g:type-is-derived gobject:+g-type-checksum+))
  (is-true  (g:type-is-derived "GApplication"))
  (is-true  (g:type-is-derived "GAction"))
  (is-true  (g:type-is-derived "GSimpleAction"))
  (is-true  (g:type-is-derived "GApplicationFlags"))
  (is-true  (g:type-is-derived "GEmblemOrigin"))
  (is-true  (g:type-is-derived "GVariantType")))

;;;   g_type_is_fundamental

(test g-type-is-fundamental
  (is-true  (g:type-is-fundamental gobject:+g-type-invalid+))
  (is-true  (g:type-is-fundamental gobject:+g-type-none+))
  (is-true  (g:type-is-fundamental gobject:+g-type-interface+))
  (is-true  (g:type-is-fundamental gobject:+g-type-char+))
  (is-true  (g:type-is-fundamental gobject:+g-type-uchar+))
  (is-true  (g:type-is-fundamental gobject:+g-type-boolean+))
  (is-true  (g:type-is-fundamental gobject:+g-type-int+))
  (is-true  (g:type-is-fundamental gobject:+g-type-uint+))
  (is-true  (g:type-is-fundamental gobject:+g-type-long+))
  (is-true  (g:type-is-fundamental gobject:+g-type-ulong+))
  (is-true  (g:type-is-fundamental gobject:+g-type-int64+))
  (is-true  (g:type-is-fundamental gobject:+g-type-uint64+))
  (is-true  (g:type-is-fundamental gobject:+g-type-enum+))
  (is-true  (g:type-is-fundamental gobject:+g-type-flags+))
  (is-true  (g:type-is-fundamental gobject:+g-type-float+))
  (is-true  (g:type-is-fundamental gobject:+g-type-double+))
  (is-true  (g:type-is-fundamental gobject:+g-type-string+))
  (is-true  (g:type-is-fundamental gobject:+g-type-pointer+))
  (is-true  (g:type-is-fundamental gobject:+g-type-boxed+))
  (is-true  (g:type-is-fundamental gobject:+g-type-param+))
  (is-true  (g:type-is-fundamental gobject:+g-type-object+))
  (is-false (g:type-is-fundamental gobject:+g-type-gtype+))
  (is-true  (g:type-is-fundamental gobject:+g-type-variant+))
  (is-false (g:type-is-fundamental gobject:+g-type-checksum+))
  (is-false (g:type-is-fundamental "GApplication"))
  (is-false (g:type-is-fundamental "GAction"))
  (is-false (g:type-is-fundamental "GSimpleAction"))
  (is-false (g:type-is-fundamental "GApplicationFlags"))
  (is-false (g:type-is-fundamental "GEmblemOrigin"))
  (is-false (g:type-is-fundamental "GVariantType")))

;;;   g_type_is_value_type

(test g-type-is-value-type
  (is-false (g:type-is-value-type gobject:+g-type-invalid+))
  (is-false (g:type-is-value-type gobject:+g-type-none+))
  (is-false (g:type-is-value-type gobject:+g-type-interface+))
  (is-true  (g:type-is-value-type gobject:+g-type-char+))
  (is-true  (g:type-is-value-type gobject:+g-type-uchar+))
  (is-true  (g:type-is-value-type gobject:+g-type-boolean+))
  (is-true  (g:type-is-value-type gobject:+g-type-int+))
  (is-true  (g:type-is-value-type gobject:+g-type-uint+))
  (is-true  (g:type-is-value-type gobject:+g-type-long+))
  (is-true  (g:type-is-value-type gobject:+g-type-ulong+))
  (is-true  (g:type-is-value-type gobject:+g-type-int64+))
  (is-true  (g:type-is-value-type gobject:+g-type-uint64+))
  (is-false (g:type-is-value-type gobject:+g-type-enum+))
  (is-false (g:type-is-value-type gobject:+g-type-flags+))
  (is-true  (g:type-is-value-type gobject:+g-type-float+))
  (is-true  (g:type-is-value-type gobject:+g-type-double+))
  (is-true  (g:type-is-value-type gobject:+g-type-string+))
  (is-true  (g:type-is-value-type gobject:+g-type-pointer+))
  (is-false (g:type-is-value-type gobject:+g-type-boxed+))
  (is-true  (g:type-is-value-type gobject:+g-type-param+))
  (is-true  (g:type-is-value-type gobject:+g-type-object+))
  (is-true  (g:type-is-value-type gobject:+g-type-gtype+))
  (is-true  (g:type-is-value-type gobject:+g-type-variant+))
  (is-true  (g:type-is-value-type gobject:+g-type-checksum+))
  (is-true  (g:type-is-value-type "GApplication"))
  (is-true  (g:type-is-value-type "GAction"))
  (is-true  (g:type-is-value-type "GSimpleAction"))
  (is-true  (g:type-is-value-type "GApplicationFlags"))
  (is-true  (g:type-is-value-type "GEmblemOrigin"))
  (is-true  (g:type-is-value-type "GVariantType")))

;;;   g_type_has_value_table                               not exported

;;;   g_type_is_classed

(test g-type-is-classed
  (is-false (g:type-is-classed gobject:+g-type-invalid+))
  (is-false (g:type-is-classed gobject:+g-type-none+))
  (is-false (g:type-is-classed gobject:+g-type-interface+))
  (is-false (g:type-is-classed gobject:+g-type-char+))
  (is-false (g:type-is-classed gobject:+g-type-uchar+))
  (is-false (g:type-is-classed gobject:+g-type-boolean+))
  (is-false (g:type-is-classed gobject:+g-type-int+))
  (is-false (g:type-is-classed gobject:+g-type-uint+))
  (is-false (g:type-is-classed gobject:+g-type-long+))
  (is-false (g:type-is-classed gobject:+g-type-ulong+))
  (is-false (g:type-is-classed gobject:+g-type-int64+))
  (is-false (g:type-is-classed gobject:+g-type-uint64+))
  (is-true  (g:type-is-classed gobject:+g-type-enum+))
  (is-true  (g:type-is-classed gobject:+g-type-flags+))
  (is-false (g:type-is-classed gobject:+g-type-float+))
  (is-false (g:type-is-classed gobject:+g-type-double+))
  (is-false (g:type-is-classed gobject:+g-type-string+))
  (is-false (g:type-is-classed gobject:+g-type-pointer+))
  (is-false (g:type-is-classed gobject:+g-type-boxed+))
  (is-true  (g:type-is-classed gobject:+g-type-param+))
  (is-true  (g:type-is-classed gobject:+g-type-object+))
  (is-false (g:type-is-classed gobject:+g-type-variant+))
  (is-true  (g:type-is-classed "GApplication"))
  (is-false (g:type-is-classed "GAction"))
  (is-true  (g:type-is-classed "GSimpleAction"))
  (is-true  (g:type-is-classed "GApplicationFlags"))
  (is-true  (g:type-is-classed "GEmblemOrigin"))
  (is-false (g:type-is-classed "GVariantType")))

;;;   g_type_is_instantiatable                             not exported
;;;   g_type_is_derivable                                  not exported
;;;   g_type_is_deep_derivable                             not exported

;;; g_type_is_interface

(test g-type-is-interface
  (is-false (g:type-is-interface gobject:+g-type-invalid+))
  (is-false (g:type-is-interface gobject:+g-type-none+))
  (is-true  (g:type-is-interface gobject:+g-type-interface+))
  (is-false (g:type-is-interface gobject:+g-type-char+))
  (is-false (g:type-is-interface gobject:+g-type-uchar+))
  (is-false (g:type-is-interface gobject:+g-type-boolean+))
  (is-false (g:type-is-interface gobject:+g-type-int+))
  (is-false (g:type-is-interface gobject:+g-type-uint+))
  (is-false (g:type-is-interface gobject:+g-type-long+))
  (is-false (g:type-is-interface gobject:+g-type-ulong+))
  (is-false (g:type-is-interface gobject:+g-type-int64+))
  (is-false (g:type-is-interface gobject:+g-type-uint64+))
  (is-false (g:type-is-interface gobject:+g-type-enum+))
  (is-false (g:type-is-interface gobject:+g-type-flags+))
  (is-false (g:type-is-interface gobject:+g-type-float+))
  (is-false (g:type-is-interface gobject:+g-type-double+))
  (is-false (g:type-is-interface gobject:+g-type-string+))
  (is-false (g:type-is-interface gobject:+g-type-pointer+))
  (is-false (g:type-is-interface gobject:+g-type-boxed+))
  (is-false (g:type-is-interface gobject:+g-type-param+))
  (is-false (g:type-is-interface gobject:+g-type-object+))
  (is-false (g:type-is-interface gobject:+g-type-variant+))
  (is-false (g:type-is-interface "GApplication"))
  (is-true  (g:type-is-interface "GAction"))
  (is-false (g:type-is-interface "GSimpleAction"))
  (is-false (g:type-is-interface "GApplicationFlags"))
  (is-false (g:type-is-interface "GEmblemOrigin"))
  (is-false (g:type-is-interface "GVariantType")))

;;; G_TYPE_FROM_INSTANCE

(test g-type-from-instance
  (signals (error) (g:type-from-instance nil))
  (is (eq (g:gtype "GSimpleAction")
          (g:type-from-instance (make-instance 'g:simple-action)))))

;;;   G_TYPE_FROM_CLASS

(test g-type-from-class
  (is (eq (g:gtype "GApplication")
          (g:type-from-class (g:type-class-ref "GApplication"))))
  (is (eq (g:gtype "GSimpleAction")
          (g:type-from-class (g:type-class-ref "GSimpleAction")))))

;;;   G_TYPE_FROM_INTERFACE

(test g-type-from-interface
  (is (eq (g:gtype "GAction")
          (g:type-from-interface
              (g:type-default-interface-ref "GAction")))))

;;;     g-type-instance-class

(test g-type-instance-class
  (is (eq (g:gtype "GSimpleAction")
          (g:type-from-class
              (g:type-instance-class (make-instance 'g:simple-action))))))

;;;     G_TYPE_INSTANCE_GET_INTERFACE                      not implemented
;;;     G_TYPE_INSTANCE_GET_PRIVATE                        not implemented
;;;     G_TYPE_CLASS_GET_PRIVATE                           not implemented
;;;     G_TYPE_CHECK_INSTANCE                              not implemented
;;;     G_TYPE_CHECK_INSTANCE_CAST                         not implemented

;;;     G_TYPE_CHECK_INSTANCE_TYPE

(test g-type-check-instance-type
  (let ((action (make-instance 'g:simple-action)))
    (is-true (g:type-check-instance-type action "GObject"))
    (is-true (g:type-check-instance-type action "GAction"))))

;;;     G_TYPE_CHECK_CLASS_CAST                            not implemented

;;;   G_TYPE_CHECK_CLASS_TYPE

(test g-type-check-class-type
  (is-true  (g:type-check-class-type (g:type-class-ref "GSimpleAction")
                                     "GObject")))

;;;     G_TYPE_CHECK_VALUE                                 not implemented
;;;     G_TYPE_CHECK_VALUE_TYPE                            not implemented
;;;
;;;     g_type_init
;;;     g_type_init_with_debug_flags                       not implemented

;;;   g_type_name

(test g-type-name
  (is (equal "gdouble" (g:type-name gobject:+g-type-double+)))
  (is (equal "GBoxed" (g:type-name gobject:+g-type-boxed+)))
  (is (equal "GApplication" (g:type-name (g:gtype "GApplication")))))

;;;     g_type_qname

;;;   g_type_from_name

(test g-type-from-name
  (is (eq (g:gtype "gdouble") (g:type-from-name "gdouble")))
  (is (eq (g:gtype "GBoxed") (g:type-from-name "GBoxed")))
  (is (eq (g:gtype "GApplication") (g:type-from-name "GApplication"))))

;;;     g_type_parent
;;;     g_type_depth
;;;     g_type_next_base

;;;     g_type_is_a

(test g-type-is-a
  (is-true (g:type-is-a "gboolean" gobject:+g-type-boolean+))
  (is-true (g:type-is-a "GResource" gobject:+g-type-boxed+))
  (is-true (g:type-is-a "gchar" gobject:+g-type-char+))
  (is-true (g:type-is-a "GChecksum" gobject:+g-type-checksum+))
  (is-true (g:type-is-a "gdouble" gobject:+g-type-double+))
  (is-true (g:type-is-a "GEmblemOrigin" gobject:+g-type-enum+))
  (is-true (g:type-is-a "GApplicationFlags" gobject:+g-type-flags+))
  (is-true (g:type-is-a "gfloat" gobject:+g-type-float+))
  (is-true (g:type-is-a "GType" gobject:+g-type-gtype+))
  (is-true (g:type-is-a "gint" gobject:+g-type-int+))
  (is-true (g:type-is-a "gint64" gobject:+g-type-int64+))
  (is-true (g:type-is-a "unknown" gobject:+g-type-invalid+))
  (is-true (g:type-is-a "glong" gobject:+g-type-long+))
  (is-true (g:type-is-a "void" gobject:+g-type-none+))
  (is-true (g:type-is-a "GApplication" gobject:+g-type-object+))
  (is-true (g:type-is-a "GParamBoolean" gobject:+g-type-param+))
  (is-true (g:type-is-a "gpointer" gobject:+g-type-pointer+))
  (is-true (g:type-is-a "gchararray" gobject:+g-type-string+))
  (is-true (g:type-is-a "guchar" gobject:+g-type-uchar+))
  (is-true (g:type-is-a "guint" gobject:+g-type-uint+))
  (is-true (g:type-is-a "guint64" gobject:+g-type-uint64+))
  (is-true (g:type-is-a "gulong" gobject:+g-type-ulong+))
  (is-true (g:type-is-a "GVariant" gobject:+g-type-variant+)))

;;;     g_type_class_ref
;;;     g_type_class_unref

(test g-type-class-ref
  (let ((class nil))
    ;; gtype is a string
    (is (cffi:pointerp (setf class (g:type-class-ref "GSimpleAction"))))
    (is (eq (g:gtype "GSimpleAction") (g:type-from-class class)))
    (is-false (g:type-class-unref class))
    ;; gtype is a ID
    (is (cffi:pointerp (setf class
                             (g:type-class-ref
                               (glib::gtype-id (g:gtype "GSimpleAction"))))))
    (is (eq (g:gtype "GSimpleAction") (g:type-from-class class)))
    (is-false (g:type-class-unref class))
    ;; gtype is a g-type
    (is (cffi:pointerp (setf class
                             (g:type-class-ref (g:gtype "GSimpleAction")))))
    (is (eq (g:gtype "GSimpleAction") (g:type-from-class class)))
    (is-false (g:type-class-unref class))))

;;;     g_type_class_peek
;;;     g_type_class_peek_static
;;;     g_type_class_peek_parent
;;;     g_type_class_add_private
;;;     g_type_add_class_private                           not implemented
;;;     g_type_interface_peek
;;;     g_type_interface_peek_parent                       not implemented
;;;     g_type_default_interface_ref
;;;     g_type_default_interface_peek
;;;     g_type_default_interface_unref
;;;     g_type_children
;;;     g_type_interfaces
;;;     g_type_interface_prerequisites

;;;     g-type-qdata

(test g-type-qdata.1
  ;; Attach and read data for a "gboolean" type
  (is (string= "a string" (setf (g:type-qdata "gboolean" "mydata") "a string")))
  (is (string= "a string" (g:type-qdata "gboolean" "mydata")))
  (is (equal '(A B C) (setf (g:type-qdata "gboolean" "mydata") '(a b c))))
  (is (equal '(A B C) (g:type-qdata "gboolean" "mydata")))
  (is-false (setf (g:type-qdata "gboolean" "mydata") nil))
  (is-false (g:type-qdata "gboolean" "mydata")))

(test g-type-qdata.2
  ;; Attach and read data for a "GSimpleAction" type
  (is (string= "a string"
               (setf (g:type-qdata "GSimpleAction" "mydata") "a string")))
  (is (string= "a string" (g:type-qdata "GSimpleAction" "mydata")))
  (is (equal '(A B C) (setf (g:type-qdata "GSimpleAction" "mydata") '(a b c))))
  (is (equal '(A B C) (g:type-qdata "GSimpleAction" "mydata")))
  (is-false (setf (g:type-qdata "GSimpleAction" "mydata") nil))
  (is-false (g:type-qdata "GSimpleAction" "mydata")))

;;;     g_type_query                                       not exported
;;;     g_type_register_static                             not exported
;;;     g_type_register_static_simple                      not exported
;;;     g_type_register_dynamic                            not implemented
;;;     g_type_register_fundamental                        not implemented
;;;     g_type_add_interface_static                        not exported
;;;     g_type_add_interface_dynamic                       not implemented
;;;     g_type_interface_add_prerequisite                  not exported
;;;     g_type_get_plugin                                  not implemented
;;;     g_type_interface_get_plugin                        not implemented
;;;     g_type_fundamental_next                            not exported
;;;     g_type_create_instance                             not implemented
;;;     g_type_free_instance                               not implemented
;;;     g_type_add_class_cache_func                        not implemented
;;;     g_type_remove_class_cache_func                     not implemented
;;;     g_type_class_unref_uncached                        not implemented
;;;     g_type_add_interface_check                         not implemented
;;;     g_type_remove_interface_check                      not implemented
;;;     g_type_value_table_peek                            not exported
;;;     g_type_ensure                                      not exported
;;;     g_type_get_type_registration_serial                not implemented
;;;     G_DEFINE_TYPE                                      not implemented
;;;     G_DEFINE_TYPE_WITH_CODE                            not implemented
;;;     G_DEFINE_ABSTRACT_TYPE                             not implemented
;;;     G_DEFINE_ABSTRACT_TYPE_WITH_CODE                   not implemented
;;;     G_DEFINE_INTERFACE                                 not implemented
;;;     G_DEFINE_INTERFACE_WITH_CODE                       not implemented
;;;     G_IMPLEMENT_INTERFACE                              not implemented
;;;     G_DEFINE_TYPE_EXTENDED                             not implemented
;;;     G_DEFINE_BOXED_TYPE                                not implemented
;;;     G_DEFINE_BOXED_TYPE_WITH_CODE                      not implemented
;;;     G_DEFINE_POINTER_TYPE                              not implemented
;;;     G_DEFINE_POINTER_TYPE_WITH_CODE                    not implemented

;;; --- 2023-7-9 ---------------------------------------------------------------
