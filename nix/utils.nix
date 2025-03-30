rec {
  make-item = path: { source = ../${path}; };
  make-recursive-item = path: {
    source = ../${path};
    target = path;
    recursive = true;
  };
  make-attr = path: { ${path} = make-item path; };
  make-maps = builtins.foldl' (acc: item: acc // make-attr item) { };
}
