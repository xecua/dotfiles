{
  pkgs,
  defaultUser,
  # neovim-nightly-overlay,
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
    gnumake
    git
    git-extras
    git-filter-repo
    gnupg
    inetutils
    llvm
    # mold # Darwinで壊れている というかそもそも使わない
    neovide
    firefox-devedition
    vscode
    w3m
    neovim-unwrapped
    # neovim-nightly-overlay.packages.${system}.default

    lsof
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
        ghq
        lazydocker
        less
        lnav
        redocly
        mercurial
        mycli
        dua
        tdf

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
