{ config, lib, pkgs, ... }:

with lib;

let
  homeDir = config.home.homeDirectory;
  fontsEnv = pkgs.buildEnv {
    name = "home-manager-fonts";
    paths = config.home.packages;
    pathsToLink = "/share/fonts";
  };
  fonts = "${fontsEnv}/share/fonts";
  installDir = "${homeDir}/Library/Fonts/HomeManager";
  cfg = config.targets.darwin;
in {
  options.targets.darwin.copyFonts = mkOption {
    type = with types; bool;
    default = true;
    description = ''
      This will copy home-manager-installed fonts to $HOME/Library/Fonts/HomeManager to ensure their use by installed applications. MacOS won't recognize fonts merely symlinked there.
    '';
  };
  # macOS won't recognize symlinked fonts
  config = mkIf cfg.copyFonts {
    home.file."Library/Fonts/.home-manager-fonts-version" = {
      text = "${fontsEnv}";
      onChange = ''
        run mkdir -p ${escapeShellArg installDir}
        run ${pkgs.rsync}/bin/rsync $VERBOSE_ARG -acL --chmod=u+w --delete \
          ${escapeShellArgs [ "${fonts}/" installDir ]}
      '';
    };
  };
}
