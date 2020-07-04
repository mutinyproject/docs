#!/bin/sh

set -x

rm -rf site
mkdir -p site

COMBINES="idioms filesystem praxis"

while [ $# -gt 0 ]; do
    printf 'ASCIIDOCTOR_FLAGS += "%s"\n' "$1" >> site/config.mk
    shift
done

for d in ${COMBINES}; do
    git clone --depth=1 https://git.mutiny.red/mutiny/"${d}" site/"${d}"
    touch site/"${d}"/config.mk
    [ -f ./config.mk ] && cat ./config.mk > site/"${d}"/config.mk
    ln -sf ../config.mk site/"${d}"/config.mk
done

make ${MAKEFLAGS} clean

for d in ${COMBINES}; do
    make ${MAKEFLAGS} -C site/"${d}" html
done

for d in ../ ${COMBINES}; do
    make ${MAKEFLAGS} -C site/"${d}" install-html DESTDIR="${PWD}"/site/generated htmldir=/
done

