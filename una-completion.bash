#/usr/bin/env bash

set +e

_completions() {
    SUGGESTIONS=()

    if [[ "$COMP_CWORD" == 1 ]]; then
        SUGGESTIONS=('install' 'upgrade' 'remove' \
          'update' 'help' 'list' 'info' 'search' )
    elif [[ "$COMP_CWORD" == 2 ]] && [[ "${COMP_WORDS[1]}" == remove ]]; then
        for pkg in $(dpkg-query --show --showformat '${Package} '); do
            SUGGESTIONS+=("${pkg}")
        done
    elif [[ "$COMP_CWORD" == 2 ]] && ( [[ "${COMP_WORDS[1]}" == install ]] \
      || [[ "${COMP_WORDS[1]}" == search ]] || [[ "${COMP_WORDS[1]}" == info ]] ); then
        for pkg in $(cat /var/lib/una/cache | jq -r '.[].Name' | grep "^${COMP_WORDS[$COMP_CWORD]}" || true) $(apt-cache search --names-only "^${COMP_WORDS[$COMP_CWORD]}" | sort -d | awk '{print $1}' || true); do
            SUGGESTIONS+=("${pkg}")
        done
    fi

    COMPREPLY=($(compgen -W "${SUGGESTIONS[*]}" "${COMP_WORDS[$COMP_CWORD]}"))
}

complete -F _completions -- una