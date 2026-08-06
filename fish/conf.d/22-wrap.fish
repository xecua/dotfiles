# wrap functions with special care

if type -q nix
    function nix --wraps nix
        if test "$argv[1]" = develop
            command nix develop $argv[2..-1] -c zsh
        else
            command nix $argv
        end
    end
end

# elio shell init fish
if type -q elio
    function elio
        switch "$argv[1]"
            case shell '-*'
                command elio $argv
                return $status
        end

        for arg in $argv
            switch "$arg"
                case --chooser-file '--chooser-file=*'
                    command elio $argv
                    return $status
            end
        end

        set -l tmp (mktemp -t "elio-cwd.XXXXXX")
        or return

        command elio --cwd-file "$tmp" $argv
        set -l status_code $status

        if test -s "$tmp"
            set -l cwd (string collect < "$tmp")
            rm -f "$tmp"
            if test -n "$cwd"; and test "$cwd" != "$PWD"; and test -d "$cwd"
                cd "$cwd"; or return $status
            end
        else
            rm -f "$tmp"
        end

        return $status_code
    end
end

if type -q devcontainer
    function poddevcontainer --wraps devcontainer
        if contains -- $argv[1] outdated features templates
            # docker-pathをオプションに取らないサブコマンド
            devcontainer $argv
        else
            devcontainer $argv[1] --docker-path podman $argv[2..-1]
        end
    end
end
