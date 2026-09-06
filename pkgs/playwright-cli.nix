# @playwright/cli (playwright-cli): nixpkgs には (2026-09 時点で) 存在しない
# 依存は playwright / playwright-core の 2 つだけなので、buildNpmPackage ではなく tarball を直接展開する。
#
# 更新手順: `npm view @playwright/cli version dependencies dist.integrity` と
#           `npm view playwright@<ver> dist.integrity` / `npm view playwright-core@<ver> dist.integrity`
#           で version / hash を差し替える。
{
  lib,
  stdenvNoCC,
  fetchurl,
  nodejs,
  makeWrapper,
}:
let
  version = "0.1.19";
  playwrightVersion = "1.63.0-alpha-2026-08-31";

  cli = fetchurl {
    url = "https://registry.npmjs.org/@playwright/cli/-/cli-${version}.tgz";
    hash = "sha512-eGXIsYa5D+dC6wHGf+9uEislhPGip1djK+yiNAD7BVsXN3WzzR1J4ClFAhYhyu7wSEFqhcPrqXAYeBJF1dKJ7A==";
  };
  playwright = fetchurl {
    url = "https://registry.npmjs.org/playwright/-/playwright-${playwrightVersion}.tgz";
    hash = "sha512-3XAsuznfu8jBVJ4QxdGvBkt0+b8ZFwuwJYyOfiIw5ZjUOrNLNRhKxzLzLuydou3gJ9c6eMwVqgzdiOwhy54Kzw==";
  };
  playwrightCore = fetchurl {
    url = "https://registry.npmjs.org/playwright-core/-/playwright-core-${playwrightVersion}.tgz";
    hash = "sha512-1ek0Lyr12h6jcs/WTcNoVtzZkQp7D/90PsMuBW/Rm6h3AsWAbzpqj0geMv8+8Tzzr9CSUYvg9kznrVZINQMXXw==";
  };
in
stdenvNoCC.mkDerivation {
  pname = "playwright-cli";
  inherit version;

  dontUnpack = true;
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall
    nm=$out/lib/node_modules
    mkdir -p $nm/@playwright/cli $nm/playwright $nm/playwright-core
    tar -xzf ${cli} -C $nm/@playwright/cli --strip-components=1
    tar -xzf ${playwright} -C $nm/playwright --strip-components=1
    tar -xzf ${playwrightCore} -C $nm/playwright-core --strip-components=1

    mkdir -p $out/bin
    makeWrapper ${lib.getExe nodejs} $out/bin/playwright-cli \
      --add-flags "$nm/@playwright/cli/playwright-cli.js"
    runHook postInstall
  '';

  passthru.skillsDir = "lib/node_modules/playwright-core/lib/tools/skills";

  meta = {
    description = "Playwright CLI for coding agents (playwright-cli)";
    homepage = "https://github.com/microsoft/playwright-cli";
    license = lib.licenses.asl20;
    mainProgram = "playwright-cli";
    platforms = lib.platforms.unix;
  };
}
