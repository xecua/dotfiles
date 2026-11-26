# Print an optspec for argparse to handle cmd's options that are independent of any subcommand.
function __fish_kache_global_optspecs
    string join \n json h/help V/version
end

function __fish_kache_needs_command
    # Figure out if the current invocation already has a command.
    set -l cmd (commandline -opc)
    set -e cmd[1]
    argparse -s (__fish_kache_global_optspecs) -- $cmd 2>/dev/null
    or return
    if set -q argv[1]
        # Also print the command, so this can be used to figure out what it is.
        echo $argv[1]
        return 1
    end
    return 0
end

function __fish_kache_using_subcommand
    set -l cmd (__fish_kache_needs_command)
    test -z "$cmd"
    and return 1
    contains -- $cmd[1] $argv
end

complete -c kache -n "__fish_kache_needs_command" -l json -d 'Machine-readable JSON on stdout, on commands that support it'
complete -c kache -n "__fish_kache_needs_command" -s h -l help -d 'Print help'
complete -c kache -n "__fish_kache_needs_command" -s V -l version -d 'Print version'
complete -c kache -n "__fish_kache_needs_command" -f -a "list" -d 'List cache entries, or one crate\'s entries in detail'
complete -c kache -n "__fish_kache_needs_command" -f -a "clean" -d 'Free disk space: remove old target directories, or empty the cache'
complete -c kache -n "__fish_kache_needs_command" -f -a "init" -d 'Set up caching for Cargo and C/C++ builds'
complete -c kache -n "__fish_kache_needs_command" -f -a "doctor" -d 'Diagnose setup issues and verify cache integrity'
complete -c kache -n "__fish_kache_needs_command" -f -a "sync" -d 'Pull from and push to the configured remote'
complete -c kache -n "__fish_kache_needs_command" -f -a "daemon" -d 'Show the background daemon\'s status, or start, stop or install it'
complete -c kache -n "__fish_kache_needs_command" -f -a "monitor" -d 'Watch builds and the cache live'
complete -c kache -n "__fish_kache_needs_command" -f -a "stats" -d 'Show hit rate, time saved and cache size; --full for the whole report'
complete -c kache -n "__fish_kache_needs_command" -f -a "status" -d 'Show hit rate, time saved and cache size; --full for the whole report'
complete -c kache -n "__fish_kache_needs_command" -f -a "key" -d 'Print one rustc invocation\'s cache-key inputs, or diff two of those documents'
complete -c kache -n "__fish_kache_needs_command" -f -a "explain" -d 'Explain why a crate, or the latest build, missed the cache'
complete -c kache -n "__fish_kache_needs_command" -f -a "config" -d 'Edit or inspect configuration (opens the editor without a subcommand)'
complete -c kache -n "__fish_kache_needs_command" -f -a "login" -d 'Log in to the planner with your Kunobi account'
complete -c kache -n "__fish_kache_needs_command" -f -a "logout" -d 'Log out of the planner and revoke the stored Kunobi session'
complete -c kache -n "__fish_kache_needs_command" -f -a "completions" -d 'Generate shell completion scripts'
complete -c kache -n "__fish_kache_needs_command" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c kache -n "__fish_kache_using_subcommand list" -l sort -d 'Sort by name, size, hits or age' -r -f -a "name\t''
size\t''
hits\t''
age\t''"
complete -c kache -n "__fish_kache_using_subcommand list" -l no-pager -d 'Print directly instead of using a pager'
complete -c kache -n "__fish_kache_using_subcommand list" -l json -d 'Machine-readable JSON on stdout, on commands that support it'
complete -c kache -n "__fish_kache_using_subcommand list" -s h -l help -d 'Print help'
complete -c kache -n "__fish_kache_using_subcommand clean" -l stale -d 'Targets no build used for this long, and targets whose worktree is gone (default 14d)' -r
complete -c kache -n "__fish_kache_using_subcommand clean" -l rustc-version -d 'With --cache: remove this Rust release or exact compiler build' -r
complete -c kache -n "__fish_kache_using_subcommand clean" -l units -l artifacts -d 'Remove obsolete units in live targets using a recorded Cargo command'
complete -c kache -n "__fish_kache_using_subcommand clean" -s n -l dry-run -d 'Show what would be removed and what kache keeps, and remove nothing'
complete -c kache -n "__fish_kache_using_subcommand clean" -s y -l yes -d 'Remove without asking. For scripts and cron; preview first with --dry-run'
complete -c kache -n "__fish_kache_using_subcommand clean" -l cache -d 'Empty the cache instead. Asks first. The daemon already keeps it under its size limit'
complete -c kache -n "__fish_kache_using_subcommand clean" -l orphans -d 'Only targets whose worktree or workspace was deleted, however recently they were built'
complete -c kache -n "__fish_kache_using_subcommand clean" -l json -d 'Machine-readable JSON on stdout, on commands that support it'
complete -c kache -n "__fish_kache_using_subcommand clean" -s h -l help -d 'Print help'
complete -c kache -n "__fish_kache_using_subcommand init" -l shims -d 'Only create the compiler-name links to kache (Unix), in DIR or ~/.local/lib/kache/shims, and change nothing else' -r -F
complete -c kache -n "__fish_kache_using_subcommand init" -s y -l yes -d 'Accept all default answers (non-interactive)'
complete -c kache -n "__fish_kache_using_subcommand init" -l no-service -d 'Do not install the daemon as a login service'
complete -c kache -n "__fish_kache_using_subcommand init" -l no-shell -d 'Leave shell setup alone: no C/C++ shims on PATH, test runner, or completions (Cargo native dependencies are still configured)'
complete -c kache -n "__fish_kache_using_subcommand init" -s n -l check -l dry-run -d 'Print what would change without modifying anything'
complete -c kache -n "__fish_kache_using_subcommand init" -l from-path -d 'With --shims, also link every other compiler name on PATH (target triplets)'
complete -c kache -n "__fish_kache_using_subcommand init" -l canonical-only -d 'With --shims, link only the unversioned names, not the versioned compilers on PATH (clang-19, g++-13)'
complete -c kache -n "__fish_kache_using_subcommand init" -l force -d 'With --shims, replace existing entries instead of refusing'
complete -c kache -n "__fish_kache_using_subcommand init" -l json -d 'Machine-readable JSON on stdout, on commands that support it'
complete -c kache -n "__fish_kache_using_subcommand init" -s h -l help -d 'Print help'
complete -c kache -n "__fish_kache_using_subcommand doctor" -l repair-build-scripts -d 'Refresh build-script runtime pins in this idle Cargo target directory' -r -F
complete -c kache -n "__fish_kache_using_subcommand doctor" -l fix -d 'Migrate from sccache (Cargo wrapper, running server) and restart a daemon older than this binary'
complete -c kache -n "__fish_kache_using_subcommand doctor" -l purge-sccache -d 'Also remove sccache cache and binary (requires --fix)'
complete -c kache -n "__fish_kache_using_subcommand doctor" -l verify -d 'Verify cache integrity (entries, blobs, metadata)'
complete -c kache -n "__fish_kache_using_subcommand doctor" -l checksums -d 'Also verify blob checksums (slower, implies --verify)'
complete -c kache -n "__fish_kache_using_subcommand doctor" -l repair -d 'Remove corrupted entries (implies --verify)'
complete -c kache -n "__fish_kache_using_subcommand doctor" -l probe -d 'Compile a temporary Rust library and verify a local cache hit (no remote access)'
complete -c kache -n "__fish_kache_using_subcommand doctor" -l json -d 'Machine-readable JSON on stdout, on commands that support it'
complete -c kache -n "__fish_kache_using_subcommand doctor" -s h -l help -d 'Print help'
complete -c kache -n "__fish_kache_using_subcommand sync" -l manifest-path -d 'Path to Cargo.toml (default: current directory)' -r
complete -c kache -n "__fish_kache_using_subcommand sync" -l pull -d 'Only download from the remote (skip uploads)'
complete -c kache -n "__fish_kache_using_subcommand sync" -l push -d 'Only upload to the remote (skip downloads)'
complete -c kache -n "__fish_kache_using_subcommand sync" -s n -l dry-run -d 'Show what would be synced without transferring'
complete -c kache -n "__fish_kache_using_subcommand sync" -l all -d 'Pull all remote artifacts (ignore workspace filtering)'
complete -c kache -n "__fish_kache_using_subcommand sync" -l workspace -d 'Scope the pull listing to workspace members (one LIST per member) instead of one LIST per Cargo.lock dependency crate'
complete -c kache -n "__fish_kache_using_subcommand sync" -l allow-partial -d 'Allow partial synchronization and exit successfully (code 0) even if some transfers or imports fail'
complete -c kache -n "__fish_kache_using_subcommand sync" -l json -d 'Machine-readable JSON on stdout, on commands that support it'
complete -c kache -n "__fish_kache_using_subcommand sync" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c kache -n "__fish_kache_using_subcommand daemon; and not __fish_seen_subcommand_from status run start stop restart install uninstall log help" -l json -d 'Machine-readable JSON on stdout, on commands that support it'
complete -c kache -n "__fish_kache_using_subcommand daemon; and not __fish_seen_subcommand_from status run start stop restart install uninstall log help" -s h -l help -d 'Print help'
complete -c kache -n "__fish_kache_using_subcommand daemon; and not __fish_seen_subcommand_from status run start stop restart install uninstall log help" -f -a "status" -d 'Show daemon status (also bare `kache daemon`)'
complete -c kache -n "__fish_kache_using_subcommand daemon; and not __fish_seen_subcommand_from status run start stop restart install uninstall log help" -f -a "run" -d 'Run the daemon server in the foreground'
complete -c kache -n "__fish_kache_using_subcommand daemon; and not __fish_seen_subcommand_from status run start stop restart install uninstall log help" -f -a "start" -d 'Start the daemon in the background and wait until it is ready'
complete -c kache -n "__fish_kache_using_subcommand daemon; and not __fish_seen_subcommand_from status run start stop restart install uninstall log help" -f -a "stop" -d 'Stop a running daemon'
complete -c kache -n "__fish_kache_using_subcommand daemon; and not __fish_seen_subcommand_from status run start stop restart install uninstall log help" -f -a "restart" -d 'Restart the daemon, through its login service when one is installed'
complete -c kache -n "__fish_kache_using_subcommand daemon; and not __fish_seen_subcommand_from status run start stop restart install uninstall log help" -f -a "install" -d 'Install the daemon as a per-user login service (launchd, systemd user unit, Task Scheduler)'
complete -c kache -n "__fish_kache_using_subcommand daemon; and not __fish_seen_subcommand_from status run start stop restart install uninstall log help" -f -a "uninstall" -d 'Remove the daemon service'
complete -c kache -n "__fish_kache_using_subcommand daemon; and not __fish_seen_subcommand_from status run start stop restart install uninstall log help" -f -a "log" -d 'Stream daemon logs'
complete -c kache -n "__fish_kache_using_subcommand daemon; and not __fish_seen_subcommand_from status run start stop restart install uninstall log help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c kache -n "__fish_kache_using_subcommand daemon; and __fish_seen_subcommand_from status" -l json -d 'Machine-readable JSON on stdout, on commands that support it'
complete -c kache -n "__fish_kache_using_subcommand daemon; and __fish_seen_subcommand_from status" -s h -l help -d 'Print help'
complete -c kache -n "__fish_kache_using_subcommand daemon; and __fish_seen_subcommand_from run" -l json -d 'Machine-readable JSON on stdout, on commands that support it'
complete -c kache -n "__fish_kache_using_subcommand daemon; and __fish_seen_subcommand_from run" -s h -l help -d 'Print help'
complete -c kache -n "__fish_kache_using_subcommand daemon; and __fish_seen_subcommand_from start" -l json -d 'Machine-readable JSON on stdout, on commands that support it'
complete -c kache -n "__fish_kache_using_subcommand daemon; and __fish_seen_subcommand_from start" -s h -l help -d 'Print help'
complete -c kache -n "__fish_kache_using_subcommand daemon; and __fish_seen_subcommand_from stop" -l json -d 'Machine-readable JSON on stdout, on commands that support it'
complete -c kache -n "__fish_kache_using_subcommand daemon; and __fish_seen_subcommand_from stop" -s h -l help -d 'Print help'
complete -c kache -n "__fish_kache_using_subcommand daemon; and __fish_seen_subcommand_from restart" -l json -d 'Machine-readable JSON on stdout, on commands that support it'
complete -c kache -n "__fish_kache_using_subcommand daemon; and __fish_seen_subcommand_from restart" -s h -l help -d 'Print help'
complete -c kache -n "__fish_kache_using_subcommand daemon; and __fish_seen_subcommand_from install" -l json -d 'Machine-readable JSON on stdout, on commands that support it'
complete -c kache -n "__fish_kache_using_subcommand daemon; and __fish_seen_subcommand_from install" -s h -l help -d 'Print help'
complete -c kache -n "__fish_kache_using_subcommand daemon; and __fish_seen_subcommand_from uninstall" -l json -d 'Machine-readable JSON on stdout, on commands that support it'
complete -c kache -n "__fish_kache_using_subcommand daemon; and __fish_seen_subcommand_from uninstall" -s h -l help -d 'Print help'
complete -c kache -n "__fish_kache_using_subcommand daemon; and __fish_seen_subcommand_from log" -l json -d 'Machine-readable JSON on stdout, on commands that support it'
complete -c kache -n "__fish_kache_using_subcommand daemon; and __fish_seen_subcommand_from log" -s h -l help -d 'Print help'
complete -c kache -n "__fish_kache_using_subcommand daemon; and __fish_seen_subcommand_from help" -f -a "status" -d 'Show daemon status (also bare `kache daemon`)'
complete -c kache -n "__fish_kache_using_subcommand daemon; and __fish_seen_subcommand_from help" -f -a "run" -d 'Run the daemon server in the foreground'
complete -c kache -n "__fish_kache_using_subcommand daemon; and __fish_seen_subcommand_from help" -f -a "start" -d 'Start the daemon in the background and wait until it is ready'
complete -c kache -n "__fish_kache_using_subcommand daemon; and __fish_seen_subcommand_from help" -f -a "stop" -d 'Stop a running daemon'
complete -c kache -n "__fish_kache_using_subcommand daemon; and __fish_seen_subcommand_from help" -f -a "restart" -d 'Restart the daemon, through its login service when one is installed'
complete -c kache -n "__fish_kache_using_subcommand daemon; and __fish_seen_subcommand_from help" -f -a "install" -d 'Install the daemon as a per-user login service (launchd, systemd user unit, Task Scheduler)'
complete -c kache -n "__fish_kache_using_subcommand daemon; and __fish_seen_subcommand_from help" -f -a "uninstall" -d 'Remove the daemon service'
complete -c kache -n "__fish_kache_using_subcommand daemon; and __fish_seen_subcommand_from help" -f -a "log" -d 'Stream daemon logs'
complete -c kache -n "__fish_kache_using_subcommand daemon; and __fish_seen_subcommand_from help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c kache -n "__fish_kache_using_subcommand monitor" -l since -d 'Preload events from this window (e.g. 15m, 2h, 7d; a bare number is hours)' -r
complete -c kache -n "__fish_kache_using_subcommand monitor" -l json -d 'Machine-readable JSON on stdout, on commands that support it'
complete -c kache -n "__fish_kache_using_subcommand monitor" -s h -l help -d 'Print help'
complete -c kache -n "__fish_kache_using_subcommand stats" -l since -d 'Event window (e.g. 15m, 2h, 7d; a bare number is hours)' -r
complete -c kache -n "__fish_kache_using_subcommand stats" -l root -d 'Only this build tree/root: the latest session in it with `--last-build`, its compiler events with `--full`' -r -F
complete -c kache -n "__fish_kache_using_subcommand stats" -l format -d 'Write the full report as json, markdown, github, or trace (Perfetto / Chrome trace). Implies --full' -r -f -a "text\t''
json\t''
markdown\t''
github\t''
trace\t'Perfetto / Chrome trace JSON'"
complete -c kache -n "__fish_kache_using_subcommand stats" -s o -l output -d 'Write the full report to a file instead of stdout. Implies --full' -r -F
complete -c kache -n "__fish_kache_using_subcommand stats" -l top -d 'Entries in each top list of the full report. Implies --full' -r
complete -c kache -n "__fish_kache_using_subcommand stats" -l last-build -d 'Report the latest recorded activity session. Sessions may span Cargo commands; events without IDs use a five-minute idle gap per root'
complete -c kache -n "__fish_kache_using_subcommand stats" -l full -d 'The full build report instead of the summary'
complete -c kache -n "__fish_kache_using_subcommand stats" -l record -d 'Also append the full report\'s summary and timing, with the host\'s load, to `<cache dir>/telemetry/sessions.jsonl`, which outlives the runtime dir a CI job deletes. Implies --full'
complete -c kache -n "__fish_kache_using_subcommand stats" -l redact -d 'Replace cache keys, roots, and object paths in the full report with `redacted`. Implies --full'
complete -c kache -n "__fish_kache_using_subcommand stats" -l json -d 'Machine-readable JSON on stdout, on commands that support it'
complete -c kache -n "__fish_kache_using_subcommand stats" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c kache -n "__fish_kache_using_subcommand status" -l since -d 'Event window (e.g. 15m, 2h, 7d; a bare number is hours)' -r
complete -c kache -n "__fish_kache_using_subcommand status" -l root -d 'Only this build tree/root: the latest session in it with `--last-build`, its compiler events with `--full`' -r -F
complete -c kache -n "__fish_kache_using_subcommand status" -l format -d 'Write the full report as json, markdown, github, or trace (Perfetto / Chrome trace). Implies --full' -r -f -a "text\t''
json\t''
markdown\t''
github\t''
trace\t'Perfetto / Chrome trace JSON'"
complete -c kache -n "__fish_kache_using_subcommand status" -s o -l output -d 'Write the full report to a file instead of stdout. Implies --full' -r -F
complete -c kache -n "__fish_kache_using_subcommand status" -l top -d 'Entries in each top list of the full report. Implies --full' -r
complete -c kache -n "__fish_kache_using_subcommand status" -l last-build -d 'Report the latest recorded activity session. Sessions may span Cargo commands; events without IDs use a five-minute idle gap per root'
complete -c kache -n "__fish_kache_using_subcommand status" -l full -d 'The full build report instead of the summary'
complete -c kache -n "__fish_kache_using_subcommand status" -l record -d 'Also append the full report\'s summary and timing, with the host\'s load, to `<cache dir>/telemetry/sessions.jsonl`, which outlives the runtime dir a CI job deletes. Implies --full'
complete -c kache -n "__fish_kache_using_subcommand status" -l redact -d 'Replace cache keys, roots, and object paths in the full report with `redacted`. Implies --full'
complete -c kache -n "__fish_kache_using_subcommand status" -l json -d 'Machine-readable JSON on stdout, on commands that support it'
complete -c kache -n "__fish_kache_using_subcommand status" -s h -l help -d 'Print help (see more with \'--help\')'
complete -c kache -n "__fish_kache_using_subcommand key; and not __fish_seen_subcommand_from explain diff help" -l json -d 'Machine-readable JSON on stdout, on commands that support it'
complete -c kache -n "__fish_kache_using_subcommand key; and not __fish_seen_subcommand_from explain diff help" -s h -l help -d 'Print help'
complete -c kache -n "__fish_kache_using_subcommand key; and not __fish_seen_subcommand_from explain diff help" -f -a "explain" -d 'Print the canonical key inputs of one rustc invocation as JSON. Does not run rustc'
complete -c kache -n "__fish_kache_using_subcommand key; and not __fish_seen_subcommand_from explain diff help" -f -a "diff" -d 'Name the fields that differ between two key-input JSON documents'
complete -c kache -n "__fish_kache_using_subcommand key; and not __fish_seen_subcommand_from explain diff help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c kache -n "__fish_kache_using_subcommand key; and __fish_seen_subcommand_from explain" -l rustc-version -d '`rustc -vV` text. Without it, the host line is left out. This command does not run rustc' -r
complete -c kache -n "__fish_kache_using_subcommand key; and __fish_seen_subcommand_from explain" -l rustc-version-file -d 'File containing `rustc -vV` text. This command does not run rustc' -r -F
complete -c kache -n "__fish_kache_using_subcommand key; and __fish_seen_subcommand_from explain" -l json -d 'Machine-readable JSON on stdout, on commands that support it'
complete -c kache -n "__fish_kache_using_subcommand key; and __fish_seen_subcommand_from explain" -s h -l help -d 'Print help'
complete -c kache -n "__fish_kache_using_subcommand key; and __fish_seen_subcommand_from diff" -l json -d 'Machine-readable JSON on stdout, on commands that support it'
complete -c kache -n "__fish_kache_using_subcommand key; and __fish_seen_subcommand_from diff" -s h -l help -d 'Print help'
complete -c kache -n "__fish_kache_using_subcommand key; and __fish_seen_subcommand_from help" -f -a "explain" -d 'Print the canonical key inputs of one rustc invocation as JSON. Does not run rustc'
complete -c kache -n "__fish_kache_using_subcommand key; and __fish_seen_subcommand_from help" -f -a "diff" -d 'Name the fields that differ between two key-input JSON documents'
complete -c kache -n "__fish_kache_using_subcommand key; and __fish_seen_subcommand_from help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c kache -n "__fish_kache_using_subcommand explain" -l root -d 'Without a crate: only builds recorded for this build tree' -r -F
complete -c kache -n "__fish_kache_using_subcommand explain" -l all -d 'List every skip and passthrough across the retained build history, with counts by reason and the affected crates'
complete -c kache -n "__fish_kache_using_subcommand explain" -l json -d 'Machine-readable JSON on stdout, on commands that support it'
complete -c kache -n "__fish_kache_using_subcommand explain" -s h -l help -d 'Print help'
complete -c kache -n "__fish_kache_using_subcommand config; and not __fish_seen_subcommand_from get list set unset path help" -l json -d 'Machine-readable JSON on stdout, on commands that support it'
complete -c kache -n "__fish_kache_using_subcommand config; and not __fish_seen_subcommand_from get list set unset path help" -s h -l help -d 'Print help'
complete -c kache -n "__fish_kache_using_subcommand config; and not __fish_seen_subcommand_from get list set unset path help" -f -a "get" -d 'Read a value explicitly set in the selected file'
complete -c kache -n "__fish_kache_using_subcommand config; and not __fish_seen_subcommand_from get list set unset path help" -f -a "list" -d 'List values explicitly set in the selected file'
complete -c kache -n "__fish_kache_using_subcommand config; and not __fish_seen_subcommand_from get list set unset path help" -f -a "set" -d 'Set a known configuration key; accepts TOML values or an unquoted string'
complete -c kache -n "__fish_kache_using_subcommand config; and not __fish_seen_subcommand_from get list set unset path help" -f -a "unset" -d 'Remove a value from the selected file'
complete -c kache -n "__fish_kache_using_subcommand config; and not __fish_seen_subcommand_from get list set unset path help" -f -a "path" -d 'Print the selected file\'s path, even if it does not exist'
complete -c kache -n "__fish_kache_using_subcommand config; and not __fish_seen_subcommand_from get list set unset path help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c kache -n "__fish_kache_using_subcommand config; and __fish_seen_subcommand_from get" -l file -d 'Use this configuration file' -r -F
complete -c kache -n "__fish_kache_using_subcommand config; and __fish_seen_subcommand_from get" -l project -d 'Use the nearest project config, or create .kache.toml in this directory'
complete -c kache -n "__fish_kache_using_subcommand config; and __fish_seen_subcommand_from get" -l global -d 'Use the user config, ignoring KACHE_CONFIG and project files'
complete -c kache -n "__fish_kache_using_subcommand config; and __fish_seen_subcommand_from get" -l json -d 'Machine-readable JSON on stdout, on commands that support it'
complete -c kache -n "__fish_kache_using_subcommand config; and __fish_seen_subcommand_from get" -s h -l help -d 'Print help'
complete -c kache -n "__fish_kache_using_subcommand config; and __fish_seen_subcommand_from list" -l file -d 'Use this configuration file' -r -F
complete -c kache -n "__fish_kache_using_subcommand config; and __fish_seen_subcommand_from list" -l project -d 'Use the nearest project config, or create .kache.toml in this directory'
complete -c kache -n "__fish_kache_using_subcommand config; and __fish_seen_subcommand_from list" -l global -d 'Use the user config, ignoring KACHE_CONFIG and project files'
complete -c kache -n "__fish_kache_using_subcommand config; and __fish_seen_subcommand_from list" -l json -d 'Machine-readable JSON on stdout, on commands that support it'
complete -c kache -n "__fish_kache_using_subcommand config; and __fish_seen_subcommand_from list" -s h -l help -d 'Print help'
complete -c kache -n "__fish_kache_using_subcommand config; and __fish_seen_subcommand_from set" -l file -d 'Use this configuration file' -r -F
complete -c kache -n "__fish_kache_using_subcommand config; and __fish_seen_subcommand_from set" -l project -d 'Use the nearest project config, or create .kache.toml in this directory'
complete -c kache -n "__fish_kache_using_subcommand config; and __fish_seen_subcommand_from set" -l global -d 'Use the user config, ignoring KACHE_CONFIG and project files'
complete -c kache -n "__fish_kache_using_subcommand config; and __fish_seen_subcommand_from set" -l json -d 'Machine-readable JSON on stdout, on commands that support it'
complete -c kache -n "__fish_kache_using_subcommand config; and __fish_seen_subcommand_from set" -s h -l help -d 'Print help'
complete -c kache -n "__fish_kache_using_subcommand config; and __fish_seen_subcommand_from unset" -l file -d 'Use this configuration file' -r -F
complete -c kache -n "__fish_kache_using_subcommand config; and __fish_seen_subcommand_from unset" -l project -d 'Use the nearest project config, or create .kache.toml in this directory'
complete -c kache -n "__fish_kache_using_subcommand config; and __fish_seen_subcommand_from unset" -l global -d 'Use the user config, ignoring KACHE_CONFIG and project files'
complete -c kache -n "__fish_kache_using_subcommand config; and __fish_seen_subcommand_from unset" -l json -d 'Machine-readable JSON on stdout, on commands that support it'
complete -c kache -n "__fish_kache_using_subcommand config; and __fish_seen_subcommand_from unset" -s h -l help -d 'Print help'
complete -c kache -n "__fish_kache_using_subcommand config; and __fish_seen_subcommand_from path" -l file -d 'Use this configuration file' -r -F
complete -c kache -n "__fish_kache_using_subcommand config; and __fish_seen_subcommand_from path" -l project -d 'Use the nearest project config, or create .kache.toml in this directory'
complete -c kache -n "__fish_kache_using_subcommand config; and __fish_seen_subcommand_from path" -l global -d 'Use the user config, ignoring KACHE_CONFIG and project files'
complete -c kache -n "__fish_kache_using_subcommand config; and __fish_seen_subcommand_from path" -l json -d 'Machine-readable JSON on stdout, on commands that support it'
complete -c kache -n "__fish_kache_using_subcommand config; and __fish_seen_subcommand_from path" -s h -l help -d 'Print help'
complete -c kache -n "__fish_kache_using_subcommand config; and __fish_seen_subcommand_from help" -f -a "get" -d 'Read a value explicitly set in the selected file'
complete -c kache -n "__fish_kache_using_subcommand config; and __fish_seen_subcommand_from help" -f -a "list" -d 'List values explicitly set in the selected file'
complete -c kache -n "__fish_kache_using_subcommand config; and __fish_seen_subcommand_from help" -f -a "set" -d 'Set a known configuration key; accepts TOML values or an unquoted string'
complete -c kache -n "__fish_kache_using_subcommand config; and __fish_seen_subcommand_from help" -f -a "unset" -d 'Remove a value from the selected file'
complete -c kache -n "__fish_kache_using_subcommand config; and __fish_seen_subcommand_from help" -f -a "path" -d 'Print the selected file\'s path, even if it does not exist'
complete -c kache -n "__fish_kache_using_subcommand config; and __fish_seen_subcommand_from help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c kache -n "__fish_kache_using_subcommand login" -l device -d 'Sign in on another device (prints a URL and a code)'
complete -c kache -n "__fish_kache_using_subcommand login" -l retrust -d 'Accept and re-pin the planner\'s current login issuer when it no longer matches the one first trusted'
complete -c kache -n "__fish_kache_using_subcommand login" -l json -d 'Machine-readable JSON on stdout, on commands that support it'
complete -c kache -n "__fish_kache_using_subcommand login" -s h -l help -d 'Print help'
complete -c kache -n "__fish_kache_using_subcommand logout" -l json -d 'Machine-readable JSON on stdout, on commands that support it'
complete -c kache -n "__fish_kache_using_subcommand logout" -s h -l help -d 'Print help'
complete -c kache -n "__fish_kache_using_subcommand completions" -l json -d 'Machine-readable JSON on stdout, on commands that support it'
complete -c kache -n "__fish_kache_using_subcommand completions" -s h -l help -d 'Print help'
complete -c kache -n "__fish_kache_using_subcommand help; and not __fish_seen_subcommand_from list clean init doctor sync daemon monitor stats key explain config login logout completions help" -f -a "list" -d 'List cache entries, or one crate\'s entries in detail'
complete -c kache -n "__fish_kache_using_subcommand help; and not __fish_seen_subcommand_from list clean init doctor sync daemon monitor stats key explain config login logout completions help" -f -a "clean" -d 'Free disk space: remove old target directories, or empty the cache'
complete -c kache -n "__fish_kache_using_subcommand help; and not __fish_seen_subcommand_from list clean init doctor sync daemon monitor stats key explain config login logout completions help" -f -a "init" -d 'Set up caching for Cargo and C/C++ builds'
complete -c kache -n "__fish_kache_using_subcommand help; and not __fish_seen_subcommand_from list clean init doctor sync daemon monitor stats key explain config login logout completions help" -f -a "doctor" -d 'Diagnose setup issues and verify cache integrity'
complete -c kache -n "__fish_kache_using_subcommand help; and not __fish_seen_subcommand_from list clean init doctor sync daemon monitor stats key explain config login logout completions help" -f -a "sync" -d 'Pull from and push to the configured remote'
complete -c kache -n "__fish_kache_using_subcommand help; and not __fish_seen_subcommand_from list clean init doctor sync daemon monitor stats key explain config login logout completions help" -f -a "daemon" -d 'Show the background daemon\'s status, or start, stop or install it'
complete -c kache -n "__fish_kache_using_subcommand help; and not __fish_seen_subcommand_from list clean init doctor sync daemon monitor stats key explain config login logout completions help" -f -a "monitor" -d 'Watch builds and the cache live'
complete -c kache -n "__fish_kache_using_subcommand help; and not __fish_seen_subcommand_from list clean init doctor sync daemon monitor stats key explain config login logout completions help" -f -a "stats" -d 'Show hit rate, time saved and cache size; --full for the whole report'
complete -c kache -n "__fish_kache_using_subcommand help; and not __fish_seen_subcommand_from list clean init doctor sync daemon monitor stats key explain config login logout completions help" -f -a "key" -d 'Print one rustc invocation\'s cache-key inputs, or diff two of those documents'
complete -c kache -n "__fish_kache_using_subcommand help; and not __fish_seen_subcommand_from list clean init doctor sync daemon monitor stats key explain config login logout completions help" -f -a "explain" -d 'Explain why a crate, or the latest build, missed the cache'
complete -c kache -n "__fish_kache_using_subcommand help; and not __fish_seen_subcommand_from list clean init doctor sync daemon monitor stats key explain config login logout completions help" -f -a "config" -d 'Edit or inspect configuration (opens the editor without a subcommand)'
complete -c kache -n "__fish_kache_using_subcommand help; and not __fish_seen_subcommand_from list clean init doctor sync daemon monitor stats key explain config login logout completions help" -f -a "login" -d 'Log in to the planner with your Kunobi account'
complete -c kache -n "__fish_kache_using_subcommand help; and not __fish_seen_subcommand_from list clean init doctor sync daemon monitor stats key explain config login logout completions help" -f -a "logout" -d 'Log out of the planner and revoke the stored Kunobi session'
complete -c kache -n "__fish_kache_using_subcommand help; and not __fish_seen_subcommand_from list clean init doctor sync daemon monitor stats key explain config login logout completions help" -f -a "completions" -d 'Generate shell completion scripts'
complete -c kache -n "__fish_kache_using_subcommand help; and not __fish_seen_subcommand_from list clean init doctor sync daemon monitor stats key explain config login logout completions help" -f -a "help" -d 'Print this message or the help of the given subcommand(s)'
complete -c kache -n "__fish_kache_using_subcommand help; and __fish_seen_subcommand_from daemon" -f -a "status" -d 'Show daemon status (also bare `kache daemon`)'
complete -c kache -n "__fish_kache_using_subcommand help; and __fish_seen_subcommand_from daemon" -f -a "run" -d 'Run the daemon server in the foreground'
complete -c kache -n "__fish_kache_using_subcommand help; and __fish_seen_subcommand_from daemon" -f -a "start" -d 'Start the daemon in the background and wait until it is ready'
complete -c kache -n "__fish_kache_using_subcommand help; and __fish_seen_subcommand_from daemon" -f -a "stop" -d 'Stop a running daemon'
complete -c kache -n "__fish_kache_using_subcommand help; and __fish_seen_subcommand_from daemon" -f -a "restart" -d 'Restart the daemon, through its login service when one is installed'
complete -c kache -n "__fish_kache_using_subcommand help; and __fish_seen_subcommand_from daemon" -f -a "install" -d 'Install the daemon as a per-user login service (launchd, systemd user unit, Task Scheduler)'
complete -c kache -n "__fish_kache_using_subcommand help; and __fish_seen_subcommand_from daemon" -f -a "uninstall" -d 'Remove the daemon service'
complete -c kache -n "__fish_kache_using_subcommand help; and __fish_seen_subcommand_from daemon" -f -a "log" -d 'Stream daemon logs'
complete -c kache -n "__fish_kache_using_subcommand help; and __fish_seen_subcommand_from key" -f -a "explain" -d 'Print the canonical key inputs of one rustc invocation as JSON. Does not run rustc'
complete -c kache -n "__fish_kache_using_subcommand help; and __fish_seen_subcommand_from key" -f -a "diff" -d 'Name the fields that differ between two key-input JSON documents'
complete -c kache -n "__fish_kache_using_subcommand help; and __fish_seen_subcommand_from config" -f -a "get" -d 'Read a value explicitly set in the selected file'
complete -c kache -n "__fish_kache_using_subcommand help; and __fish_seen_subcommand_from config" -f -a "list" -d 'List values explicitly set in the selected file'
complete -c kache -n "__fish_kache_using_subcommand help; and __fish_seen_subcommand_from config" -f -a "set" -d 'Set a known configuration key; accepts TOML values or an unquoted string'
complete -c kache -n "__fish_kache_using_subcommand help; and __fish_seen_subcommand_from config" -f -a "unset" -d 'Remove a value from the selected file'
complete -c kache -n "__fish_kache_using_subcommand help; and __fish_seen_subcommand_from config" -f -a "path" -d 'Print the selected file\'s path, even if it does not exist'
