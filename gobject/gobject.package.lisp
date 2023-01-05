;;; ----------------------------------------------------------------------------
;;; gobject.package.lisp
;;;
;;; The documentation of this file is taken from the GObject Reference Manual
;;; Version 2.74 and modified to document the Lisp binding to the GObject
;;; library. See <http://www.gtk.org>. The API documentation of the Lisp binding
;;; is available from <http://www.crategus.com/books/cl-cffi-gtk/>.
;;;
;;; Copyright (C) 2009 - 2011 Kalyanov Dmitry
;;; Copyright (C) 2011 - 2022 Dieter Kaiser
;;;
;;; This program is free software: you can redistribute it and/or modify
;;; it under the terms of the GNU Lesser General Public License for Lisp
;;; as published by the Free Software Foundation, either version 3 of the
;;; License, or (at your option) any later version and with a preamble to
;;; the GNU Lesser General Public License that clarifies the terms for use
;;; with Lisp programs and is referred as the LLGPL.
;;;
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU Lesser General Public License for more details.
;;;
;;; You should have received a copy of the GNU Lesser General Public
;;; License along with this program and the preamble to the Gnu Lesser
;;; General Public License.  If not, see <http://www.gnu.org/licenses/>
;;; and <http://opensource.franz.com/preamble.html>.
;;; ----------------------------------------------------------------------------

(defpackage :gobject
  (:use :closer-common-lisp :iterate) ; :closer-common-lisp includes :cl
  (:import-from :cffi #:defcfun
                      #:defcvar
                      #:defctype
                      #:defcenum
                      #:defcunion
                      #:defbitfield
                      #:defcstruct
                      #:defcallback
                      #:define-foreign-type
                      #:define-parse-method
                      #:with-foreign-object
                      #:with-foreign-objects
                      #:with-foreign-slots)
  (:import-from :closer-mop)
  (:import-from :trivial-garbage)
  (:import-from :bordeaux-threads)
  (:export #:symbol-for-gtype
           #:get-lisp-name-exception

           #:parse-g-value
           #:set-g-value

           #:create-fn-ref

           #:define-cb-methods
           #:define-g-boxed-cstruct
           #:define-g-boxed-opaque
           #:define-g-boxed-variant-cstruct
           #:define-g-enum
           #:define-g-flags
           #:define-g-interface
           #:define-g-object-class
           #:define-boxed-opaque-accessor
           #:define-vtable

           #:boxed-related-symbols
           #:with-foreign-boxed-array

           #:get-g-type-definition

           #:get-flags-items
           #:get-g-flags-definition
           #:flags-item-name
           #:flags-item-value
           #:flags-item-nick

           #:get-enum-items
           #:get-g-enum-definition
           #:enum-item-name
           #:enum-item-value
           #:enum-item-nick
    ))

;;; ----------------------------------------------------------------------------

#+liber-documentation
(setf (documentation (find-package :gobject) t)
 "GObject provides the object system used for Pango and GTK.
  This is the API documentation of a Lisp binding to GObject.
  @begin[Type Information]{section}
    The GLib Runtime type identification and management system.

    The GType API is the foundation of the GObject system. It provides the
    facilities for registering and managing all fundamental data types,
    user-defined objects and interface types.

    For type creation and registration purposes, all types fall into one of two
    categories: static or dynamic. Static types are never loaded or unloaded at
    run-time as dynamic types may be. Static types are created with the function
    @code{g_type_register_static()} that gets type specific information passed
    in via a @code{GTypeInfo} structure. Dynamic types are created with the
    function @code{g_type_register_dynamic()} which takes a @code{GTypePlugin}
    structure instead. The remaining type information (the @code{GTypeInfo}
    structure) is retrieved during runtime through the @code{GTypePlugin}
    structure and the @code{g_type_plugin_*()} API. These registration functions
    are usually called only once from a function whose only purpose is to return
    the type identifier for a specific class. Once the type (or class or
    interface) is registered, it may be instantiated, inherited, or implemented
    depending on exactly what sort of type it is. There is also a third
    registration function for registering fundamental types called
    @code{g_type_register_fundamental()} which requires both a @code{GTypeInfo}
    structure and a @code{GTypeFundamentalInfo} structure but it is seldom used
    since most fundamental types are predefined rather than user-defined.

    Type instance and class structures are limited to a total of 64 KiB,
    including all parent types. Similarly, type instances' private data (as
    created by the function @code{g_type_class_add_private()}) are limited to a
    total of 64 KiB. If a type instance needs a large static buffer, allocate it
    separately (typically by using a @code{GArray} or @code{GPtrArray}
    structure) and put a pointer to the buffer in the structure.

    A final word about type names. Such an identifier needs to be at least three
    characters long. There is no upper length limit. The first character needs
    to be a letter (a-z or A-Z) or an underscore '_'. Subsequent characters can
    be letters, numbers or any of '-_+'.
    @about-variable{+g-type-invalid+}
    @about-variable{+g-type-none+}
    @about-variable{+g-type-interface+}
    @about-variable{+g-type-char+}
    @about-variable{+g-type-uchar+}
    @about-variable{+g-type-boolean+}
    @about-variable{+g-type-int+}
    @about-variable{+g-type-uint+}
    @about-variable{+g-type-long+}
    @about-variable{+g-type-ulong+}
    @about-variable{+g-type-int64+}
    @about-variable{+g-type-uint64+}
    @about-variable{+g-type-enum+}
    @about-variable{+g-type-flags+}
    @about-variable{+g-type-float+}
    @about-variable{+g-type-double+}
    @about-variable{+g-type-string+}
    @about-variable{+g-type-pointer+}
    @about-variable{+g-type-boxed+}
    @about-variable{+g-type-param+}
    @about-variable{+g-type-object+}
    @about-variable{+g-type-gtype+}
    @about-variable{+g-type-variant+}
    @about-variable{+g-type-checksum+}
    @about-variable{+g-type-reserved-glib-first+}
    @about-variable{+g-type-reserved-glib-last+}
    @about-variable{+g-type-reserved-bse-first+}
    @about-variable{+g-type-reserved-bse-last+}
    @about-variable{+g-type-reserved-user-first+}
    @about-variable{+g-type-fundamental-max+}
    @about-class{type-t}
    @about-symbol{type-interface}
    @about-symbol{type-instance}
    @about-symbol{type-class}
    @about-symbol{type-info}
    @about-symbol{type-fundamental-info}
    @about-symbol{interface-info}
    @about-symbol{type-value-table}
    @about-symbol{type-debug-flags}
    @about-symbol{type-query}
    @about-symbol{type-flags}
    @about-symbol{type-fundamental-flags}
    @about-function{type-fundamental}
    @about-function{type-make-fundamental}
    @about-function{type-is-abstract}
    @about-function{type-is-derived}
    @about-function{type-is-fundamental}
    @about-function{type-is-value-type}
    @about-function{type-has-value-table}
    @about-function{type-is-classed}
    @about-function{type-is-instantiatable}
    @about-function{type-is-derivable}
    @about-function{type-is-deep-derivable}
    @about-function{type-is-interface}
    @about-function{type-from-instance}
    @about-function{type-from-class}
    @about-function{type-from-interface}
    @about-function{type-instance-class}
    @about-function{type-instance-interface}
    @about-function{type-instance-get-private}
    @about-function{type-class-get-private}
    @about-function{type-check-instance}
    @about-function{type-check-instance-cast}
    @about-function{type-check-instance-type}
    @about-function{type-check-instance-fundamental-type}
    @about-function{type-check-class-cast}
    @about-function{type-check-class-type}
    @about-function{type-check-value}
    @about-function{type-check-value-type}
    @about-function{type-init}
    @about-function{type-init-with-debug-flags}
    @about-function{type-name}
    @about-function{type-qname}
    @about-function{type-from-name}
    @about-function{type-parent}
    @about-function{type-depth}
    @about-function{type-next-base}
    @about-function{type-is-a}
    @about-function{type-class-ref}
    @about-function{type-class-peek}
    @about-function{type-class-peek-static}
    @about-function{type-class-unref}
    @about-function{type-class-peek-parent}
    @about-function{type-class-add-private}
    @about-function{type-add-class-private}
    @about-function{type-interface-peek}
    @about-function{type-interface-peek-parent}
    @about-function{type-default-interface-ref}
    @about-function{type-default-interface-peek}
    @about-function{type-default-interface-unref}
    @about-function{type-children}
    @about-function{type-interfaces}
    @about-function{type-interface-prerequisites}
    @about-function{type-qdata}
    @about-function{type-query}
    @about-function{type-register-static}
    @about-function{type-register-static-simple}
    @about-function{type-register-dynamic}
    @about-function{type-register-fundamental}
    @about-function{type-add-interface-static}
    @about-function{type-add-interface-dynamic}
    @about-function{type-interface-add-prerequisite}
    @about-function{type-get-plugin}
    @about-function{type-interface-get-plugin}
    @about-function{type-fundamental-next}
    @about-function{type-create-instance}
    @about-function{type-free-instance}
    @about-function{type-add-class-cache-func}
    @about-function{type-remove-class-cache-func}
    @about-function{type-class-unref-uncached}
    @about-function{type-add-interface-check}
    @about-function{type-remove-interface-check}
    @about-function{type-value-table-peek}
    @about-function{type-ensure}
    @about-function{type-get-type-registration-serial}
    @about-function{type-get-instance-count}
  @end{section}
  @begin[GObject]{section}
    The base object type.
    @about-class{object}
    @about-generic{object-has-reference}
    @about-generic{object-pointer}
    @about-generic{object-signal-handlers}
    @about-function{type-is-object}
    @about-function{is-object}
    @about-function{object-type}
    @about-function{object-type-name}
    @about-function{object-class-find-property}
    @about-function{object-class-list-properties}
    @about-function{object-interface-find-property}
    @about-function{object-interface-list-properties}
    @about-function{object-new}
    @about-function{object-notify}
    @about-function{object-freeze-notify}
    @about-function{object-thaw-notify}
    @about-function{object-data}
    @about-function{object-set-data-full}
    @about-function{object-steal-data}
    @about-function{object-property}
  @end{section}
  @begin[Enumeration and Flag Types]{section}
    The GLib type system provides fundamental types for enumeration and flags
    types. Flags types are like enumerations, but allow their values to be
    combined by bitwise OR. A registered enumeration or flags type associates a
    name and a nickname with each allowed value. When an enumeration or flags
    type is registered with the GLib type system, it can be used as value type
    for object properties, using the @fun{g:param-spec-enum} or
    @fun{g:param-spec-flags} functions.
    @about-symbol{enum-value}
    @about-symbol{enum-class}
    @about-function{type-is-enum}
    @about-symbol{flags-value}
    @about-symbol{flags-class}
    @about-function{type-is-flags}
  @end{section}
  @begin[Boxed Types]{section}
    A mechanism to wrap opaque C structures registered by the type system

    GBoxed is a generic wrapper mechanism for arbitrary C structures. The only
    thing the type system needs to know about the structures is how to copy and
    free them, beyond that they are treated as opaque chunks of memory.

    Boxed types are useful for simple value-holder structures like rectangles or
    points. They can also be used for wrapping structures defined in non-GObject
    based libraries. They allow arbitrary structures to be handled in a uniform
    way, allowing uniform copying (or referencing) and freeing
    (or unreferencing) of them, and uniform representation of the type of the
    contained structure. In turn, this allows any type which can be boxed to be
    set as the data in a GValue, which allows for polymorphic handling of a much
    wider range of data types, and hence usage of such types as GObject property
    values.

    GBoxed is designed so that reference counted types can be boxed. Use the
    type’s ‘ref’ function as the @code{GBoxedCopyFunc}, and its ‘unref’ function
    as the @code{GBoxedFreeFunc}. For example, for @code{GBytes}, the
    @code{GBoxedCopyFunc} is @code{g_bytes_ref()}, and the
    @code{GBoxedFreeFunc} is @code{g_bytes_unref()}.
    @about-function{boxed-copy}
    @about-function{boxed-free}
    @about-function{boxed-type-register-static}
    @about-function{pointer-type-register-static}
    @about-function{type-hash-table}
    @about-function{type-date}
    @about-function{type-gstring}
    @about-function{type-strv}
    @about-function{type-regex}
    @about-function{type-match-info}
    @about-function{type-array}
    @about-function{type-byte-array}
    @about-function{type-ptr-array}
    @about-function{type-bytes}
    @about-function{type-variant-type}
    @about-function{type-error}
    @about-function{type-date-time}
    @about-function{type-time-zone}
    @about-function{type-io-channel}
    @about-function{type-io-condition}
    @about-function{type-variant-builder}
    @about-function{type-key-file}
    @about-function{type-main-context}
    @about-function{type-main-loop}
    @about-function{type-markup-parse-context}
    @about-function{type-source}
    @about-function{type-polled}
    @about-function{type-thread}
  @end{section}
  @begin[Generic Values]{section}
    A polymorphic type that can hold values of any other type.
    @about-symbol{value}
    @about-function{value-holds}
    @about-function{value-type}
    @about-function{value-type-name}
    @about-function{type-is-value}
    @about-function{type-is-value-abstract}
    @about-function{is-value}
    @about-function{type-value}
    @about-function{type-value-array}
    @about-function{value-init}
    @about-function{value-copy}
    @about-function{value-reset}
    @about-function{value-unset}
    @about-function{value-set-instance}
    @about-function{value-fits-pointer}
    @about-function{value-peek-pointer}
    @about-function{value-type-compatible}
    @about-function{value-type-transformable}
    @about-function{value-transform}
    @about-function{value-register-transform-func}
    @about-function{strdup-value-contents}
  @end{section}
  @begin[Parameters and Values]{section}
    Standard Parameter and Value Types

    GValue provides an abstract container structure which can be copied,
    transformed and compared while holding a value of any (derived) type, which
    is registered as a GType with a GTypeValueTable in its GTypeInfo structure.
    Parameter specifications for most value types can be created as GParamSpec
    derived instances, to implement e.g. GObject properties which operate on
    GValue containers.

    Parameter names need to start with a letter (a-z or A-Z). Subsequent
    characters can be letters, numbers or a '-'. All other characters are
    replaced by a '-' during construction.
    @about-symbol{param-spec-boolean}
    @about-function{param-spec-boolean}
    @about-function{value-boolean}
    @about-symbol{param-spec-char}
    @about-function{param-spec-char}
    @about-function{value-char}
    @about-function{value-schar}
    @about-symbol{param-spec-uchar}
    @about-function{param-spec-uchar}
    @about-function{value-uchar}
    @about-symbol{param-spec-int}
    @about-function{param-spec-int}
    @about-function{value-int}
    @about-symbol{param-spec-uint}
    @about-function{param-spec-uint}
    @about-function{value-uint}
    @about-symbol{param-spec-long}
    @about-function{param-spec-long}
    @about-function{value-long}
    @about-symbol{param-spec-ulong}
    @about-function{param-spec-ulong}
    @about-function{value-ulong}
    @about-symbol{param-spec-int64}
    @about-function{param-spec-int64}
    @about-function{value-int64}
    @about-symbol{param-spec-uint64}
    @about-function{param-spec-uint64}
    @about-function{value-uint64}
    @about-symbol{param-spec-float}
    @about-function{param-spec-float}
    @about-function{value-float}
    @about-symbol{param-spec-double}
    @about-function{param-spec-double}
    @about-function{value-double}
    @about-symbol{param-spec-enum}
    @about-function{param-spec-enum}
    @about-function{value-enum}
    @about-symbol{param-spec-flags}
    @about-function{param-spec-flags}
    @about-function{value-flags}
    @about-symbol{param-spec-string}
    @about-function{param-spec-string}
    @about-function{value-string}
    @about-function{value-set-static-string}
    @about-function{value-take-string}
    @about-function{value-set-string-take-ownership}
    @about-function{value-dup-string}
    @about-symbol{param-spec-param}
    @about-function{param-spec-param}
    @about-function{value-param}
    @about-function{value-take-param}
    @about-function{value-set-param-take-ownership}
    @about-function{value-dup-param}
    @about-symbol{param-spec-boxed}
    @about-function{param-spec-boxed}
    @about-function{value-boxed}
    @about-function{value-set-static-boxed}
    @about-function{value-take-boxed}
    @about-function{value-set-boxed-take-ownership}
    @about-function{value-dup-boxed}
    @about-symbol{param-spec-pointer}
    @about-function{param-spec-pointer}
    @about-function{value-pointer}
    @about-symbol{param-spec-object}
    @about-function{param-spec-object}
    @about-function{value-object}
    @about-function{value-take-object}
    @about-function{value-set-object-take-ownership}
    @about-function{value-dup-object}
    @about-symbol{param-spec-unichar}
    @about-function{param-spec-unichar}
    @about-symbol{param-spec-value-array}
    @about-function{param-spec-value-array}
    @about-symbol{param-spec-override}
    @about-function{param-spec-override}
    @about-symbol{param-spec-gtype}
    @about-function{param-spec-gtype}
    @about-function{value-gtype}
    @about-symbol{param-spec-variant}
    @about-function{param-spec-variant}
    @about-function{value-variant}
    @about-function{value-dup-variant}
    @about-function{value-take-variant}
  @end{section}
  @begin[GParamSpec]{section}
    Metadata for parameter specifications.
    @about-symbol{param-flags}
    @about-symbol{param-spec}
    @about-symbol{param-spec-class}
    @about-symbol{param-spec-type-info}
    @about-symbol{param-spec-pool}
    @about-function{type-is-param}
    @about-function{param-spec}
    @about-function{is-param-spec}
    @about-function{param-spec-class}
    @about-function{is-param-spec-class}
    @about-function{param-spec-get-class}
    @about-function{param-spec-type}
    @about-function{param-spec-type-name}
    @about-function{param-spec-value-type}
    @about-function{param-readwrite}
    @about-function{param-static-strings}
    @about-function{param-mask}
    @about-function{param-user-shift}
    @about-function{param-spec-ref}
    @about-function{param-spec-unref}
    @about-function{param-spec-sink}
    @about-function{param-spec-ref-sink}
    @about-function{param-spec-default-value}
    @about-function{param-value-set-default}
    @about-function{param-value-defaults}
    @about-function{param-value-validate}
    @about-function{param-value-convert}
    @about-function{param-values-cmp}
    @about-function{param-spec-is-valid-name}
    @about-function{param-spec-name}
    @about-function{param-spec-name-quark}
    @about-function{param-spec-nick}
    @about-function{param-spec-blurb}
    @about-function{param-spec-get-qdata}
    @about-function{param-spec-set-qdata}
    @about-function{param-spec-set-qdata-full}
    @about-function{param-spec-steal-qdata}
    @about-function{param-spec-get-redirect-target}
    @about-function{param-spec-internal}
    @about-function{param-type-register-static}
    @about-function{param-spec-pool-new}
    @about-function{param-spec-pool-insert}
    @about-function{param-spec-pool-remove}
    @about-function{param-spec-pool-lookup}
    @about-function{param-spec-pool-list}
    @about-function{param-spec-pool-list-owned}
  @end{section}
  @begin[Signals]{section}
    A means for customization of object behaviour and a general purpose
    notification mechanism.

    The basic concept of the signal system is that of the emission of a signal.
    Signals are introduced per-type and are identified through strings. Signals
    introduced for a parent type are available in derived types as well, so
    basically they are a per-type facility that is inherited.

    A signal emission mainly involves invocation of a certain set of callbacks
    in precisely defined manner. There are two main categories of such
    callbacks, per-object ones and user provided ones. (Although signals can
    deal with any kind of instantiatable type, I am referring to those types as
    \"object types\" in the following, simply because that is the context most
    users will encounter signals in.) The per-object callbacks are most often
    referred to as \"object method handler\" or \"default (signal) handler\",
    while user provided callbacks are usually just called \"signal handler\".

    The object method handler is provided at signal creation time (this most
    frequently happens at the end of an object class' creation), while user
    provided handlers are frequently connected and disconnected to/from a
    certain signal on certain object instances.

    A signal emission consists of five stages, unless prematurely stopped:
    @begin{enumerate}
      @begin{item}
        Invocation of the object method handler for @code{:run-first} signals.
      @end{item}
      @begin{item}
        Invocation of normal user-provided signal handlers (where the after
        flag is not set).
      @end{item}
      @begin{item}
        Invocation of the object method handler for @code{:run-last} signals.
      @end{item}
      @begin{item}
        Invocation of user provided signal handlers (where the after flag is
        set).
      @end{item}
      @begin{item}
        Invocation of the object method handler for @code{:run-cleanup} signals.
      @end{item}
    @end{enumerate}
    The user-provided signal handlers are called in the order they were
    connected in.

    All handlers may prematurely stop a signal emission, and any number of
    handlers may be connected, disconnected, blocked or unblocked during a
    signal emission.

    There are certain criteria for skipping user handlers in stages 2 and 4 of
    a signal emission.

    First, user handlers may be blocked. Blocked handlers are omitted during
    callback invocation, to return from the blocked state, a handler has to get
    unblocked exactly the same amount of times it has been blocked before.

    Second, upon emission of a @code{:detailed} signal, an additional detail
    argument passed in to the @fun{g:signal-emit} function has to match the
    detail argument of the signal handler currently subject to invocation.
    Specification of no detail argument for signal handlers (omission of the
    detail part of the signal specification upon connection) serves as a
    wildcard and matches any detail argument passed in to emission.

    While the detail argument is typically used to pass an object property name
    (as with \"notify\"), no specific format is mandated for the detail string,
    other than that it must be non-empty.

    @subheading{Memory management of signal handlers}
    If you are connecting handlers to signals and using a @class{g:object}
    instance as your signal handler user data, you should remember to pair calls
    to the @fun{g:signal-connect} function with calls to the
    @fun{g:signal-handler-disconnect} function. While signal handlers are
    automatically disconnected when the object emitting the signal is finalised,
    they are not automatically disconnected when the signal handler user data is
    destroyed. If this user data is a @class{g:object} instance, using it from a
    signal handler after it has been finalised is an error.

    There are two strategies for managing such user data. The first is to
    disconnect the signal handler (using the @fun{g:signal-handler-disconnect}
    function) when the user data (object) is finalised; this has to be
    implemented manually. For non-threaded programs, the
    @code{g_signal_connect_object()} function can be used to implement this
    automatically. Currently, however, it is unsafe to use in threaded programs.

    The second is to hold a strong reference on the user data until after the
    signal is disconnected for other reasons. This can be implemented
    automatically using the @code{g_signal_connect_data()} function.

    The first approach is recommended, as the second approach can result in
    effective memory leaks of the user data if the signal handler is never
    disconnected for some reason.
    @about-symbol{signal-invocation-hint}
    @about-symbol{signal-cmarshaller}
    @about-symbol{signal-cvamarshaller}
    @about-symbol{signal-flags}
    @about-symbol{signal-match-type}
    @about-struct{signal-query}
    @about-function{signal-query-signal-id}
    @about-function{signal-query-signal-name}
    @about-function{signal-query-owner-type}
    @about-function{signal-query-signal-flags}
    @about-function{signal-query-return-type}
    @about-function{signal-query-param-types}
    @about-function{signal-query-signal-detail}
    @about-symbol{connect-flags}
    @about-function{signal-new}
    @about-function{signal-newv}
    @about-function{signal-new-valist}
    @about-function{signal-set-va-marshaller}
    @about-function{signal-query}
    @about-function{signal-lookup}
    @about-function{signal-name}
    @about-function{signal-list-ids}
    @about-function{signal-emit}
    @about-function{signal-emit-by-name}
    @about-function{signal-emitv}
    @about-function{signal-emit-valist}
    @about-function{signal-connect}
    @about-function{signal-connect-after}
    @about-function{signal-connect-swapped}
    @about-function{signal-connect-object}
    @about-function{signal-connect-data}
    @about-function{signal-connect-closure}
    @about-function{signal-connect-closure-by-id}
    @about-function{signal-handler-block}
    @about-function{signal-handler-unblock}
    @about-function{signal-handler-disconnect}
    @about-function{signal-handler-find}
    @about-function{signal-handlers-block-matched}
    @about-function{signal-handlers-unblock-matched}
    @about-function{signal-handlers-disconnect-matched}
    @about-function{signal-handler-is-connected}
    @about-function{signal-handlers-block-by-func}
    @about-function{signal-handlers-unblock-by-func}
    @about-function{signal-handlers-disconnect-by-func}
    @about-function{signal-handlers-disconnect-by-data}
    @about-function{signal-has-handler-pending}
    @about-function{signal-stop-emission}
    @about-function{signal-stop-emission-by-name}
    @about-function{signal-override-class-closure}
    @about-function{signal-chain-from-overridden}
    @about-function{signal-new-class-handler}
    @about-function{signal-override-class-handler}
    @about-function{signal-chain-from-overridden-handler}
    @about-function{signal-add-emission-hook}
    @about-function{signal-remove-emission-hook}
    @about-function{signal-is-valid-name}
    @about-function{signal-parse-name}
    @about-function{signal-get-invocation-hint}
    @about-function{signal-type-cclosure-new}
    @about-function{signal-accumulator-first-wins}
    @about-function{signal-accumulator-true-handled}
    @about-function{clear-signal-handler}
  @end{section}
  @begin[Closures]{section}
    Functions as first-class objects

    A GClosure represents a callback supplied by the programmer. It will
    generally comprise a function of some kind and a marshaller used to call it.
    It is the reponsibility of the marshaller to convert the arguments for the
    invocation from GValues into a suitable form, perform the callback on the
    converted arguments, and transform the return value back into a GValue.

    In the case of C programs, a closure usually just holds a pointer to a
    function and maybe a data argument, and the marshaller converts between
    GValue and native C types. The GObject library provides the GCClosure type
    for this purpose. Bindings for other languages need marshallers which
    convert between GValues and suitable representations in the runtime of the
    language in order to use functions written in that languages as callbacks.

    Within GObject, closures play an important role in the implementation of
    signals. When a signal is registered, the c_marshaller argument to
    g_signal_new() specifies the default C marshaller for any closure which is
    connected to this signal. GObject provides a number of C marshallers for
    this purpose, see the g_cclosure_marshal_*() functions. Additional C
    marshallers can be generated with the glib-genmarshal utility. Closures can
    be explicitly connected to signals with g_signal_connect_closure(), but it
    usually more convenient to let GObject create a closure automatically by
    using one of the g_signal_connect_*() functions which take a callback
    function/user data pair.

    Using closures has a number of important advantages over a simple callback
    function/data pointer combination:
    @begin{itemize}
      @begin{item}
        Closures allow the callee to get the types of the callback parameters,
        which means that language bindings don't have to write individual glue
        for each callback type.
      @end{item}
      @begin{item}
        The reference counting of GClosure makes it easy to handle reentrancy
        right; if a callback is removed while it is being invoked, the closure
        and its parameters won't be freed until the invocation finishes.
      @end{item}
      @begin{item}
        g_closure_invalidate() and invalidation notifiers allow callbacks to be
        automatically removed when the objects they point to go away.
      @end{item}
    @end{itemize}
    @about-symbol{G_CLOSURE_NEEDS_MARSHAL}
    @about-symbol{G_CLOSURE_N_NOTIFIERS}
    @about-symbol{G_CCLOSURE_SWAP_DATA}
    @about-symbol{G_CALLBACK}
    @about-symbol{closure}
    @about-function{type-closure}
    @about-symbol{cclosure}
    @about-function{cclosure-new}
    @about-function{cclosure-new-swap}
    @about-function{cclosure-new-object}
    @about-function{cclosure-new-object-swap}
    @about-function{cclosure-marshal-generic}
    @about-function{closure-new-object}
    @about-function{closure-ref}
    @about-function{closure-sink}
    @about-function{closure-unref}
    @about-function{closure-invoke}
    @about-function{closure-invalidate}
    @about-function{closure-add-finalize-notifier}
    @about-function{closure-add-invalidate-notifier}
    @about-function{closure-remove-finalize-notifier}
    @about-function{closure-remove-invalidate-notifier}
    @about-function{closure-new-simple}
    @about-function{closure-set-marshal}
    @about-function{closure-add-marshal-guards}
    @about-function{closure-set-meta-marshal}
    @about-function{closure-set-closure}
    @about-function{closure-set-dummy-callback}
  @end{section}
  @begin[GBinding]{section}
    Bind two object properties.
    @about-symbol{binding-flags}
    @about-class{binding}
    @about-generic{binding-flags}
    @about-generic{binding-source}
    @about-generic{binding-source-property}
    @about-generic{binding-target}
    @about-generic{binding-target-property}
    @about-function{binding-unbind}
    @about-function{object-bind-property}
    @about-function{object-bind-property-full}
    @about-function{object-bind-property-with-closures}
  @end{section} ")

;;; --- End of file gobject.package.lisp ---------------------------------------
