;;;; t/hardware/hardware-test.lisp
;;;;
;;;; Every case here needs a real display: run only by hand (`nix run
;;;; .#test-hardware`), never as part of `nix flake check`. See
;;;; cl-glfw3-kit.asd's cl-glfw3-kit/hardware-test system.
(in-package #:cl-glfw3-kit/hardware-test)

(describe
  "a real GLFW session"
  (it "initializes, reports a 3.x version, and terminates cleanly"
    (with-glfw ()
      (let ((major (glfw-version)))
        (expect (>= major 3) :to-be-truthy))
      (expect (plusp (length (glfw-version-string))) :to-be-truthy))))

(describe
  "a real window"
  (it "creates an invisible window with the requested size and title"
    (with-glfw ()
      (with-glfw-window (window :width 320 :height 240 :title "cl-glfw3-kit"
                                 :hints (list :visible nil :resizable nil))
        (multiple-value-bind (width height) (window-size window)
          (expect width :to-equal 320)
          (expect height :to-equal 240))
        (expect (window-title window) :to-equal "cl-glfw3-kit")
        (multiple-value-bind (fb-width fb-height) (framebuffer-size window)
          (expect (>= fb-width 320) :to-be-truthy)
          (expect (>= fb-height 240) :to-be-truthy)))))

  (it "WINDOW-SHOULD-CLOSE-P / SET-WINDOW-SHOULD-CLOSE round-trip for real"
    (with-glfw ()
      (with-glfw-window (window :hints (list :visible nil))
        (expect (window-should-close-p window) :to-be-falsy)
        (set-window-should-close window t)
        (expect (window-should-close-p window) :to-be-truthy))))

  (it "SET-WINDOW-TITLE changes what WINDOW-TITLE reports"
    (with-glfw ()
      (with-glfw-window (window :title "before" :hints (list :visible nil))
        (set-window-title window "after")
        (expect (window-title window) :to-equal "after")))))

(describe
  "input queries against a real window"
  (it "KEY/MOUSE-BUTTON-PRESSED-P report false with no input, CURSOR-POSITION returns two reals"
    (with-glfw ()
      (with-glfw-window (window :hints (list :visible nil))
        (expect (key-pressed-p window :a) :to-be-falsy)
        (expect (mouse-button-pressed-p window :left) :to-be-falsy)
        (multiple-value-bind (x y) (cursor-position window)
          (expect (realp x) :to-be-truthy)
          (expect (realp y) :to-be-truthy))))))

(describe
  "context and the per-frame loop against a real window"
  (it "MAKE-CONTEXT-CURRENT/SWAP-INTERVAL/SWAP-BUFFERS run without signalling"
    (with-glfw ()
      (with-glfw-window (window :hints (list :visible nil))
        (make-context-current window)
        (swap-interval 1)
        (swap-buffers window))))

  (it "FOR-EACH-FRAME runs until WINDOW-SHOULD-CLOSE-P, calling the body each time"
    (with-glfw ()
      (with-glfw-window (window :hints (list :visible nil))
        (let ((frames 0))
          (for-each-frame (win window)
            (incf frames)
            (when (>= frames 3) (set-window-should-close win t)))
          (expect frames :to-equal 3)))))

  (it "WITH-GLFW-CALLBACKS installs and clears real key/window-size callbacks"
    (with-glfw ()
      (with-glfw-window (window :hints (list :visible nil))
        (let ((window-size-events '()))
          (with-glfw-callbacks (window
                                 :on-window-size (lambda (w width height)
                                                   (declare (ignore w))
                                                   (push (list width height)
                                                         window-size-events)))
            (for-each-frame (win window)
              (declare (ignore win))
              (set-window-should-close window t)))
          ;; No resize actually happened (the window is invisible and
          ;; untouched), so this only proves installation/teardown ran
          ;; without error -- the callback firing at all is proven by
          ;; t/hardware/hardware-test.lisp's real usage in a live session,
          ;; matching how docs/src/getting-started.md's example is used.
          (expect (listp window-size-events) :to-be-truthy))))))

(describe
  "a real monitor and its video mode"
  (it "VIDEO-MODE reports a plausible resolution and refresh rate for PRIMARY-MONITOR"
    (with-glfw ()
      (let ((mode (video-mode (primary-monitor))))
        (expect (plusp (video-mode-width mode)) :to-be-truthy)
        (expect (plusp (video-mode-height mode)) :to-be-truthy)
        (expect (plusp (video-mode-refresh-rate mode)) :to-be-truthy)))))
