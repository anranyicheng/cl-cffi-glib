(in-package :glib-test)

(def-suite gio-action-group :in gio-suite)
(in-suite gio-action-group)

(defparameter *verbose-g-action-group* nil)

(defun change-state (action parameter)
  (when *verbose-g-action-group*
    (format t "~%in CHANGE-STATE~%")
    (format t "     action : ~a~%" (g:action-name action))
    (format t "  parameter : ~a~%" (g:variant-boolean parameter)))
  (setf (g:action-state action) parameter))

(defun change-radio-state (action parameter)
  (when *verbose-g-action-group*
    (format t "~%in CHANGE-RADIO-STATE~%")
    (format t "     action : ~a~%" (g:action-name action))
    (format t "  parameter : ~a~%" (g:variant-string parameter)))
  (setf (g:action-state action) parameter))

(defparameter *action-entries*
              (list (list "paste" nil nil nil nil)
                    (list "copy" nil nil nil nil)
                    (list "toolbar" nil "b" "true" #'change-state)
                    (list "statusbar" nil "b" "false" #'change-state)
                    (list "sources" nil "s" "'vala'" #'change-radio-state)
                    (list "markup" nil "s" "'html'" #'change-radio-state)))

;;; --- Types and Values -------------------------------------------------------

;;;     GActionGroup

(test g-action-group-interface
  ;; Check type
  (is (g:type-is-interface "GActionGroup"))
  ;; Check registered symbol
  (is (eq 'g:action-group
          (glib:symbol-for-gtype "GActionGroup")))
  ;; Check type initializer
  (is (eq (g:gtype "GActionGroup")
          (g:gtype (cffi:foreign-funcall "g_action_group_get_type" :size))))
  ;; Check interface prerequisites
  (is (equal '("GObject")
             (glib-test:list-interface-prerequisites "GActionGroup")))
  ;; Check interface properties
  (is (equal '()
             (glib-test:list-interface-properties "GActionGroup")))
  ;; Check signals
  (is (equal '("action-added" "action-enabled-changed" "action-removed"
               "action-state-changed")
             (glib-test:list-signals "GActionGroup")))
  ;; Check interface definition
  (is (equal '(GOBJECT:DEFINE-GINTERFACE "GActionGroup" GIO:ACTION-GROUP
                      (:EXPORT T
                       :TYPE-INITIALIZER "g_action_group_get_type"))
             (gobject:get-gtype-definition "GActionGroup"))))

;;; --- Signals ----------------------------------------------------------------

;;;     action-added

(test g-action-group-action-added-signal
  (let* ((name "action-added")
         (gtype (g:gtype "GActionGroup"))
         (query (g:signal-query (g:signal-lookup name gtype))))
    ;; Retrieve name and gtype
    (is (string= name (g:signal-query-signal-name query)))
    (is (eq gtype (g:signal-query-owner-type query)))
    ;; Check flags
    (is (equal '(:DETAILED :RUN-LAST)
               (sort (g:signal-query-signal-flags query) #'string<)))
    ;; Check return type
    (is (eq (g:gtype "void") (g:signal-query-return-type query)))
    ;; Check parameter types
    (is (equal '("gchararray")
               (mapcar #'g:type-name (g:signal-query-param-types query))))))

;;;     action-enabled-changed

(test g-action-group-action-enabled-changed-signal
  (let* ((name "action-enabled-changed")
         (gtype (g:gtype "GActionGroup"))
         (query (g:signal-query (g:signal-lookup name gtype))))
    ;; Retrieve name and gtype
    (is (string= name (g:signal-query-signal-name query)))
    (is (eq gtype (g:signal-query-owner-type query)))
    ;; Check flags
    (is (equal '(:DETAILED :RUN-LAST)
               (sort (g:signal-query-signal-flags query) #'string<)))
    ;; Check return type
    (is (eq (g:gtype "void") (g:signal-query-return-type query)))
    ;; Check parameter types
    (is (equal '("gchararray" "gboolean")
               (mapcar #'g:type-name (g:signal-query-param-types query))))))

;;;     action-removed

(test g-action-group-action-removed-signal
  (let* ((name "action-removed")
         (gtype (g:gtype "GActionGroup"))
         (query (g:signal-query (g:signal-lookup name gtype))))
    ;; Retrieve name and gtype
    (is (string= name (g:signal-query-signal-name query)))
    (is (eq gtype (g:signal-query-owner-type query)))
    ;; Check flags
    (is (equal '(:DETAILED :RUN-LAST)
               (sort (g:signal-query-signal-flags query) #'string<)))
    ;; Check return type
    (is (eq (g:gtype "void") (g:signal-query-return-type query)))
    ;; Check parameter types
    (is (equal '("gchararray")
               (mapcar #'g:type-name (g:signal-query-param-types query))))))

;;;     action-state-changed

(test g-action-group-action-state-changed-signal
  (let* ((name "action-state-changed")
         (gtype (g:gtype "GActionGroup"))
         (query (g:signal-query (g:signal-lookup name gtype))))
    ;; Retrieve name and gtype
    (is (string= name (g:signal-query-signal-name query)))
    (is (eq gtype (g:signal-query-owner-type query)))
    ;; Check flags
    (is (equal '(:DETAILED :MUST-COLLECT :RUN-LAST)
               (sort (g:signal-query-signal-flags query) #'string<)))
    ;; Check return type
    (is (eq (g:gtype "void") (g:signal-query-return-type query)))
    ;; Check parameter types
    (is (equal '("gchararray" "GVariant")
               (mapcar #'g:type-name (g:signal-query-param-types query))))))

;;; --- Functions --------------------------------------------------------------

;;;     g_action_group_list_actions

(test g-action-group-list-actions
  (glib-test:with-check-memory (group)
    (setf group (g:simple-action-group-new))
    (is (equal '() (g:action-group-list-actions group)))
    (is-false (g:action-map-add-action-entries group *action-entries*))
    (is (equal '("markup" "paste" "statusbar" "sources" "copy" "toolbar")
               (g:action-group-list-actions group)))
    ;; Remove references
    (is-false (map nil (lambda (x)
                         (g:action-map-remove-action group x))
                       (g:action-group-list-actions group)))
    (is-false (g:action-group-list-actions group))))

;;;     g_action_group_query_action                         not implemented

;;;     g_action_group_has_action

(test g-action-group-has-action
  (glib-test:with-check-memory (group)
    (setf group (g:simple-action-group-new))
    (is-false (g:action-map-add-action-entries group *action-entries*))
    (is-true (g:action-group-has-action group "copy"))
    (is-true (g:action-group-has-action group "paste"))
    (is-false (g:action-group-has-action group "unknonw"))
    ;; Remove references
    (is-false (map nil (lambda (x)
                         (g:action-map-remove-action group x))
                       (g:action-group-list-actions group)))
    (is-false (g:action-group-list-actions group))))

;;;     g_action_group_get_action_enabled

(test g-action-group-action-enabled
  (glib-test:with-check-memory (group)
    (setf group (g:simple-action-group-new))
    (is-false (g:action-map-add-action-entries group *action-entries*))
    (is-true (g:action-group-action-enabled group "copy"))
    (is-true (g:action-group-action-enabled group "paste"))
    (is-false (setf (g:action-enabled (g:action-map-lookup-action group "copy"))
                    nil))
    (is-false (g:action-group-action-enabled group "copy"))
    ;; Remove references
    (is-false (map nil (lambda (x)
                         (g:action-map-remove-action group x))
                       (g:action-group-list-actions group)))
    (is-false (g:action-group-list-actions group))))

;;;     g_action_group_get_action_parameter_type

(test g-action-group-action-parameter-type
  (glib-test:with-check-memory (group)
    (setf group (g:simple-action-group-new))
    (is-false (g:action-map-add-action-entries group *action-entries*))
    ;; Does not return a g:variant-type, but nil
    (is-false (g:action-group-action-parameter-type group "copy"))
    ;; Again this code works as expected, the return value is nil
    (let ((action (g:action-map-lookup-action group "copy")))
      (is-false (g:action-parameter-type action)))
    ;; This is the expected case for a valid g:variant-type
    (is (typep (g:action-group-action-parameter-type group "markup")
               'g:variant-type))
    (is (string= "s"
                 (g:variant-type-dup-string
                   (g:action-group-action-parameter-type group "markup"))))
    ;; Remove references
    (is-false (map nil (lambda (x)
                         (g:action-map-remove-action group x))
                       (g:action-group-list-actions group)))
    (is-false (g:action-group-list-actions group))))

;;;     g_action_group_get_action_state_type

(test g-action-group-action-state-type
  (glib-test:with-check-memory (group)
    (setf group (g:simple-action-group-new))
    (is-false (g:action-map-add-action-entries group *action-entries*))
    ;; Does not return a g:variant-type instance, but nil
    (is-false (g:action-group-action-state-type group "copy"))
    ;; Again this code works as expected, the return value is nil
    (let ((action (g:action-map-lookup-action group "copy")))
      (is-false (g:action-state-type action)))
    ;; This is case with for a valid g:variant-type
    (is (typep (g:action-group-action-state-type group "toolbar")
               'g:variant-type))
    (is (string= "b"
                 (g:variant-type-dup-string
                   (g:action-group-action-parameter-type group "toolbar"))))
    ;; Remove references
    (is-false (map nil (lambda (x)
                         (g:action-map-remove-action group x))
                       (g:action-group-list-actions group)))
    (is-false (g:action-group-list-actions group))))

;;;     g_action_group_get_action_state_hint

(test g-action-group-action-state-hint
  (glib-test:with-check-memory (group)
    (setf group (g:simple-action-group-new))
    (is-false (g:action-map-add-action-entries group *action-entries*))
    ;; We get a null-pointer
    (is (cffi:null-pointer-p (g:action-group-action-state-hint group "copy")))
    (let ((action (g:action-map-lookup-action group "copy")))
      (is (cffi:null-pointer-p (g:action-state-hint action))))
    ;; We get a null-pointer
    (is (cffi:null-pointer-p (g:action-group-action-state-hint group "toolbar")))
    (let ((action (g:action-map-lookup-action group "toolbar")))
      (is (cffi:null-pointer-p (g:action-state-hint action))))
    ;; We get a null-pointer
    (is (cffi:null-pointer-p (g:action-group-action-state-hint group "sources")))
    (let ((action (g:action-map-lookup-action group "sources")))
      (is (cffi:null-pointer-p (g:action-state-hint action))))
    ;; Set a state hint and retrieve the state hint
    (let* ((str1 (g:variant-new-string "html"))
           (str2 (g:variant-new-string "xml"))
           (hint (g:variant-new-tuple str1 str2))
           (action (g:action-map-lookup-action group "markup")))
      ;; Set a state hint
      (is-false (g:simple-action-set-state-hint action hint))
      ;; Get the state hint
      (is (string= "('html', 'xml')"
                   (g:variant-print (g:action-state-hint action))))
      (is (string= "('html', 'xml')"
                   (g:variant-print
                       (g:action-group-action-state-hint group "markup")))))
    ;; Remove references
    (is-false (map nil (lambda (x)
                         (g:action-map-remove-action group x))
                       (g:action-group-list-actions group)))
    (is-false (g:action-group-list-actions group))))

;;;     g_action_group_get_action_state

(test g-action-group-action-state
  (glib-test:with-check-memory (group)
    (setf group (g:simple-action-group-new))
    (is-false (g:action-map-add-action-entries group *action-entries*))
    (is (cffi:null-pointer-p (g:action-group-action-state group "copy")))
    (is (cffi:null-pointer-p (g:action-group-action-state group "paste")))
    (is-true (g:variant-boolean (g:action-group-action-state group "toolbar")))
    (is-false (g:variant-boolean (g:action-group-action-state group "statusbar")))
    (is (string= "vala"
                 (g:variant-string (g:action-group-action-state group
                                                                "sources"))))
    (is (string= "html"
                 (g:variant-string (g:action-group-action-state group
                                                                "markup"))))
    ;; Remove references
    (is-false (map nil (lambda (x)
                         (g:action-map-remove-action group x))
                       (g:action-group-list-actions group)))
    (is-false (g:action-group-list-actions group))))

;;;     g_action_group_change_action_state

(test g-action-group-action-change-action-state
  (glib-test:with-check-memory (group)
    (setf group (g:simple-action-group-new))
    (is-false (g:action-map-add-action-entries group *action-entries*))
    ;; Change a boolean state
    (is-true (g:variant-boolean (g:action-group-action-state group "toolbar")))
    (is-false (g:action-group-change-action-state group "toolbar"
                                                  (g:variant-new-boolean nil)))
    (is-false (g:variant-boolean (g:action-group-action-state group "toolbar")))
    ;; Change a string state
    (is (string= "vala"
                 (g:variant-string
                     (g:action-group-action-state group "sources"))))
    (is-false (g:action-group-change-action-state
                                            group "sources"
                                            (g:variant-new-string "new value")))
    (is (string= "new value"
                 (g:variant-string
                     (g:action-group-action-state group "sources"))))
    ;; Remove references
    (is-false (map nil (lambda (x)
                         (g:action-map-remove-action group x))
                       (g:action-group-list-actions group)))
    (is-false (g:action-group-list-actions group))))

;;;     g_action_group_activate_action

(test g-action-group-activate-action
  (glib-test:with-check-memory (group)
    (setf group (g:simple-action-group-new))
    (is-false (g:action-map-add-action-entries group *action-entries*))

    (is-false (g:action-group-activate-action group "copy" (cffi:null-pointer)))
    (is-false (g:action-group-activate-action group "toolbar"
                                                    (g:variant-new-boolean t)))
    (is-false (g:action-group-activate-action group "sources"
                                              (g:variant-new-string "new value")))
    ;; Remove references
    (is-false (map nil (lambda (x)
                         (g:action-map-remove-action group x))
                       (g:action-group-list-actions group)))
    (is-false (g:action-group-list-actions group))))

;;;     g_action_group_action_added
;;;     g_action_group_action_removed
;;;     g_action_group_action_enabled_changed
;;;     g_action_group_action_state_changed

;;; 2025-2-3
