if type -q sccache
  set -gx RUSTC_WRAPPER (which sccache)
end

