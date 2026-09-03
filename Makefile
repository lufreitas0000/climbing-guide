.PHONY: all test production clean check-fonts test-lua test-fonts test-summary test-suite test-visual test-miniguide test-images test-zone-stats test-qr init-dirs docs

TEX = lualatex
FLAGS = --interaction=batchmode --halt-on-error
export TEXINPUTS := $(abspath src)//:$(abspath doc)//:
export LUAINPUTS := $(abspath src)//:

all: test docs

init-dirs:
	@mkdir -p tests/tests_export production/production_exports doc/doc_export doc/doc_tex

check-fonts:
	@echo "Auditing system fonts..."
	@./scripts/check_fonts.sh

test-lua:
	@echo "Executing Lua mathematical logic..."
	@lua tests/test_lua.lua
	@lua tests/test_sanitizer.lua

test-fonts: init-dirs check-fonts
	@echo "Compiling test_fonts.tex..."
	@$(TEX) $(FLAGS) --output-directory=tests/tests_export tests/test_fonts.tex

test-summary: init-dirs check-fonts
	@echo "Compiling test_summary.tex..."
	@$(TEX) $(FLAGS) --output-directory=tests/tests_export tests/test_summary.tex
	@$(TEX) $(FLAGS) --output-directory=tests/tests_export tests/test_summary.tex

test-miniguide: init-dirs check-fonts
	@echo "Compiling test_miniguide.tex..."
	@$(TEX) $(FLAGS) --output-directory=tests/tests_export tests/test_miniguide.tex
	@$(TEX) $(FLAGS) --output-directory=tests/tests_export tests/test_miniguide.tex

test-images: init-dirs check-fonts
	@echo "Compiling test_images.tex..."
	@$(TEX) $(FLAGS) --output-directory=tests/tests_export tests/test_images.tex
	@$(TEX) $(FLAGS) --output-directory=tests/tests_export tests/test_images.tex

test-zone-stats: init-dirs check-fonts
	@echo "Compiling test_zone_stats.tex..."
	@$(TEX) $(FLAGS) --output-directory=tests/tests_export tests/test_zone_stats.tex
	@$(TEX) $(FLAGS) --output-directory=tests/tests_export tests/test_zone_stats.tex

test-qr: init-dirs check-fonts test-lua
	@echo "Compiling test_qr.tex (Pass 1 - Manifest Generation)..."
	@$(TEX) $(FLAGS) --output-directory=tests/tests_export tests/test_qr.tex
	@echo "Generating QR Codes (Test)..."
	@scripts/python/.venv/bin/python scripts/python/generate_qrcodes.py --manifest export/qrcodes_manifest.json --outdir tests/tests_assets/tests_qrcodes
	@echo "Compiling test_qr.tex (Pass 2 - PNG Injection)..."
	@$(TEX) $(FLAGS) --output-directory=tests/tests_export tests/test_qr.tex
	@echo "Compiling test_qr.tex (Pass 3 - TikZ Positioning)..."
	@$(TEX) $(FLAGS) --output-directory=tests/tests_export tests/test_qr.tex

test: test-lua test-fonts test-summary test-suite test-visual test-miniguide test-images test-zone-stats test-qr

production: init-dirs check-fonts test-lua
	@echo "Clearing .cgstats cache..."
	@rm -f production/production_exports/*.cgstats tests/tests_export/*.cgstats *.cgstats
	@echo "Compiling serra_do_cuo.tex (Pass 1 - Data Extraction)..."
	@$(TEX) $(FLAGS) --output-directory=production/production_exports production/serra_do_cuo.tex
	@mv *.cgstats production/production_exports/ 2>/dev/null || true
	@echo "Generating QR Codes (Production)..."
	@scripts/python/.venv/bin/python scripts/python/generate_qrcodes.py --manifest export/qrcodes_manifest.json --outdir production/production_assets/production_qrcodes
	@echo "Compiling serra_do_cuo.tex (Pass 2 - Layout Anchor Resolution)..."
	@$(TEX) $(FLAGS) --output-directory=production/production_exports production/serra_do_cuo.tex
	@echo "Compiling serra_do_cuo.tex (Pass 3 - Final TikZ Positioning)..."
	@$(TEX) $(FLAGS) --output-directory=production/production_exports production/serra_do_cuo.tex

clean:
	@echo "Cleaning auxiliary build artifacts..."
	@rm -rf production/production_exports/* tests/tests_export/* doc/doc_export/* *.cgstats
	@rm -rf export/ tests/aux/ tests/log/ tests/pdf/ production/aux/ production/log/ production/pdf/

docs: init-dirs check-fonts
	@echo "Compiling doc/cg-documentation.tex..."
	@$(TEX) $(FLAGS) --output-directory=doc/doc_export doc/cg-documentation.tex
	@$(TEX) $(FLAGS) --output-directory=doc/doc_export doc/cg-documentation.tex

compress:
	@echo "Compressing PDF (sRGB, 300 DPI)..."
	gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/printer \
	-dNOPAUSE -dBATCH -dQUIET \
	-dProcessColorModel=/DeviceRGB -dColorConversionStrategy=/sRGB \
	-sOutputFile=production/production_exports/serra_do_cuo_optimized.pdf production/production_exports/serra_do_cuo.pdf
	@echo "Compression complete!"
