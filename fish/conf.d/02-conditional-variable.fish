if type -q sccache
  set -gx RUSTC_WRAPPER (which sccache)
end

if type -q npm
  set -gxp PATH (npm -g bin 2>/dev/null)
end

if type -q yarn
  set -gxp PATH (yarn global bin)
end

if [ -e /usr/local/opt/gnu-sed ]
  # GNU sed installed with Homebrew
  set -gxp PATH /usr/local/opt/gnu-sed/libexec/gnubin
end

if [ -e /usr/local/opt/gnu-tar ]
  # GNU tar installed with Homebrew
  set -gxp PATH /usr/local/opt/gnu-tar/libexec/gnubin
end

if [ -e /usr/local/opt/llvm ] && status --is-interactive
  # LLVM installed with Homebrew
  set -gxp PATH /usr/local/opt/llvm/bin
end
