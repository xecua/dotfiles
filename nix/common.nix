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
    bat
    clang
    curl
    gcc
    git
    gnupg
    inetutils
    llvm
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
          bat-extras.batman
          bat-extras.batpipe
          bat-extras.prettybat
          bottom
          deno
          devcontainer
          difftastic
          dig
          direnv
          dotnetCorePackages.dotnet_9.sdk
          eza
          fastfetch
          fd
          fish
          fzf
          gh
          gnirehtet
          go
          hexyl
          httpie
          iconv
          jaq
          jnv
          lazygit
          less
          lnav
          mercurial
          mycli
          neovim-nightly-overlay.packages.${system}.default
          nodejs
          pastel
          php84
          php84Packages.composer
          # php84Packages.psysh
          pv
          python3
          python312Packages.weasyprint
          radare2
          rename
          ripgrep
          rustup
          sccache
          skktools
          socat # WSLだけ?
          starship
          teip
          temurin-bin
          tig
          tmux
          trash-cli
          trippy
          typst
          unar
          universal-ctags
          unzip
          # (uutils-coreutils.override { prefix = "u"; })
          wget
        ];
        # file = {};
      };
      xdg.dataFile = {
        "fish/vendor_completions.d/nix.fish".source = "${pkgs.nix}/share/fish/vendor_completions.d/nix.fish";
      };
    };
  };
}
