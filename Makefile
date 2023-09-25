# Makefile for compiling slides with Pandoc

# Get all new markdown files
SOURCE := $(wildcard *.md)

PANDOC_OPTS = -s \
			  -t revealjs \
			  --template=./templates/revealjs.md \
			  -L ./filters/revealjs-code.lua \
			  -L ./filters/inline_svg.lua \
			  -L ./filters/tikz.lua \
			  --mathjax=./js/revealjs/plugin/math/katex.js

REVEAL_OPTS = -V revealjs-url=./js/revealjs \
			  -V highlightjs \
			  -V center=false

# Pattern match to run if html is desired
%.html: %.md
	@pandoc $(PANDOC_OPTS) $(REVEAL_OPTS) $< -o $@
	@echo Compiling $<

# Default rule (convert all markdown to html)
default: $(SOURCE:.md=.html)

clean: 
	@rm *.html
	@echo All html files purged
