# cl-glfw3-kit

[![CI](https://github.com/nerima-lisp/cl-glfw3-kit/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/nerima-lisp/cl-glfw3-kit/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Documentation](https://img.shields.io/badge/docs-MkDocs%20Material-0a7a5a)](https://nerima-lisp.github.io/cl-glfw3-kit/)

Common Lisp bindings for [GLFW3](https://www.glfw.org/), targeting SBCL —
window, input, and OpenGL/OpenGL-ES context management, via SBCL's own
`sb-alien` FFI rather than cffi. See
[docs/src/project/roadmap.md](docs/src/project/roadmap.md) for the bound
surface and what is deliberately out of scope.

Full documentation is published at <https://nerima-lisp.github.io/cl-glfw3-kit/>.
The source for that site lives in [docs/src/](docs/src/).

## Quick Start

```lisp
(asdf:load-system "cl-glfw3-kit")

(cl-glfw3-kit:with-glfw ()
  (cl-glfw3-kit:with-glfw-window (window :width 800 :height 600 :title "hello")
    (cl-glfw3-kit:make-context-current window)
    (cl-glfw3-kit:for-each-frame (frame window)
      ;; render into FRAME here
      )))
```

Needs the real GLFW shared library at load time:
`export CL_GLFW3_KIT_LIBRARY=/path/to/libglfw.so` (`nix develop`/`nix
build` set this automatically). See
[Getting started](https://nerima-lisp.github.io/cl-glfw3-kit/getting-started/)
for the full walkthrough.

## Install

```nix
# flake.nix
inputs.cl-glfw3-kit = {
  url = "github:nerima-lisp/cl-glfw3-kit/v0.1.0";
  inputs.nixpkgs.follows = "nixpkgs";
};
```

Note the pinned tag. Consumers inside this org must pin a release tag rather
than follow the default branch.

## Documentation

- [Getting started](https://nerima-lisp.github.io/cl-glfw3-kit/getting-started/)
- [API reference](https://nerima-lisp.github.io/cl-glfw3-kit/reference/api/)
- [Roadmap](https://nerima-lisp.github.io/cl-glfw3-kit/project/roadmap/)

## Development

```sh
nix develop           # SBCL with CL_SOURCE_REGISTRY and CL_GLFW3_KIT_LIBRARY set
nix run .#test        # run the default test suite (no real display needed)
nix run .#test-hardware  # run the real-GLFWwindow suite (needs a real display)
nix flake check       # tests + formatting + docs, the same gate CI uses
nix fmt               # format Nix sources (treefmt)
```

Tests live in `t/` and run under [cl-weave](https://github.com/nerima-lisp/cl-weave),
the org's test framework, with [cl-boundary-kit](https://github.com/nerima-lisp/cl-boundary-kit)
providing the recording-boundary test doubles the default suite uses in
place of a real display. See
[the roadmap](https://nerima-lisp.github.io/cl-glfw3-kit/project/roadmap/)
for why the two test systems are split.

## Contributing

See the org-wide [CONTRIBUTING](https://github.com/nerima-lisp/.github/blob/main/CONTRIBUTING.md)
guide and the [package standard](https://github.com/nerima-lisp/.github/blob/main/PACKAGE_STANDARD.md).

## Support

See [SUPPORT](https://github.com/nerima-lisp/.github/blob/main/SUPPORT.md).

## License

MIT. See [LICENSE](LICENSE).
