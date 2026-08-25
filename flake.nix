{
  description = "Common Lisp bindings for GLFW3 window, input, and context management";

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

    # The window-creation test seam's recording-boundary assertions (see
    # t/helpers-window.lisp) -- cl-glfw3-kit/test only, never the main
    # cl-glfw3-kit system.
    cl-boundary-kit = {
      url = "github:nerima-lisp/cl-boundary-kit/v2.3.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      cl-nix-forge,
      cl-weave,
      cl-boundary-kit,
      treefmt-nix,
      ...
    }:
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

      # The GLFW shared library's runtime-loadable name (see
      # src/library.lisp's SB-ALIEN:LOAD-SHARED-OBJECT) is platform-specific
      # but always available as this SONAME-unversioned symlink --
      # libglfw.dylib on darwin, libglfw.so on linux -- confirmed by
      # building nixpkgs' pkgs.glfw directly rather than assumed.
      glfwLibraryPath =
        pkgs: "${pkgs.glfw}/lib/libglfw${pkgs.stdenv.hostPlatform.extensions.sharedLibrary}";

      # apps.test/apps.default from mkPackageFlake's mkTestApp do not thread
      # `packageArgs`' `nativeLibraries`/`env` through (mkTestApp's own
      # signature has neither parameter -- confirmed by reading
      # lib/batteries/outputs.nix) -- only `checks.default`, built from the
      # fully-resolved `lispDerivation`, sees CL_GLFW3_KIT_LIBRARY
      # automatically. Wrap the generated app so `nix run .#test` sets the
      # same variable `nix flake check` already gets for free, rather than
      # leaving a README-documented workflow silently unable to find GLFW.
      wrapTestApp = pkgs: name: app: {
        type = "app";
        program = "${
          pkgs.writeShellApplication {
            inherit name;
            text = ''
              export CL_GLFW3_KIT_LIBRARY="${glfwLibraryPath pkgs}"
              exec ${app.program} "$@"
            '';
          }
        }/bin/${name}";
      };
    in
    cl-nix-forge.lib.${nixpkgs.lib.head systems}.mkPackageFlake {
      inherit self systems nixpkgs;

      pname = "cl-glfw3-kit";
      asd = ./cl-glfw3-kit.asd;
      root = ./.;

      meta = {
        description = "Common Lisp bindings for GLFW3 window, input, and context management";
        homepage = "https://github.com/nerima-lisp/cl-glfw3-kit";
        license = nixpkgs.lib.licenses.mit;
      };

      lispCheckDependencies = ctx: [
        cl-weave.packages.${ctx.system}.cl-weave
        cl-boundary-kit.packages.${ctx.system}.cl-boundary-kit
      ];

      # nativeLibraries is `lispDerivation`'s own hook for a real shared
      # library dependency (see lib/core/native.nix's libDirsOf: any
      # `${drv}/lib` works, no wrapping needed for an existing nixpkgs
      # package). env sets CL_GLFW3_KIT_LIBRARY to its exact store path,
      # mirroring cl-process-kit's CL_PROCESS_KIT_PTY_LIBRARY.
      packageArgs = ctx: {
        nativeLibraries = [ ctx.pkgs.glfw ];
        env.CL_GLFW3_KIT_LIBRARY = glfwLibraryPath ctx.pkgs;
      };

      docs.root = ./docs;

      treefmt.evalModule = treefmt-nix.lib.evalModule;

      extraOutputs = ctx: {
        checks = {
          # Dead code, TODO/FIXME/XXX markers, and adapter/backward-compat
          # layers have all been verified absent by hand across this
          # repository's refactoring passes; this turns that one-off
          # verification into a standing invariant CI enforces on every
          # push, the same pattern cl-process-kit's flake.nix uses.
          noForbiddenMarkers =
            ctx.pkgs.runCommand "cl-glfw3-kit-no-forbidden-markers"
              { nativeBuildInputs = [ ctx.pkgs.gnugrep ]; }
              ''
                cd ${self}
                if grep -rniE 'TODO|FIXME|XXX|adapter|backward.?compat' \
                    --include='*.lisp' --include='*.asd' --include='*.md' \
                    src t docs README.md; then
                  echo "Forbidden marker found above -- this project keeps zero" >&2
                  echo "TODO/FIXME/XXX/adapter/backward-compat markers." >&2
                  exit 1
                fi
                touch "$out"
              '';

          # cl-weave's own stated guideline: no source file exceeds 500
          # lines. A file approaching it is the point to reach for
          # paredit-cli's structural split/move commands.
          maxFileLength = ctx.pkgs.runCommand "cl-glfw3-kit-max-file-length" { } ''
            cd ${self}
            over=0
            for f in $(find src t -name '*.lisp'); do
              lines=$(wc -l < "$f")
              if [ "$lines" -gt 500 ]; then
                echo "$f has $lines lines, over the 500-line guideline." >&2
                over=1
              fi
            done
            if [ "$over" -ne 0 ]; then exit 1; fi
            touch "$out"
          '';

          # CODING_STANDARD.md's line-length rule.
          maxLineLength =
            ctx.pkgs.runCommand "cl-glfw3-kit-max-line-length" { nativeBuildInputs = [ ctx.pkgs.perl ]; }
              ''
                cd ${self}
                over=0
                for f in $(find src t -name '*.lisp'); do
                  long=$(perl -ne 'chomp; if (length > 100) { print "$.: " . length . "\n" }' "$f")
                  if [ -n "$long" ]; then
                    echo "$f has lines over 100 columns:" >&2
                    echo "$long" >&2
                    over=1
                  fi
                done
                if [ "$over" -ne 0 ]; then exit 1; fi
                touch "$out"
              '';
        };

        # Real-GLFWwindow suite (t/hardware/, cl-glfw3-kit/hardware-test),
        # split out of the default checks the way nerimux's real-PTY suite
        # is `nerimux/pty-test`: `nix flake check`'s sandbox has no display
        # server, so this never runs there -- only by hand, e.g. on this
        # org's aarch64-darwin dev machines.
        apps.test-hardware = wrapTestApp ctx.pkgs "cl-glfw3-kit-test-hardware" (
          ctx.cl.mkTestApp {
            pname = "cl-glfw3-kit-hardware";
            src = ctx.src;
            runner = "run-hardware-tests.lisp";
            lisp = ctx.lispDerivationArgs.lisp;
            lispDependencies = [
              cl-weave.packages.${ctx.system}.cl-weave
            ];
          }
        );
      };

      # See wrapTestApp: mkTestApp does not see packageArgs' env/nativeLibraries,
      # so apps.test/apps.default (unlike checks.default) need it added back by hand.
      overrideOutputs = ctx: {
        apps = {
          test = wrapTestApp ctx.pkgs "cl-glfw3-kit-test" ctx.generated.apps.test;
          default = wrapTestApp ctx.pkgs "cl-glfw3-kit-test" ctx.generated.apps.default;
        };
      };
    };
}
