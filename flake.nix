{
  description = "Common Lisp CFFI bindings for GLFW3 window, input, and context management";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    cl-nix-forge = {
      url = "github:nerima-lisp/cl-nix-forge/v0.5.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    cl-weave = {
      url = "github:nerima-lisp/cl-weave/v1.3.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self, nixpkgs, cl-nix-forge, cl-weave, treefmt-nix, ... }:
    let
      # aarch64-darwin included alongside the CI-gated x86_64-linux so
      # `nix build`/`nix flake check` work on the aarch64-darwin dev machine
      # too -- this reverts PACKAGE_STANDARD.md's 2026-08-01 Linux-only
      # decision the same way every other current sibling repo already has
      # (cl-codec-kit, cl-nyancat, cl-prolog-kit, cl-dataflow-kit).
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];
    in
    cl-nix-forge.lib.${nixpkgs.lib.head systems}.mkPackageFlake {
      inherit self systems nixpkgs;

      pname = "cl-glfw3-kit";
      asd = ./cl-glfw3-kit.asd;
      root = ./.;

      meta = {
        description = "Common Lisp CFFI bindings for GLFW3 window, input, and context management";
        homepage = "https://github.com/nerima-lisp/cl-glfw3-kit";
        license = nixpkgs.lib.licenses.mit;
      };

      lispCheckDependencies = ctx: [ cl-weave.packages.${ctx.system}.cl-weave ];

      docs.root = ./docs;

      treefmt.evalModule = treefmt-nix.lib.evalModule;
    };
}
