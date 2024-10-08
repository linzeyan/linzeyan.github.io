run:
	@hugo mod npm pack
	@npm install
	@open http://localhost:1313
	@hugo server --disableFastRender --watch
.PHONY: run

cf:
	@wget https://github.com/gohugoio/hugo/releases/download/v0.131.0/hugo_extended_0.131.0_linux-amd64.tar.gz
	@tar xf hugo_extended_0.131.0_linux-amd64.tar.gz
	@./hugo --minify -b $CF_PAGES_URL
.PHONY: cf