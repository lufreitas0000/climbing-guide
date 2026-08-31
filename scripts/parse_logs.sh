#!/bin/bash
LOG_FILE=$1

# Catch critical engine failures and provide surrounding context
if grep -q "^!" "$LOG_FILE" || grep -q "Fatal error" "$LOG_FILE"; then
    echo "[FATAL] Engine failure detected in $LOG_FILE"
    echo "--- Error Context ---"
    grep -E -C 5 "^!|Fatal error" "$LOG_FILE"
    echo "---------------------"
    exit 1
fi

# Allow compilation but notify of visual overflows
if grep -q -i "overfull" "$LOG_FILE"; then
    echo "[WARNING] Expected Overfull boxes detected; bypassing strict failure."
fi

exit 0
