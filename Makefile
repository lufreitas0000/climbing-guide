.PHONY: all test production clean

TEX = lualatex
FLAGS = --interaction=nonstopmode --halt-on-error
export TEXINPUTS := $(abspath src)//:

all: test production

test:
	$(TEX) $(FLAGS) --output-directory=tests tests/test_suite.tex
	$(TEX) $(FLAGS) --output-directory=tests tests/test_suite.tex

production:
	$(TEX) $(FLAGS) --output-directory=production production/serra_do_cuo.tex
	$(TEX) $(FLAGS) --output-directory=production production/serra_do_cuo.tex

clean:
	find tests production -type f \( -name "*.aux" -o -name "*.log" -o -name "*.out" -o -name "*.toc" -o -name "*.fls" -o -name "*.fmt" -o -name "*.fot" -o -name "*.cb" -o -name "*.cb2" -o -name "*.lb" -o -name "*.synctex.gz" \) -exec rm -f {} +
