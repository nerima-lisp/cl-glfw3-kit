# Getting started

## Install

Via a sibling checkout on `CL_SOURCE_REGISTRY` or ASDF's `*central-registry*`:

```lisp
(asdf:load-system "cl-glfw3-kit")
```

`cl-glfw3-kit` itself has no Lisp dependencies -- its FFI layer is SBCL's
own `sb-alien`, not cffi. It does need the real GLFW shared library at load
time, pointed to by an environment variable:

```sh
export CL_GLFW3_KIT_LIBRARY=/path/to/libglfw.so   # or libglfw.dylib on macOS
```

`nix develop`/`nix build`/`nix flake check` set this automatically, wired
to nixpkgs' `pkgs.glfw` in `flake.nix`.

## A window and an event loop

```lisp
(cl-glfw3-kit:with-glfw ()
  (cl-glfw3-kit:with-glfw-window (window :width 800 :height 600 :title "hello")
    (cl-glfw3-kit:make-context-current window)
    (cl-glfw3-kit:with-glfw-callbacks
        (window :on-key (lambda (window key scancode action mods)
                          (declare (ignore scancode mods))
                          (when (and (eq key :escape) (eq action :press))
                            (cl-glfw3-kit:set-window-should-close window t))))
      (cl-glfw3-kit:for-each-frame (frame window)
        ;; render into FRAME here -- FOR-EACH-FRAME already polled events
        ;; and will swap buffers after this body returns
        ))))
```

`with-glfw`, `with-glfw-window`, `with-glfw-callbacks`, and `for-each-frame`
are all continuation-passing: each guarantees its own teardown (GLFW
termination, window destruction, callback removal) once its body returns
or signals, so nothing needs an explicit `unwind-protect` at the call site.

## Running the tests

```sh
sbcl --script run-tests.lisp
```

expects sibling `../cl-weave/`, `../cl-boundary-kit/`, and `../cl-host-kit/`
checkouts (the test system's dependencies; see `cl-glfw3-kit.asd`) and
`CL_GLFW3_KIT_LIBRARY` set, as above.

The default suite never touches a real GLFW window: `nix flake check`'s
sandbox has no display server, so `glfwInit()` cannot succeed there. To
exercise the real, end-to-end path against an actual window on a machine with
a display, run the separate hardware suite instead:

```sh
sbcl --script run-hardware-tests.lisp   # or: nix run .#test-hardware
```

See the [roadmap](project/roadmap.md) for what each suite covers and why
the split exists, and the [API reference](reference/api.md) for the full
bound surface.
