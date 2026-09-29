{
  elfmt,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    getExe
    makeBinPath
    ;

  inherit (pkgs.formats)
    toml
    ;

  formatterPackages = with pkgs; [
    elfmt
    git
    nixfmt
    treefmt
  ];
in
{
  files = {
    prek = rec {
      data = {
        default_install_hook_types = [
          "pre-commit"
        ];

        repos = [
          {
            repo = "local";

            hooks = [
              {
                entry = "treefmt --fail-on-change";
                id = "treefmt";
                language = "system";
                name = "treefmt";
                require_serial = true;

                stages = [
                  "pre-commit"
                ];
              }
            ];
          }
        ];
      };

      deps = [
        "treefmt"
      ];

      generator = data: (toml { }).generate (baseNameOf path) data;

      hook =
        let
          inherit (pkgs)
            coreutils
            git
            prek
            writeShellScript
            ;

          preCommitHook = writeShellScript "prek-pre-commit" ''
            if [ "''${PREK:-}" = "0" ]; then
              exit 0
            fi

            repoRoot="$(${getExe git} rev-parse --show-toplevel)" || exit 1
            export PATH=${makeBinPath formatterPackages}:"$PATH"

            exec ${getExe prek} -C "$repoRoot" run --stage pre-commit "$@"
          '';
        in
        ''
          if hooksDir="$(
            ${getExe git} -C "$PRJ_ROOT" \
              rev-parse --path-format=absolute --git-path hooks \
              2>/dev/null
          )"; then
            ${coreutils}/bin/mkdir -p "$hooksDir"
            ${coreutils}/bin/ln -sf "${preCommitHook}" "$hooksDir/pre-commit"
          fi
        '';

      packages = with pkgs; [
        git
        prek
      ];

      path = "prek.toml";
    };

    treefmt = rec {
      data = {
        formatter = {
          emacs-lisp = {
            command = "elfmt";

            includes = [
              "*.el"
            ];
          };

          nix = {
            command = "nixfmt";

            includes = [
              "*.nix"
            ];

            options = [
              "--width=80"
            ];
          };
        };
      };

      generator = data: (toml { }).generate (baseNameOf path) data;

      packages = formatterPackages;
      path = "treefmt.toml";
    };
  };

  packages = with pkgs; [
    emacs-nox
  ];
}
