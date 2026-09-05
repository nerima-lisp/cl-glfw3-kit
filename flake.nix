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

    # Test-only dependency for the window-creation recording boundary.
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
      # Keep the development platform alongside the CI platform.
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      # GLFW's unversioned shared-library name is platform-specific.
      glfwLibraryPath =
        pkgs: "${pkgs.glfw}/lib/libglfw${pkgs.stdenv.hostPlatform.extensions.sharedLibrary}";

      # The generated test app needs the same library environment as the
      # default check, so wrap it explicitly.
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

      # nativeLibraries supplies GLFW to the Lisp derivation; env exposes its
      # exact shared-library path to the test and application runners.
      packageArgs = ctx: {
        nativeLibraries = [ ctx.pkgs.glfw ];
        env.CL_GLFW3_KIT_LIBRARY = glfwLibraryPath ctx.pkgs;
      };

      docs.root = ./docs;

      treefmt.evalModule = treefmt-nix.lib.evalModule;

      extraOutputs = ctx: {
        checks = {
          # Keep dead-code and compatibility markers out of source files.
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

          # Keep Lisp source files below the repository's 500-line guideline.
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

        # Real GLFW tests run separately because the flake-check sandbox has
        # no display server.
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

      # Generated apps do not inherit packageArgs' library environment.
      overrideOutputs = ctx: {
        apps = {
          test = wrapTestApp ctx.pkgs "cl-glfw3-kit-test" ctx.generated.apps.test;
          default = wrapTestApp ctx.pkgs "cl-glfw3-kit-test" ctx.generated.apps.default;
        };
      };
    };
}
