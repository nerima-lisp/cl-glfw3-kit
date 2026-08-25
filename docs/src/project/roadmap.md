# Roadmap

GLFW3 window, input, and context management is bound today via SBCL's
`sb-alien`, not cffi -- see [Getting started](../getting-started.md) and
the [API reference](../reference/api.md) for how to use it.

## What is bound

- Init/terminate/error/version (`with-glfw`, `glfw-version`,
  `glfw-version-string`)
- Window lifecycle and hints (`with-glfw-window`, `window-size`,
  `framebuffer-size`, `window-title`)
- The event loop (`poll-events`, `wait-events`, `wait-events-timeout`,
  `for-each-frame`)
- Context management (`make-context-current`, `swap-interval`,
  `swap-buffers`)
- Input queries (`key-pressed-p`, `mouse-button-pressed-p`,
  `cursor-position`)
- The seven core window callbacks -- key, mouse button, cursor position,
  scroll, window size, framebuffer size, window close -- via
  `with-glfw-callbacks`
- Monitor enumeration and video modes (`primary-monitor`, `list-monitors`,
  `video-mode`)

## What is not bound

Deliberately out of scope for the current API surface, not forgotten:

- Joystick and gamepad input
- Clipboard access
- Custom cursor images
- Native/platform-specific window handles (`glfwGetX11Window` and similar)
- Vulkan surface creation (`glfwCreateWindowSurface`)
- Monitor gamma ramps
- Window icons

Each is a reasonably self-contained addition once needed; none changes the
`sb-alien`/`define-glfw-function` foundation the current surface is built
on.

## Why sb-alien, not cffi

`cffi` would have been an external (non-org) dependency, subject to
`DEPENDENCY_POLICY.md`'s four-condition procedure. `sb-alien` is bundled
with SBCL itself, so it counts as an implementation dependency rather than
an external one -- the same distinction `nerimux`'s own 2026-08-01/02
dependency sweep relies on for its own native calls. See
`cl-glfw3-kit.asd`'s `:depends-on` comment.

## Testing against a real display

`nix flake check`'s sandbox has no display server, so `glfwInit()` itself
cannot succeed there on Linux (it needs a `DISPLAY`/X11 connection to pick
a platform backend). Every function that needs a real, already-initialized
GLFW window or context lives in the `cl-glfw3-kit/hardware-test` system
(`t/hardware/`) instead, run only by hand:

```sh
nix run .#test-hardware
```

The default `cl-glfw3-kit/test` system covers everything below the FFI
boundary that does not need a real display -- constant-table round-trips,
the `define-glfw-function`-generated wrapper shape, window/init CPS
lifecycle logic against a `cl-boundary-kit` recording-boundary test double
-- and stops there on purpose. See `run-coverage.lisp` for the measured
split between what each suite covers.
