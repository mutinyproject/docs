export DEBUG ?= -v --failure-level=error

export SRCDIR = $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
export BUILDDIR := $(SRCDIR)/build
export IMAGE ?= $(SRCDIR)/image

DOCS := $(shell find $(SRCDIR)/././ -type f -a \( -name '*.adoc' \) -a \! \( -path '$(SRCDIR)/././build/*' -o -path '$(SRCDIR)/././image/*' \))
DOCS := $(subst $(SRCDIR)/././,,$(DOCS))

MAN := $(shell printf '%s\n' $(DOCS) | grep '[0-9]\.adoc$\')
MAN := $(subst $(SRCDIR)/././,,$(MAN))
MAN := $(MAN:.adoc=.man)

HTML := $(DOCS:.adoc=.html)

AUX  := $(shell find $(SRCDIR)/././ -type f -a \( -name '*.svg' \) -a \! \( -path '$(SRCDIR)/././build/*' -o -path '$(SRCDIR)/././image/*' \))
AUX  := $(subst $(SRCDIR)/././,,$(AUX))

.PHONY: all man html deploy-html watch clean
all: html man aux

$(BUILDDIR)/man/%.man: $(SRCDIR)/%.adoc $(SRCDIR)/docinfo-footer.man
	@mkdir -p $(BUILDDIR)/man
	asciidoctor $(DEBUG) \
		-B $(BUILDDIR) \
		-b manpage \
		-a docinfo=shared \
		-a docinfodir=$(SRCDIR) \
		-a manmanual="Mutiny manual" \
		-o $@ \
		$(SRCDIR)/$*.adoc || rm -f $@

$(BUILDDIR)/html/%.html: $(SRCDIR)/%.adoc $(SRCDIR)/docinfo-footer.html
	@mkdir -p $(BUILDDIR)/html
	asciidoctor $(DEBUG) \
		-B $(BUILDDIR) \
		-b html5 \
		-a docinfo=shared \
		-a linkcss \
		-o "$@" \
		$(SRCDIR)/$*.adoc

$(BUILDDIR)/aux/%: $(SRCDIR)/%
	@mkdir -p $(BUILDDIR)/aux/$(dir $*)
	cp -f $(SRCDIR)/$* $(BUILDDIR)/aux/$*

man: $(foreach m,$(MAN),$(BUILDDIR)/man/$(m))
html: $(foreach h,$(HTML),$(BUILDDIR)/html/$(h))
aux: $(foreach a,$(AUX),$(BUILDDIR)/aux/$(a))

deploy: html aux
	rsync -vr "$(BUILDDIR)"/html/ "$(BUILDDIR)"/aux/ "$(IMAGE)"/
	ln -sf mutiny.7.html $(IMAGE)/index.html

watch: ; $(MAKE) -j1
	WATCH=true; \
	cd $(SRCDIR); \
	sh -c 'exit 2'; \
	while [ $$? -eq 2 ];do printf '%s\n' Makefile $(DOCS) $(AUX) | entr -dn $(MAKE) --no-print-directory;done

watch-deploy: ; $(MAKE) -j1
	WATCH=true; \
	cd $(SRCDIR); \
	sh -c 'exit 2'; \
	while [ $$? -eq 2 ];do printf '%s\n' Makefile $(DOCS) $(AUX) | entr -dn $(MAKE) all deploy --no-print-directory;done

clean:
	rm -rf $(BUILDDIR) $(IMAGE)
