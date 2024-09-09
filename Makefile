run:
	@hugo mod npm pack
	@npm install
	@open http://localhost:1313
	@hugo server --disableFastRender --watch
.PHONY: run