if status --is-interactive
    if type -q gibo
        gibo completion fish | source
    end

    if type -q xremap
        xremap --completions fish | source
    end

    if type -q localstack
        localstack completion fish 2>/dev/null | source
    end

    if type -q dyff
        dyff completion fish | source
    end

    if type -q dlv
        dlv completion fish | source
    end

    if type -q zmx
        zmx completions fish | source
    end

    if type -q brew
        if test -d (brew --prefix)"/share/fish/completions"
            set -p fish_complete_path (brew --prefix)/share/fish/completions
        end

        if test -d (brew --prefix)"/share/fish/vendor_completions.d"
            set -p fish_complete_path (brew --prefix)/share/fish/vendor_completions.d
        end
    end

end
