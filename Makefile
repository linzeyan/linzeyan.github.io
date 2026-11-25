# Hugo and Dart Sass are pinned in mise.toml. Hugo runs through mise so that the
# pinned `sass` is on its PATH: toha compiles its Bootstrap stylesheet with it.
HUGO := mise exec -- hugo

run:
	@$(HUGO) mod npm pack
	@npm install
	@open http://localhost:1313
	@$(HUGO) server --disableFastRender --watch
.PHONY: run

# Build command for Cloudflare Pages, whose image has no mise: the same two
# versions are read out of mise.toml and fetched as release tarballs.
HUGO_VERSION = $(shell sed -n 's/^hugo-extended = "\(.*\)"$$/\1/p' mise.toml)
SASS_VERSION = $(shell sed -n 's/^"github:sass\/dart-sass" = .* version = "\([^"]*\)".*/\1/p' mise.toml)
cf:
	@wget https://github.com/gohugoio/hugo/releases/download/v$(HUGO_VERSION)/hugo_extended_$(HUGO_VERSION)_linux-amd64.tar.gz
	@tar xf hugo_extended_$(HUGO_VERSION)_linux-amd64.tar.gz
	@wget https://github.com/sass/dart-sass/releases/download/$(SASS_VERSION)/dart-sass-$(SASS_VERSION)-linux-x64.tar.gz
	@tar xf dart-sass-$(SASS_VERSION)-linux-x64.tar.gz
	@PATH="$$PWD/dart-sass:$$PATH" ./hugo --minify -b "$(CF_PAGES_URL)"
.PHONY: cf

clean:
	@rm -rf ./node_modules
	@rm -rf ./public
	@rm -rf ./resources
	@rm -rf ~/Library/Caches/hugo_cache
	@$(HUGO) mod clean
.PHONY: clean

# Tests read the built HTML, so build into a throwaway dir rather than public/,
# which a running `make run` server or a deploy may be using.
test:
	@out=$$(mktemp -d) && $(HUGO) --quiet -d "$$out" && SITE_OUT="$$out" node --test tests/*.test.mjs; code=$$?; rm -rf "$$out"; exit $$code
.PHONY: test

check: test
.PHONY: check
