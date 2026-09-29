{
  description = "Command-line Emacs Lisp formatting with EditorConfig";

  inputs = {
    flake-parts = {
      inputs = {
        nixpkgs-lib = {
          follows = "nixpkgs";
        };
      };

      url = "git+https://github.com/hercules-ci/flake-parts.git?ref=main";
    };

    nixpkgs = {
      url = "git+https://github.com/NixOS/nixpkgs.git?ref=nixos-unstable";
    };
  };

  outputs =
    inputs@{
      flake-parts,
      ...
    }:
    let
      inherit (flake-parts.lib)
        mkFlake
        ;
    in
    mkFlake
      {
        inherit
          inputs
          ;
      }
      {
        imports = [
          flake-parts.flakeModules.partitions
        ];

        partitionedAttrs = {
          devShells = "tool";
          formatter = "tool";
        };

        partitions = {
          tool = {
            extraInputsFlake = ./tool;

            module = {
              imports = [
                ./tool/flake-module.nix
              ];
            };
          };
        };

        perSystem =
          {
            config,
            lib,
            pkgs,
            ...
          }:
          let
            inherit (lib)
              licenses
              maintainers
              ;

            inherit (pkgs)
              emacs-nox
              stdenvNoCC
              ;
          in
          {
            packages = {
              default = config.packages.elfmt;

              elfmt = stdenvNoCC.mkDerivation {
                pname = "elfmt";
                version = "0.1.0";

                src = ./lisp/elfmt.el;
                dontUnpack = true;

                nativeBuildInputs = [
                  emacs-nox
                ];

                installPhase = ''
                  runHook preInstall

                  install -Dm755 "$src" "$out/bin/elfmt"
                  patchShebangs --build "$out/bin/elfmt"
                  install -Dm644 ${./COPYING} \
                    "$out/share/licenses/elfmt/COPYING"

                  runHook postInstall
                '';

                meta = {
                  description = "Command-line Emacs Lisp formatting with EditorConfig";
                  homepage = "https://github.com/brsvh/emacs-elfmt";
                  license = licenses.gpl3Plus;
                  mainProgram = "elfmt";

                  maintainers = with maintainers; [
                    brsvh
                  ];

                  platforms = emacs-nox.meta.platforms;
                };
              };
            };
          };

        systems = [
          "x86_64-linux"
        ];
      };
}
