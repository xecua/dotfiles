function randomstring
  if [ -z "$argv[1]" ]
    echo "usage: randomstring width" >&2
    return 1
  end
  cat /dev/urandom | base64 | fold -w $argv[1] | head -1
end

