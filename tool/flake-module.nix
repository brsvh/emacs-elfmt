{
  inputs,
  ...
}:
let
  inherit (inputs)
    infix
    ;
in
{
  imports = [
    infix.flakeModules.devshell
  ];

  perSystem =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    {
      devshells = {
        default = import ./devshells/default.nix {
          inherit
            lib
            pkgs
            ;

          elfmt = config.packages.elfmt;
        };
      };

      formatter = import ./formatter.nix {
        inherit
          lib
          pkgs
          ;

        treefmtConfig = config.devshells.default.files.treefmt;
      };
    };
}
