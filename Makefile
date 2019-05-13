export DEBUG ?= -v --failure-level=error

export SRCDIR = $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
export BUILDDIR := $(SRCDIR)/build
export IMAGE ?= $(SRCDIR)/image

DOCS := $(shell find $(SRCDIR)/././ -type f -a \( -name '*.adoc' \) -a \! \( -path '$(SRCDIR)/././build/*' -o -path '$(SRCDIR)/././image/*' \))
DOCS := $(subst $(SRCDIR)/././,,$(DOCS))
HTML := $(DOCS:.adoc=.html)
AUX  := $(shell find $(SRCDIR)/././ -type f -a \( -name '*.svg' \) -a \! \( -path '$(SRCDIR)/././build/*' -o -path '$(SRCDIR)/././image/*' \))
AUX  := $(subst $(SRCDIR)/././,,$(AUX))

.PHONY: all man html deploy-html watch clean
all: html man aux

$(BUILDDIR)/html/%.html: $(SRCDIR)/%.adoc $(SRCDIR)/docinfo-footer.html
	@mkdir -p $(BUILDDIR)/html
	asciidoctor $(DEBUG) -B . -b html5 \
		-o "$@" \
		-a "docinfo=shared" \
		-a linkcss \
		-a nofooter \
		-a author \
		$(SRCDIR)/$*.adoc

$(BUILDDIR)/aux/%: $(SRCDIR)/%
	@mkdir -p $(BUILDDIR)/aux/$(dir $*)
	cp -f $(SRCDIR)/$* $(BUILDDIR)/aux/$*

man:
	@$(SRCDIR)/scripts/mkman.sh
	
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
