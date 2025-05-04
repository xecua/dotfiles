{
  pkgs,
  defaultUser,
  ...
}:
{
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    download-buffer-size = 500 * 1024 * 1024;
  };
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    bat
    clang
    curl
    gcc
    git
    git-extras
    git-filter-repo
    gnupg
    inetutils
    llvm
    mold
    neovim-unwrapped
    neovide
    firefox-devedition-bin
    vscode
    # neovim-nightly-overlay.packages.${system}.default
  ];
  fonts = {
    packages = with pkgs; [
      udev-gothic
      udev-gothic-nf
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      nerd-fonts.symbols-only
      font-awesome
    ];
  };
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = { inherit defaultUser; };
    users.${defaultUser} = {
      home.packages = with pkgs; [
        bat-extras.batman
        bat-extras.batpipe
        bat-extras.prettybat
        bottom
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
        lazydocker
        less
        lnav
        redocly
        mercurial
        mycli
        dua

        nodejs
        pastel
        # php84
        # php84Packages.composer
        # php84Packages.psysh
        pv
        python3
        visidata
        radare2
        rename
        ripgrep
        sccache
        skktools
        socat # WSLだけ?
        starship
        teip
        temurin-bin
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
    };
  };
}
