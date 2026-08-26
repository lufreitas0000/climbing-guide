.PHONY: all test production clean check-fonts test-lua audit-logs

TEX = lualatex
FLAGS = --interaction=nonstopmode --halt-on-error
export TEXINPUTS := $(abspath src)//:

all: test production

check-fonts test-lua:
	./scripts/check_fonts.sh

test: check-fonts test-lua
	$(TEX) $(FLAGS) --output-directory=tests tests/test_summary.tex
	./scripts/parse_logs.sh tests/test_summary.log

production: check-fonts test-lua
	$(TEX) $(FLAGS) --output-directory=production production/serra_do_cuo.tex
	$(TEX) $(FLAGS) --output-directory=production production/serra_do_cuo.tex
	./scripts/parse_logs.sh production/serra_do_cuo.log

clean:
	find tests production -type f \( -name "*.aux" -o -name "*.log" -o -name "*.out" -o -name "*.toc" -o -name "*.fls" -o -name "*.fmt" -o -name "*.fot" -o -name "*.cb" -o -name "*.cb2" -o -name "*.lb" -o -name "*.synctex.gz" \) -exec rm -f {} +

test-lua:
	lua tests/test_lua.lua
