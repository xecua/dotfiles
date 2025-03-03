{ pkgs, defaultUser, neovim-nightly-overlay, ... }:
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  environment.systemPackages = with pkgs; [
    gcc
    git
    llvm
    gnupg
    mold
  ];
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${defaultUser} = {
      programs.home-manager.enable = true;
      home = {
        username = defaultUser;
        stateVersion = "24.05";
        packages = with pkgs; [
          neovim-nightly-overlay.packages.${system}.default
          fish
          deno
          rustup
          nodejs
          go
          tmux
          unzip
          direnv
          difftastic
          eza
          fd
          ripgrep
          fzf
          lazygit
          tig
          lnav
          fastfetch
          jnv
          jaq
          unar
          hexyl
          bat
          starship
          skktools
          bat-extras.prettybat
          bat-extras.batpipe
          bat-extras.batman
          sccache
          radare2
          typst
          bottom
          temurin-bin
          # .NET: https://nixos.wiki/wiki/DotNET
          socat # WSLだけ?
        ];
        # file = {};
        # xdg.configFile = {};
      };
    };
  };
}
