function randomstring
  if [ -z "$argv[1]" ]
    echo "usage: randomstring width" >&2
    return 1
  end
  cat /dev/urandom | base64 | fold -w $argv[1] | head -1
end

# upgrade all installed packages
function pip-upgrade
  pip install -U (pip freeze | awk -F '==' '{print $1}')
end

function pip3-upgrade
  pip3 install -U (pip3 freeze | awk -F '==' '{print $1}')
end

