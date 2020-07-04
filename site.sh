#!/bin/sh

set -ex

rm -rf site
mkdir -p site

: "${COMBINES:=
    https://git.mutiny.red/mutiny/idioms
    https://git.mutiny.red/mutiny/filesystem
    https://git.mutiny.red/mutiny/praxis
}"

while [ $# -gt 0 ]; do
    printf 'ASCIIDOCTOR_FLAGS += "%s"\n' "$1" >> site/config.mk
    shift
done

for d in ${COMBINES}; do
    name="${d##*/}"; name="${d%%.git}"
    git clone --depth=1 "${d}" site/"${name}"
    touch site/"${name}"/config.mk
    [ -f ./config.mk ] && cat ./config.mk > site/"${name}"/config.mk
    ln -sf ../config.mk site/"${name}"/config.mk
done

make clean

for d in ${COMBINES}; do
    name="${d##*/}"; name="${d%%.git}"
    make -C site/"${name}" html
done

for d in .. ${COMBINES}; do
    name="${d##*/}"; name="${d%%.git}"
    make -C site/"${name}" install-html DESTDIR="${PWD}"/site/generated htmldir=/
done

