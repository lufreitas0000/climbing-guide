.PHONY: all test production clean check-fonts test-lua audit-logs

TEX = lualatex
FLAGS = --interaction=nonstopmode --halt-on-error
export TEXINPUTS := $(abspath src)//:

all: test production

check-fonts:
	@echo "Auditing system fonts..."
	@./scripts/check_fonts.sh

test-lua:
	@echo "Executing Lua mathematical logic..."
	@lua tests/test_lua.lua

test: check-fonts test-lua
	@echo "Compiling test_fonts.tex..."
	@$(TEX) $(FLAGS) --output-directory=tests tests/test_fonts.tex > /dev/null
	@./scripts/parse_logs.sh tests/test_fonts.log
	
	@echo "Compiling test_summary.tex..."
	@$(TEX) $(FLAGS) --output-directory=tests tests/test_summary.tex > /dev/null
	@./scripts/parse_logs.sh tests/test_summary.log
	
	@echo "Compiling test_suite.tex..."
	@$(TEX) $(FLAGS) --output-directory=tests tests/test_suite.tex > /dev/null
	@$(TEX) $(FLAGS) --output-directory=tests tests/test_suite.tex > /dev/null
	@./scripts/parse_logs.sh tests/test_suite.log
	
	@echo "Compiling test_visual.tex..."
	@$(TEX) $(FLAGS) --output-directory=tests tests/test_visual.tex > /dev/null
	@$(TEX) $(FLAGS) --output-directory=tests tests/test_visual.tex > /dev/null
	@./scripts/parse_logs.sh tests/test_visual.log
	@echo "Compiling test_miniguide.tex..."
	@$(TEX) $(FLAGS) --output-directory=tests tests/test_miniguide.tex > /dev/null
	@$(TEX) $(FLAGS) --output-directory=tests tests/test_miniguide.tex > /dev/null
	@./scripts/parse_logs.sh tests/test_miniguide.log


production: check-fonts test-lua
	@echo "Compiling serra_do_cuo.tex..."
	@$(TEX) $(FLAGS) --output-directory=production production/serra_do_cuo.tex > /dev/null
	@$(TEX) $(FLAGS) --output-directory=production production/serra_do_cuo.tex > /dev/null
	@./scripts/parse_logs.sh production/serra_do_cuo.log

clean:
	@find tests production -type f \( -name "*.aux" -o -name "*.log" -o -name "*.out" -o -name "*.toc" -o -name "*.fls" -o -name "*.fmt" -o -name "*.fot" -o -name "*.cb" -o -name "*.cb2" -o -name "*.lb" -o -name "*.synctex.gz" \) -exec rm -f {} +
	@echo "Cleaned build artifacts."
