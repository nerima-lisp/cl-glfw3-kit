(in-package #:cl-glfw3-kit)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (unless (member :sbcl *features*)
    (error "cl-glfw3-kit requires SBCL: its FFI layer is SB-ALIEN, not cffi.")))

(sb-alien:load-shared-object
 (or (uiop:getenv "CL_GLFW3_KIT_LIBRARY")
     (error "Set CL_GLFW3_KIT_LIBRARY to the GLFW shared library path (flake.nix ~
             wires this to nixpkgs' pkgs.glfw automatically)."))
 :dont-save t)

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
  "Signal the condition mapped to CODE, or GLFW-UNKNOWN-ERROR."
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
  "Bind C-NAME as a checked SB-ALIEN routine named LISP-NAME."
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
