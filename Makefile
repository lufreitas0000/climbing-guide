.PHONY: all test production clean check-fonts test-lua test-fonts test-summary test-suite test-visual test-miniguide init-dirs docs

TEX = lualatex
FLAGS = --interaction=nonstopmode --halt-on-error
export TEXINPUTS := $(abspath src)//:$(abspath doc)//:
export LUAINPUTS := $(abspath src)//:

all: test docs

init-dirs:
	@mkdir -p tests/aux tests/pdf tests/log production/aux production/pdf production/log export doc/export doc/tex

check-fonts:
	@echo "Auditing system fonts..."
	@./scripts/check_fonts.sh

test-lua:
	@echo "Executing Lua mathematical logic..."
	@lua tests/test_lua.lua

test-fonts: init-dirs check-fonts
	@echo "Compiling test_fonts.tex..."
	@$(TEX) $(FLAGS) --output-directory=tests/aux tests/test_fonts.tex > /dev/null
	@mv tests/aux/test_fonts.pdf tests/pdf/
	@mv tests/aux/test_fonts.log tests/log/
	@./scripts/parse_logs.sh tests/log/test_fonts.log

test-summary: init-dirs check-fonts
	@echo "Compiling test_summary.tex..."
	@$(TEX) $(FLAGS) --output-directory=tests/aux tests/test_summary.tex > /dev/null
	@$(TEX) $(FLAGS) --output-directory=tests/aux tests/test_summary.tex > /dev/null
	@mv tests/aux/test_summary.pdf tests/pdf/
	@mv tests/aux/test_summary.log tests/log/
	@./scripts/parse_logs.sh tests/log/test_summary.log

test-suite: init-dirs check-fonts
	@echo "Compiling test_suite.tex..."
	@$(TEX) $(FLAGS) --output-directory=tests/aux tests/test_suite.tex > /dev/null
	@$(TEX) $(FLAGS) --output-directory=tests/aux tests/test_suite.tex > /dev/null
	@mv tests/aux/test_suite.pdf tests/pdf/
	@mv tests/aux/test_suite.log tests/log/
	@./scripts/parse_logs.sh tests/log/test_suite.log
	@./scripts/validate_exports.sh

test-visual: init-dirs check-fonts
	@echo "Compiling test_visual.tex..."
	@$(TEX) $(FLAGS) --output-directory=tests/aux tests/test_visual.tex > /dev/null
	@$(TEX) $(FLAGS) --output-directory=tests/aux tests/test_visual.tex > /dev/null
	@mv tests/aux/test_visual.pdf tests/pdf/
	@mv tests/aux/test_visual.log tests/log/
	@./scripts/parse_logs.sh tests/log/test_visual.log

test-miniguide: init-dirs check-fonts
	@echo "Compiling test_miniguide.tex..."
	@$(TEX) $(FLAGS) --output-directory=tests/aux tests/test_miniguide.tex > /dev/null
	@$(TEX) $(FLAGS) --output-directory=tests/aux tests/test_miniguide.tex > /dev/null
	@mv tests/aux/test_miniguide.pdf tests/pdf/
	@mv tests/aux/test_miniguide.log tests/log/
	@./scripts/parse_logs.sh tests/log/test_miniguide.log

test: test-lua test-fonts test-summary test-suite test-visual test-miniguide

production: init-dirs check-fonts test-lua
	@echo "Compiling serra_do_cuo.tex..."
	@$(TEX) $(FLAGS) --output-directory=production/aux production/serra_do_cuo.tex > /dev/null
	@$(TEX) $(FLAGS) --output-directory=production/aux production/serra_do_cuo.tex > /dev/null
	@mv production/aux/serra_do_cuo.pdf production/pdf/
	@mv production/aux/serra_do_cuo.log production/log/
	@./scripts/parse_logs.sh production/log/serra_do_cuo.log

clean:
	@echo "Cleaning auxiliary build artifacts..."
	@rm -rf production/aux/* doc/export/*

docs: init-dirs check-fonts
	@echo "Compiling doc/cg-documentation.tex..."
	@$(TEX) $(FLAGS) --output-directory=doc/export doc/cg-documentation.tex > /dev/null
	@$(TEX) $(FLAGS) --output-directory=doc/export doc/cg-documentation.tex > /dev/null
	@./scripts/parse_logs.sh doc/export/cg-documentation.log
