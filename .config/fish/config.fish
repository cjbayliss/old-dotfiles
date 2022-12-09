if status is-interactive
    set fish_greeting

    # allow urls with '?' in them
    set -U fish_features qmark-noglob

    # colors
    set -U fish_color_autosuggestion      brblue
    set -U fish_color_cancel              -r
    set -U fish_color_command             'white' '--bold'
    set -U fish_color_comment             brblue
    set -U fish_color_cwd                 brgreen
    set -U fish_color_cwd_root            brred
    set -U fish_color_end                 brmagenta
    set -U fish_color_error               brred
    set -U fish_color_escape              brcyan
    set -U fish_color_history_current     --bold
    set -U fish_color_host                normal
    set -U fish_color_match               --background=brblue
    set -U fish_color_normal              normal
    set -U fish_color_operator            normal
    set -U fish_color_param               normal
    set -U fish_color_quote               bryellow
    set -U fish_color_redirection         bryellow
    set -U fish_color_search_match        'bryellow' '--background=brblack'
    set -U fish_color_selection           'white' '--bold' '--background=brblack'
    set -U fish_color_status              brred
    set -U fish_color_user                brgreen
    set -U fish_color_valid_path          --underline
    set -U fish_pager_color_completion    normal
    set -U fish_pager_color_description   bryellow
    set -U fish_pager_color_prefix        'white' '--bold' '--underline'
    set -U fish_pager_color_progress      '-r' 'white'

    # prompt
    function __git_branch
        git branch 2>/dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ \1/'
    end

    function __git_status
        if [ (git ls-files 2>/dev/null | wc -l) -lt 2000 ]
            git status --short 2>/dev/null | sed 's/^ //g' | cut -d' ' -f1 | sort -u | tr -d '\n' | sed 's/^/ /'
        else
            printf " [NOSTAT]"
        end
    end

    function fish_right_prompt
        set -l last_status $status
        if [ $last_status -ne 0 ]
            set_color --bold $fish_color_error
            printf '%s ' $last_status
            set_color normal
        end
    end

    function fish_prompt
        # host
        set_color normal
        printf '%s ' (prompt_hostname)

        # pwd
        set_color $fish_color_cwd
        echo -n (prompt_pwd)
        set_color normal

        # git stuff
        set_color brmagenta
        printf '%s' (__git_branch)
        set_color brred
        printf '%s ' (__git_status)
        set_color normal

        # prompt delimiter
        echo -n '» '
    end

    # aliases
    alias luafmt "stylua --config-path ~/.config/stylua/stylua.toml"
    alias podman-cleanup "podman image rm (podman image ls -f dangling=1 -q)"
    alias podman-cleanup-all "podman image rm (podman image ls -q)"

    set -Ux EDITOR "nvim"
    set -Ux VISUAL "$EDITOR"
    set -Ux MANPAGER "nvim +Man!"
    set -Ux MANWIDTH 72
    set -Ux PAGER "less --mouse --wheel-lines=3"
end
