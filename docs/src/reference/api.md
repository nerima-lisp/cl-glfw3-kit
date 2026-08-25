# API reference

All symbols below are in the `CL-GLFW3-KIT` package. See
[Getting started](../getting-started.md) for a full worked example and
[the roadmap](../project/roadmap.md) for what is and is not bound.

## Library version

### `library-version`

```lisp
(library-version)
```

Return this Lisp package's own version string, kept in sync with
`cl-glfw3-kit.asd`'s `:version`. Distinct from `glfw-version`/
`glfw-version-string`, which report the underlying GLFW C library's own
version.

## Conditions

`cl-glfw3-kit-error` is the base condition every error this library signals
derives from; catch it to handle any GLFW failure in one clause. Each
situational subtype below carries a `<name>-description` reader with the
description GLFW itself reported:

`glfw-not-initialized`, `glfw-no-current-context`, `glfw-invalid-enum`,
`glfw-invalid-value`, `glfw-out-of-memory`, `glfw-api-unavailable`,
`glfw-version-unavailable`, `glfw-platform-error`, `glfw-format-unavailable`,
`glfw-no-window-context`, `glfw-cursor-unavailable`,
`glfw-feature-unavailable`, `glfw-feature-unimplemented`,
`glfw-platform-unavailable`.

`glfw-unknown-error` (with `glfw-unknown-error-code` and
`glfw-unknown-error-description`) is signalled instead if a future GLFW
release reports an error code outside the fourteen above.

## Init/terminate

### `with-glfw`

```lisp
(with-glfw () body...)
```

Run `body` with GLFW initialized, terminating it on the way out --
success or error. Thin syntax over `call-with-glfw`, the continuation-
passing function underneath it.

### `glfw-version`, `glfw-version-string`

```lisp
(glfw-version)         ; => (values major minor revision)
(glfw-version-string)  ; => "3.4.0 Cocoa NSGL Null EGL OSMesa monotonic dynamic"
```

Report the underlying GLFW C library's own version. Safe to call before
`with-glfw` -- unlike every other function below, neither touches
platform-backend state.

### `*init-function*`, `*terminate-function*`

The functions `call-with-glfw` calls to initialize/shut down GLFW.
Rebindable as a pair for tests; production code should not need to touch
these.

## Windows

### `glfw-window`, `glfw-window-p`

The opaque handle type every window function below takes or returns.

### `with-glfw-window`

```lisp
(with-glfw-window (window &key width height title hints) body...)
```

Create a `width` (default 640) by `height` (default 480) window titled
`title`, bind it to `window` for `body`, and destroy it on the way out --
success or error. `hints` is a plist; see [Window hints](#window-hints)
below for the accepted keys. Thin syntax over `call-with-glfw-window`.

### `default-window-hints`

```lisp
(default-window-hints)
```

Reset all window hints to their GLFW defaults.

### `window-should-close-p`, `set-window-should-close`

```lisp
(window-should-close-p window)          ; => generalized boolean
(set-window-should-close window t)
```

Read or set `window`'s close flag -- the condition `for-each-frame`'s loop
checks.

### `window-size`, `framebuffer-size`

```lisp
(window-size window)        ; => (values width height), screen coordinates
(framebuffer-size window)   ; => (values width height), pixels
```

Distinct on any HiDPI display: `framebuffer-size` reports the actual pixel
dimensions, which can exceed `window-size`'s screen-coordinate figure.

### `window-title`, `set-window-title`

```lisp
(window-title window)              ; => string
(set-window-title window "title")
```

### Window hints

`with-glfw-window`'s `:hints` plist accepts:

- **Boolean** (value is any Lisp generalized boolean): `:resizable`,
  `:visible`, `:decorated`, `:auto-iconify`, `:floating`, `:maximized`,
  `:center-cursor`, `:transparent-framebuffer`, `:focus-on-show`,
  `:scale-to-monitor`, `:scale-framebuffer`, `:stereo`, `:srgb-capable`,
  `:doublebuffer`, `:opengl-forward-compat`
- **Integer**: `:context-version-major`, `:context-version-minor`,
  `:samples`, `:refresh-rate`
- **Enum**: `:client-api` (`:opengl`, `:opengl-es`, or `:no-api`),
  `:opengl-profile` (`:any`, `:core`, or `:compat`)

### `*create-window-function*`, `*destroy-window-function*`

The functions `call-with-glfw-window` calls to create/destroy the
underlying `GLFWwindow*`. Rebindable as a pair for tests; production code
should not need to touch these.

## Event callbacks

### `with-glfw-callbacks`

```lisp
(with-glfw-callbacks (window &key on-key on-mouse-button on-cursor-pos
                                   on-scroll on-window-size
                                   on-framebuffer-size on-close)
  body...)
```

Install whichever continuations are supplied as GLFW callbacks on `window`
for the extent of `body`, clearing them on the way out -- success or
error. Each installed continuation is called with `window` first, then the
event's own arguments:

| Keyword | Continuation arguments |
|---|---|
| `:on-key` | `window key scancode action mods` |
| `:on-mouse-button` | `window button action mods` |
| `:on-cursor-pos` | `window x y` |
| `:on-scroll` | `window x-offset y-offset` |
| `:on-window-size` | `window width height` |
| `:on-framebuffer-size` | `window width height` |
| `:on-close` | `window` |

`key`/`button` are keywords from the same tables `key-pressed-p`/
`mouse-button-pressed-p` accept below; `action` is `:press`, `:release`,
or `:repeat`; `mods` is a list of held modifier keywords among `:shift`,
`:control`, `:alt`, `:super`, `:caps-lock`, `:num-lock`.

## Context and the event loop

### `make-context-current`, `swap-interval`, `swap-buffers`

```lisp
(make-context-current window)
(swap-interval 1)      ; enable vsync
(swap-buffers window)
```

### `poll-events`, `wait-events`, `wait-events-timeout`

```lisp
(poll-events)
(wait-events)
(wait-events-timeout 0.5d0)
```

### `for-each-frame`

```lisp
(for-each-frame (frame window &key (swap-buffers-p t)) body...)
```

Run `body` once per frame, `frame` bound to `window` -- `poll-events`,
then `body`, then (unless `swap-buffers-p` is false) `swap-buffers` --
until `window`'s close flag is set. Thin syntax over
`call-with-each-frame`.

## Input queries

### `key-pressed-p`, `mouse-button-pressed-p`

```lisp
(key-pressed-p window :space)
(mouse-button-pressed-p window :left)
```

Key keywords follow GLFW's own `GLFW_KEY_*` names lowercased (`:a`
through `:z`, `:0` through `:9`, `:space`, `:escape`, `:left`, `:kp-0`,
`:left-shift`, and so on). Mouse-button keywords are `:button-1` through
`:button-8`, plus the aliases `:left`/`:right`/`:middle` for
`:button-1`/`:button-2`/`:button-3`.

### `cursor-position`

```lisp
(cursor-position window)   ; => (values x y), relative to window's content area
```

## Monitors

### `primary-monitor`, `list-monitors`

```lisp
(primary-monitor)    ; => a GLFW-MONITOR
(list-monitors)      ; => a list of GLFW-MONITOR
```

### `video-mode`

```lisp
(video-mode (primary-monitor))
;; => #S(VIDEO-MODE :WIDTH 1512 :HEIGHT 982 :RED-BITS 8 :GREEN-BITS 8
;;                   :BLUE-BITS 8 :REFRESH-RATE 120)
```

Accessors: `video-mode-width`, `video-mode-height`, `video-mode-red-bits`,
`video-mode-green-bits`, `video-mode-blue-bits`, `video-mode-refresh-rate`.
