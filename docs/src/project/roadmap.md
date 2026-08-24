# Roadmap

This repository is provisioning only today: GitHub repo, Cachix cache, CI,
and this documentation site exist; no GLFW3 binding does.

## What implementing the binding requires

- **External dependency justification.** `cffi` is the obvious FFI layer,
  but nerima-lisp/.github's `DEPENDENCY_POLICY.md` defaults to rejecting a
  new external dependency. All four conditions in its "外部依存を追加する手続き"
  section need to be satisfied explicitly in the PR body, including that
  this repository is L2 or above (`cffi` is precedented only in `cl-tmux`,
  an L4 repository, today).
- **A nixpkgs package for the C library.** `pkgs.glfw` exists in nixpkgs, so
  `nix flake check` can stay network-free.
- **A headless CI testing strategy.** `nix flake check` runs on
  `ubuntu-latest` with no display server and no GPU. Actually creating a
  GLFW window (`glfwCreateWindow`) will not work there unmodified; a real
  test suite needs either a virtual display (e.g. Xvfb) wired into the flake
  sandbox, or a test boundary that stops short of real window creation and
  only exercises the CFFI marshalling layer.

## Not yet decided

- Which GLFW3 API surface (window/input only, or also the native-context
  extensions) this binds.
- Whether tests need a real (virtual) display at all, or can stay at the
  marshalling layer.
