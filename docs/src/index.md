# cl-glfw3-kit

Common Lisp bindings for [GLFW3](https://www.glfw.org/), the
cross-platform C library for creating windows and OpenGL/OpenGL-ES
contexts and handling keyboard, mouse, and monitor input.

The current implementation targets SBCL and uses its built-in `sb-alien`
FFI; it does not depend on CFFI.

## Status

Window lifecycle, hints, the event loop, context management, input
queries, the seven core window callbacks, and monitor/video-mode
enumeration are bound, via SBCL's own `sb-alien` (not cffi). See
[Getting started](getting-started.md) for a worked example, the
[API reference](reference/api.md) for the full surface, and the
[roadmap](project/roadmap.md) for what is deliberately not bound yet.
