#!/bin/sh

edo() { printf '%s\n' "$*" >&2; "$@"; }

cd "${SRCDIR}"
find -type f -name '*.adoc' | sed -E '/[0-9].adoc$/!d; s:^\./::;s:\.adoc::' | \
    while read -r source;do
    dest=$(printf '%s' ${source} | tr '/' '-')
    source="${source}".adoc
    section="${dest##*.}"
    dest="${BUILDDIR}"/man/man${section}/"${dest}"
    [ -d "${dest%/*}" ] || edo mkdir -p "${dest%/*}"
    if [ "${source}" -nt "${dest}" ];then
        edo asciidoctor ${DEBUG} -o "${dest}" -b manpage -a manmanual="Mutiny manual" "${source}"
    fi
done

