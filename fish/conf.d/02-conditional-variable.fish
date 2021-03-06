if type -q sccache
  set -gx RUSTC_WRAPPER (which sccache)
end

if type -q npm
  set -l npmbin (npm -g bin 2>/dev/null)
  if not contains $npmbin $PATH
    fish_add_path $npmbin
  end
end

if type -q yarn
  set -l yarnbin (yarn global bin)
  if not contains $yarnbin $PATH
    fish_add_path $yarnbin
  end
end

if [ -e /usr/local/opt/gnu-sed ]
  # GNU sed installed with Homebrew
  fish_add_path /usr/local/opt/gnu-sed/libexec/gnubin
end

if [ -e /usr/local/opt/gnu-tar ]
  # GNU tar installed with Homebrew
  fish_add_path /usr/local/opt/gnu-tar/libexec/gnubin
end

if [ -e /usr/local/opt/llvm ] && status --is-interactive
  # LLVM installed with Homebrew
  fish_add_path /usr/local/opt/llvm/bin
end

if [ -e /usr/local/opt/ruby ]
  # Ruby installed with Hoebrew
  # gems
  fish_add_path /usr/local/lib/ruby/gems/3.0.0/bin
  if status --is-interactive
    # interpreter
    fish_add_path /usr/local/opt/ruby/bin
  end
end
