# cl-glfw3-kit

Common Lisp bindings for [GLFW3](https://www.glfw.org/), the
cross-platform C library for creating windows and OpenGL/OpenGL-ES
contexts and handling keyboard, mouse, and monitor input.

The current implementation targets SBCL and uses its built-in `sb-alien`
FFI; it does not depend on CFFI.

The implemented `0.2.0` surface covers window and framebuffer lifecycle,
keyboard and mouse queries, scoped callbacks, event polling, context
management, monitor/video-mode queries, gamepad state and mapping updates,
and GLFW time/procedure lookup. The exported `*glfw-keys*` table and
`key-code` support NES keyboard bindings; controller policy remains in the
frontend.

## Status

Window lifecycle, hints, the event loop, context management, input
queries, the seven core window callbacks, and monitor/video-mode
enumeration are bound, via SBCL's own `sb-alien` (not cffi). See
[Getting started](getting-started.md) for a worked example, the
[API reference](reference/api.md) for the full surface, and the
[roadmap](project/roadmap.md) for what is not bound yet.
