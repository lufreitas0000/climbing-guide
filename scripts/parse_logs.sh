#!/usr/bin/env bash
LOG_FILE=$1
BASENAME=$(basename "$LOG_FILE")
DEBUG_FILE="$(dirname "$LOG_FILE")/debug_test_${BASENAME}"

# Clear previous debug log
> "$DEBUG_FILE"

# Extract Fatal Errors
grep -iE "(! |Fatal error)" "$LOG_FILE" >> "$DEBUG_FILE"

# Extract Warnings
grep -iE "(Warning:)" "$LOG_FILE" >> "$DEBUG_FILE"

# Extract Overfull boxes exceeding 5.0pt tolerance
grep -oP "Overfull \\\\hbox \(\K[0-9.]+(?=pt too wide)" "$LOG_FILE" | awk '$1 > 5.0 {print "Overfull \\hbox: " $1 "pt"}' >> "$DEBUG_FILE"

# Check if debug log is empty
if [ -s "$DEBUG_FILE" ]; then
    echo "[FATAL] Errors/Warnings found. Check $DEBUG_FILE for concise details."
    exit 1
else
    echo "[OK] $LOG_FILE passed flawless audit."
    rm -f "$DEBUG_FILE"
    exit 0
fi
