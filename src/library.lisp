;;;; src/library.lisp
;;;;
;;;; Loads the GLFW shared library via SB-ALIEN and defines
;;;; DEFINE-GLFW-FUNCTION, the one macro every other src/ file uses to bind
;;;; a GLFW C function. No cffi: SBCL's own sb-alien is bundled with the
;;;; implementation, so DEPENDENCY_POLICY.md's external-dependency
;;;; procedure never applies (see cl-glfw3-kit.asd's :depends-on comment).
(in-package #:cl-glfw3-kit)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (unless (member :sbcl *features*)
    (error "cl-glfw3-kit requires SBCL: its FFI layer is SB-ALIEN, not cffi.")))

(sb-alien:load-shared-object
 (or (uiop:getenv "CL_GLFW3_KIT_LIBRARY")
     (error "Set CL_GLFW3_KIT_LIBRARY to the GLFW shared library path (flake.nix ~
             wires this to nixpkgs' pkgs.glfw automatically)."))
 :dont-save t)

;; GLFWwindow* and GLFWmonitor* are opaque handles in the GLFW C API -- never
;; dereferenced, only passed back to GLFW. (* T) is SB-ALIEN's spelling for
;; "pointer to an unspecified alien type."
(sb-alien:define-alien-type glfw-window-alien (* t))
(sb-alien:define-alien-type glfw-monitor-alien (* t))

(defun %null-pointer ()
  "A NULL (* T) alien value -- GLFW's spelling of \"no monitor\"/\"no shared
context\"/\"no callback\" wherever a function takes an optional pointer
argument."
  (sb-alien:sap-alien (sb-sys:int-sap 0) (* t)))

(defvar *last-glfw-error* nil
  "(CODE . DESCRIPTION) recorded by the error callback WITH-GLFW installs for
its dynamic extent, or NIL between errors. %CHECK-GLFW-ERROR reads and
clears this immediately after every DEFINE-GLFW-FUNCTION call returns --
GLFW invokes the error callback synchronously, on the same thread, during
the call that failed, so by the time control returns to Lisp the error (if
any) has already been recorded.")

(defun %signal-glfw-error (code description)
  "Signal the condition *GLFW-ERROR-CONDITIONS* maps CODE to, or
GLFW-UNKNOWN-ERROR if CODE is absent from that table -- unreachable against
the GLFW 3.4 error codes this library targets, all fourteen of which are in
the table; kept as a forward-compatible default rather than an ecase."
  (let ((condition-type (cdr (assoc code *glfw-error-conditions*))))
    (if condition-type
        (error condition-type :description description)
        (error 'glfw-unknown-error :code code :description description))))

(defun %check-glfw-error ()
  "Signal and clear *LAST-GLFW-ERROR* if the error callback recorded one
since the last check. Called after every DEFINE-GLFW-FUNCTION-generated
call returns, so no call site needs to check for itself."
  (let ((error-cell *last-glfw-error*))
    (when error-cell
      (setf *last-glfw-error* nil)
      (%signal-glfw-error (car error-cell) (cdr error-cell)))))

(defmacro define-glfw-function (lisp-name c-name return-type &rest arguments)
  "Bind the GLFW C function C-NAME as the alien routine %RAW-<LISP-NAME>,
then define the public LISP-NAME as a function that calls it wrapped in
WITH-FLOAT-TRAPS-MASKED -- GLFW's Cocoa backend performs IEEE754-harmless
floating point operations during window creation that trip SBCL's default
FPU exception traps otherwise -- followed by %CHECK-GLFW-ERROR. Every GLFW
binding in this library goes through this one macro, so this float-trap
mask and error check are written exactly once rather than at each of the
~30 call sites that would otherwise need to remember both. ARGUMENTS are
(NAME TYPE) pairs, the same shape SB-ALIEN:DEFINE-ALIEN-ROUTINE itself
takes."
  (let ((raw-name (intern (format nil "%RAW-~A" lisp-name)))
        (argument-names (mapcar #'first arguments)))
    `(progn
       (sb-alien:define-alien-routine (,c-name ,raw-name) ,return-type ,@arguments)
       (defun ,lisp-name (,@argument-names)
         (multiple-value-prog1
             (sb-int:with-float-traps-masked
                 (:invalid :inexact :overflow :divide-by-zero :underflow)
               (,raw-name ,@argument-names))
           (%check-glfw-error))))))
