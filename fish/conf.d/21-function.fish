function randomstring
  if [ -z "$argv[1]" ]
    echo "usage: randomstring width" >&2
    return 1
  end
  cat /dev/urandom | base64 | fold -w $argv[1] | head -1
end

# load .env file before exec each command
# https://github.com/vially/fish-config/blob/7a8ba7310ca6ca5215538a48d19e8323215ca4c7/functions/dotenv.fish
function load_env --on-event fish_preexec
  if [ -e ".env" ]
    for line in (cat ".env")
      set -x (echo $line | cut -d = -f 1) (echo $line | cut -d = -f 2)
    end
  end
end

