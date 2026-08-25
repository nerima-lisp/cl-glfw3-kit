;;;; src/callbacks.lisp
(in-package #:cl-glfw3-kit)

(define-glfw-function %glfw-set-key-callback "glfwSetKeyCallback" (* t)
  (window glfw-window-alien) (callback (* t)))
(define-glfw-function %glfw-set-mouse-button-callback "glfwSetMouseButtonCallback" (* t)
  (window glfw-window-alien) (callback (* t)))
(define-glfw-function %glfw-set-cursor-pos-callback "glfwSetCursorPosCallback" (* t)
  (window glfw-window-alien) (callback (* t)))
(define-glfw-function %glfw-set-scroll-callback "glfwSetScrollCallback" (* t)
  (window glfw-window-alien) (callback (* t)))
(define-glfw-function %glfw-set-window-size-callback "glfwSetWindowSizeCallback" (* t)
  (window glfw-window-alien) (callback (* t)))
(define-glfw-function %glfw-set-framebuffer-size-callback "glfwSetFramebufferSizeCallback" (* t)
  (window glfw-window-alien) (callback (* t)))
(define-glfw-function %glfw-set-window-close-callback "glfwSetWindowCloseCallback" (* t)
  (window glfw-window-alien) (callback (* t)))

(defun %decode-mods (mods)
  "Decode a GLFW callback's MODS bitmask into the list of *GLFW-MOD-KEYS*
keywords currently held."
  (loop for (keyword . bit) in *glfw-mod-keys*
        when (plusp (logand mods bit))
          collect keyword))

(defun %key-keyword (key)
  (or (car (rassoc key *glfw-keys*)) key))

(defun %mouse-button-keyword (button)
  (or (car (rassoc button *glfw-mouse-buttons*)) button))

(defun %action-keyword (action)
  (or (car (rassoc action *glfw-actions*)) action))

(defun call-with-glfw-callbacks (window continuation &key on-key on-mouse-button
                                                            on-cursor-pos on-scroll
                                                            on-window-size
                                                            on-framebuffer-size on-close)
  "Install whichever of ON-KEY/ON-MOUSE-BUTTON/ON-CURSOR-POS/ON-SCROLL/
ON-WINDOW-SIZE/ON-FRAMEBUFFER-SIZE/ON-CLOSE continuations were supplied on
WINDOW, call CONTINUATION with no arguments, then clear them on the way out
-- success or error. Each installed continuation is called with WINDOW
first, then the event's own arguments, translated from GLFW's raw ints via
%KEY-KEYWORD/%MOUSE-BUTTON-KEYWORD/%ACTION-KEYWORD/%DECODE-MODS. The
continuation-passing core of WITH-GLFW-CALLBACKS: every callback is a
dynamic-extent closure via WITH-ALIEN-CALLABLE, valid only while
CONTINUATION runs, torn down automatically when this function returns."
  (let ((pointer (glfw-window-pointer window)))
    (sb-alien:with-alien-callable
        ((key-callback sb-alien:void
                        ((raw-window (* t)) (key sb-alien:int) (scancode sb-alien:int)
                         (action sb-alien:int) (mods sb-alien:int))
           (declare (ignore raw-window))
           (when on-key
             (funcall on-key window (%key-keyword key) scancode
                      (%action-keyword action) (%decode-mods mods))))
         (mouse-button-callback sb-alien:void
                                 ((raw-window (* t)) (button sb-alien:int)
                                  (action sb-alien:int) (mods sb-alien:int))
           (declare (ignore raw-window))
           (when on-mouse-button
             (funcall on-mouse-button window (%mouse-button-keyword button)
                      (%action-keyword action) (%decode-mods mods))))
         (cursor-pos-callback sb-alien:void
                               ((raw-window (* t)) (x sb-alien:double) (y sb-alien:double))
           (declare (ignore raw-window))
           (when on-cursor-pos (funcall on-cursor-pos window x y)))
         (scroll-callback sb-alien:void
                           ((raw-window (* t)) (x-offset sb-alien:double)
                            (y-offset sb-alien:double))
           (declare (ignore raw-window))
           (when on-scroll (funcall on-scroll window x-offset y-offset)))
         (window-size-callback sb-alien:void
                                ((raw-window (* t)) (width sb-alien:int) (height sb-alien:int))
           (declare (ignore raw-window))
           (when on-window-size (funcall on-window-size window width height)))
         (framebuffer-size-callback sb-alien:void
                                     ((raw-window (* t)) (width sb-alien:int)
                                      (height sb-alien:int))
           (declare (ignore raw-window))
           (when on-framebuffer-size (funcall on-framebuffer-size window width height)))
         (close-callback sb-alien:void ((raw-window (* t)))
           (declare (ignore raw-window))
           (when on-close (funcall on-close window))))
      ;; One (supplied? setter callback) row per GLFW event, so installing
      ;; and tearing down all seven is a loop over data rather than the same
      ;; seven-line WHEN clause written out twice.
      (let ((rows (list (list on-key #'%glfw-set-key-callback key-callback)
                         (list on-mouse-button #'%glfw-set-mouse-button-callback
                               mouse-button-callback)
                         (list on-cursor-pos #'%glfw-set-cursor-pos-callback
                               cursor-pos-callback)
                         (list on-scroll #'%glfw-set-scroll-callback scroll-callback)
                         (list on-window-size #'%glfw-set-window-size-callback
                               window-size-callback)
                         (list on-framebuffer-size #'%glfw-set-framebuffer-size-callback
                               framebuffer-size-callback)
                         (list on-close #'%glfw-set-window-close-callback close-callback))))
        (dolist (row rows)
          (destructuring-bind (supplied-p setter callback) row
            (when supplied-p (funcall setter pointer (sb-alien:cast callback (* t))))))
        (unwind-protect (funcall continuation)
          (dolist (row rows)
            (destructuring-bind (supplied-p setter callback) row
              (declare (ignore callback))
              (when supplied-p (funcall setter pointer (%null-pointer))))))))))

(defmacro with-glfw-callbacks ((window &rest options) &body body)
  "Install whichever callback continuations OPTIONS supplies on WINDOW for
BODY, clearing them on the way out -- success or error. OPTIONS are
CALL-WITH-GLFW-CALLBACKS's keyword arguments (:ON-KEY, :ON-MOUSE-BUTTON,
:ON-CURSOR-POS, :ON-SCROLL, :ON-WINDOW-SIZE, :ON-FRAMEBUFFER-SIZE,
:ON-CLOSE). Thin syntax over CALL-WITH-GLFW-CALLBACKS."
  `(call-with-glfw-callbacks ,window (lambda () ,@body) ,@options))
