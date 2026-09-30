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
- Gamepad presence, mapping detection, state, and mapping updates for integer
  joystick slots
- GLFW time and procedure lookup (`glfw-time`, `glfw-proc-address`)
- The exported function forms behind the convenience macros (`call-with-glfw`,
  `call-with-glfw-window`, `call-with-glfw-callbacks`, and
  `call-with-each-frame`)

## What is not bound

The following features are outside the current API surface:

- Clipboard access
- Custom cursor images
- Native/platform-specific window handles (`glfwGetX11Window` and similar)
- Vulkan surface creation (`glfwCreateWindowSurface`)
- Monitor gamma ramps
- Window icons
- Application-specific input normalization and controller policy beyond the
  standard GLFW key table

The gamepad API uses integer joystick slots and does not impose a two-device
limit, so two or more connected devices can be queried independently.

These can be added without changing the `sb-alien`/`define-glfw-function`
foundation.

## Why sb-alien, not cffi

`sb-alien` is bundled with SBCL, so it avoids adding a separate FFI
dependency. The package uses `define-glfw-function` to keep the bindings in
one place.

## Testing against a real display

The default checks do not require a display server. Functions that need a
real GLFW window or context are covered by the `cl-glfw3-kit/hardware-test`
system in `t/hardware/`:

```sh
nix run .#test-hardware
```

The default `cl-glfw3-kit/test` system covers constant tables, generated
wrappers, and window/init lifecycle logic with recording-boundary test
doubles.
