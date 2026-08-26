#!/usr/bin/env bash
LOG_FILE=$1

# 1. Hard fail on Fatal Errors
if grep -iE "(! |Fatal error)" "$LOG_FILE"; then
    echo "[FATAL] Typesetting errors detected in $LOG_FILE. Halting."
    exit 1
fi

# 2. Tolerance checking for Overfull \hbox (> 5.0pt)
OVERFULL_FAILS=$(grep -oP "Overfull \\\\hbox \(\K[0-9.]+(?=pt too wide)" "$LOG_FILE" | awk '$1 > 5.0 {print $1}')
if [ -n "$OVERFULL_FAILS" ]; then
    echo "[FATAL] Overfull \hbox exceeding 5.0pt tolerance detected in $LOG_FILE. Halting."
    echo "Failing values: $OVERFULL_FAILS"
    exit 1
fi

echo "[OK] $LOG_FILE passed strict audit."
exit 0
