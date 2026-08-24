# Getting started

## Install

Via a sibling checkout on `CL_SOURCE_REGISTRY` or ASDF's `*central-registry*`:

```lisp
(asdf:load-system "cl-glfw3-kit")
```

## Running the tests

```sh
sbcl --script run-tests.lisp
```

expects a sibling `../cl-weave/` checkout (the test system's only
dependency; see `cl-glfw3-kit.asd`).

There is nothing to bind to GLFW3 yet — see the [roadmap](project/roadmap.md).
