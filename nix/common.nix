{
  pkgs,
  defaultUser,
  neovim-nightly-overlay,
  ...
}:
{
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    gcc
    git
    clang
    llvm
    gnupg
    mold
  ];
  programs.fish.enable = true; # enable `nix` completion
  fonts = {
    packages = with pkgs; [
      udev-gothic
      udev-gothic-nf
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      corefonts
      nerd-fonts.symbols-only
      font-awesome
    ];
  };
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
          mercurial
          mycli
          gh
          dig
          less
          curl
          wget
          devcontainer
          pv
          universal-ctags
          iconv
          pastel
          teip
          trippy
          python3
          httpie
          dotnetCorePackages.dotnet_9.sdk
          socat # WSLだけ?

          php84
          php84Packages.composer
          php84Packages.psysh
        ];
        # file = {};
        # xdg.configFile = {};
      };
    };
  };
}
