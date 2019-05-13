export DEBUG ?= -v --failure-level=error

export SRCDIR = $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
export BUILDDIR ?= $(SRCDIR)/build

DOCS := $(shell cd $(SRCDIR) && find -name '*.adoc')
HTML := $(DOCS:.adoc=.html)

.PHONY: all man html deploy-html watch clean
all: html man

$(BUILDDIR)/html/%.html: %.adoc $(SRCDIR)/docinfo-footer.html
	@mkdir -p $(BUILDDIR)/html
	asciidoctor $(DEBUG) -B . -b html5 \
		-o "$@" \
		-a "docinfo=shared" \
		-a linkcss \
		-a nofooter \
		-a author \
		$(SRCDIR)/$*.adoc

man:
	@$(SRCDIR)/scripts/mkman.sh
	
html: $(foreach h,$(HTML),$(BUILDDIR)/html/$(h))

deploy-html: html
	rsync -uvr "$(BUILDDIR)"/html/ "$(DESTDIR)"
	ln -sf mutiny.7.html $(DESTDIR)/index.html

.ONESHELL:
watch: ; $(MAKE) -j1
	WATCH=true
	sh -c 'exit 2'
	while [ $$? -eq 2 ];do printf '%s\n' $(DOCS) | entr -dn $(MAKE);done

clean:
	rm -rf $(BUILDDIR)
