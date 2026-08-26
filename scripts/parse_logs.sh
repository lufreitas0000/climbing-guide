#!/usr/bin/env bash
LOG_FILE=$1

if grep -iE "(!|Fatal error|Overfull \\\hbox|Underfull \\\hbox|Warning)" "$LOG_FILE"; then
    echo "[FATAL] Typesetting errors or warnings detected in $LOG_FILE. Halting."
    exit 1
fi
echo "[OK] $LOG_FILE passed strict audit."
exit 0
