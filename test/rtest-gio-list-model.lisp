(in-package :glib-test)

(def-suite gio-list-model :in gio-suite)
(in-suite gio-list-model)

;;; --- Types and Values -------------------------------------------------------

;;;     GListModel

(test g-list-model-interface
  ;; Check type
  (is (g:type-is-interface "GListModel"))
  ;; Check registered symbol
  (is (eq 'g:list-model
          (glib:symbol-for-gtype "GListModel")))
  ;; Check type initializer
  (is (eq (g:gtype "GListModel")
          (g:gtype (cffi:foreign-funcall "g_list_model_get_type" :size))))
  ;; Check interface prerequisites
  (is (equal '("GObject")
             (glib-test:list-interface-prerequisites "GListModel")))
  ;; Check interface properties
  (is (equal '()
             (glib-test:list-interface-properties "GListModel")))
  ;; Check signals
  (is (equal '("items-changed")
             (glib-test:list-signals "GListModel")))
  ;; Check interface definition
  (is (equal '(GOBJECT:DEFINE-GINTERFACE "GListModel" GIO:LIST-MODEL
                       (:EXPORT T
                        :TYPE-INITIALIZER "g_list_model_get_type"))
             (gobject:get-gtype-definition "GListModel"))))

;;; --- Signals ----------------------------------------------------------------

;;;     items-changed

(test g-list-model-items-changed-signal
  (let ((query (g:signal-query (g:signal-lookup "items-changed" "GListModel"))))
    (is (string= "items-changed" (g:signal-query-signal-name query)))
    (is (string= "GListModel" (g:type-name (g:signal-query-owner-type query))))
    (is (equal '(:RUN-LAST)
               (sort (g:signal-query-signal-flags query) #'string<)))
    (is (string= "void" (g:type-name (g:signal-query-return-type query))))
    (is (equal '("guint" "guint" "guint")
               (mapcar #'g:type-name (g:signal-query-param-types query))))
    (is-false (g:signal-query-signal-detail query))))

;;; --- Functions --------------------------------------------------------------

;;;     g_list_model_get_item_type
;;;     g_list_model_get_n_items
;;;     g_list_model_get_item

(test g-list-model-get.1
  (let ((store (g:list-store-new "GObject")))
    ;; Append some objects
    (is-false (g:list-store-append store (make-instance 'g:simple-action)))
    (is-false (g:list-store-append store (make-instance 'g:menu-item)))
    ;; Use the interace functions
    (is (eq (g:gtype "GObject") (g:list-model-item-type store)))
    (is (= 2 (g:list-model-n-items store)))

    (is (cffi:pointerp (g:list-model-item store 0)))
    (is (typep (cffi:convert-from-foreign (g:list-model-item store 0)
                                          'g:object)
               'g:simple-action))
    (is (typep (g:list-model-object store 0) 'g:simple-action))

    (is (cffi:pointerp (g:list-model-item store 1)))
    (is (typep (cffi:convert-from-foreign (g:list-model-item store 1)
                                          'g:object)
               'g:menu-item))
    (is (typep (g:list-model-object store 1) 'g:menu-item))
    ;; Access an invalid position
    (is (cffi:null-pointer-p (g:list-model-item store 2)))
    (is-false  (g:list-model-object store 2))))

(test g-list-model-get.2
  (let ((store (g:list-store-new "GAction")))
    ;; Append some objects
    (is-false (g:list-store-append store (make-instance 'g:simple-action)))
    (is-false (g:list-store-append store (make-instance 'g:simple-action)))
    ;; Use the interace functions
    (is (eq (g:gtype "GAction") (g:list-model-item-type store)))
    (is (= 2 (g:list-model-n-items store)))
    (is (cffi:pointerp (g:list-model-item store 0)))
    (is (typep (g:list-model-object store 0) 'g:simple-action))
    (is (typep (g:list-model-object store 1) 'g:simple-action))))

;;;     g_list_model_get_object

(test g-list-model-object
  (let ((store (g:list-store-new "GObject"))
        (object nil))
    ;; Append some objects
    (is-false (g:list-store-append store (make-instance 'g:simple-action)))
    (is-false (g:list-store-append store (make-instance 'g:menu-item)))
    ;; Get an object from the list store
    (is (typep (setf object
                     (g:list-model-object store 0)) 'g:simple-action))
    (is (= 2 (g:object-ref-count object)))
    ;; Get the object a second time from the list store
    (is (typep (setf object
                     (g:list-model-object store 0)) 'g:simple-action))
    (is (= 2 (g:object-ref-count object)))))

;;;     g_list_model_items_changed

;;; 2024-10-1
