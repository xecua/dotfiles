if status --is-interactive
  if [ -e /usr/local/opt/llvm ]
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
end
