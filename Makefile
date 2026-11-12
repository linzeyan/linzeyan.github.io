run:
	@hugo mod npm pack
	@npm install
	@open http://localhost:1313
	@hugo server --disableFastRender --watch
.PHONY: run

cf:
	@wget https://github.com/gohugoio/hugo/releases/download/v0.169.0/hugo_extended_0.169.0_linux-amd64.tar.gz
	@tar xf hugo_extended_0.169.0_linux-amd64.tar.gz
	@./hugo --minify -b "$(CF_PAGES_URL)"
.PHONY: cf

clean:
	@rm -rf ./node_modules
	@rm -rf ./public
	@rm -rf ./resources
	@rm -rf ~/Library/Caches/hugo_cache
	@hugo mod clean
.PHONY: clean

# Tests read the built HTML, so build into a throwaway dir rather than public/,
# which a running `make run` server or a deploy may be using.
test:
	@out=$$(mktemp -d) && hugo --quiet -d "$$out" && SITE_OUT="$$out" node --test tests/*.test.mjs; code=$$?; rm -rf "$$out"; exit $$code
.PHONY: test

check: test
.PHONY: check
