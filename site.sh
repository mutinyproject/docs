#!/bin/sh

set -e

mkdir -p site

: "${MAKE:=make}"
: "${COMBINES:=
    https://git.mutiny.red/mutiny/idioms
    https://git.mutiny.red/mutiny/filesystem
    https://git.mutiny.red/mutiny/praxis
}"

for d in ${COMBINES}; do
    name="${d##*/}"; name="${name%%.git}"
    if [ -d site/"${name}" ]; then
        git -C site/"${name}" pull
    else
        git clone --depth=1 "${d}" site/"${name}"
    fi

    if ! [ -f site/"${name}"/config.mk ]; then
        touch site/"${name}"/config.mk
        [ -f ./config.mk ] && cat ./config.mk >> site/"${name}"/config.mk
        ln -sf ../config.mk site/"${name}"/config.mk
    fi
done

if ! [ -f site/config.mk ]; then
    while [ $# -gt 0 ]; do
        printf 'ASCIIDOCTOR_FLAGS += "%s"\n' "$1" >> site/config.mk
        shift
    done
fi

for d in .. ${COMBINES}; do
    name="${d##*/}"; name="${name%%.git}"
    ${MAKE} -C site/"${name}" html
done

for d in .. ${COMBINES}; do
    name="${d##*/}"; name="${name%%.git}"
    ${MAKE} -C site/"${name}" install-html DESTDIR="${PWD}"/site/generated htmldir=/
done

