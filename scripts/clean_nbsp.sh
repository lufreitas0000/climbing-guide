#!/bin/sh
# Finds and replaces all UTF-8 non-breaking spaces (\xC2\xA0) with standard spaces.
# Uses perl to guarantee cross-platform (Linux/macOS) byte replacement.

find . -type f \( -name "*.tex" -o -name "*.lua" -o -name "*.sty" \) -exec perl -pi -e 's/\xC2\xA0/ /g' {} +
