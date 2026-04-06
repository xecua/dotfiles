if status is-interactive
    # tmux内でのみ--tmuxオプションを追加する
    if set -q TMUX
        set -gx FZF_DEFAULT_OPTS "--tmux 80%"
    end

    if type -q podman && test (uname) = Darwin
        set -x PODMAN_HOST "unix://"(podman machine inspect --format '{{.ConnectionInfo.PodmanSocket.Path}}')
    end
end
