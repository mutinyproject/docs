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
        edo cat "${source}" docinfo-footer.man | \
        edo asciidoctor ${DEBUG} \
            -B "${SRCDIR}" \
            -o "${dest}" \
            -b manpage \
            -a docinfo="shared" \
            -a manmanual="Mutiny manual" \
            /dev/stdin
    fi
done

