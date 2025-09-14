#!/bin/bash

# Enhanced Date Validation Script
# This script validates that "Last Updated" dates match actual file modification dates

set -e

# Performance tracking and logging
start_time=$(date +%s)
VALIDATION_LOG="/tmp/date_validation_$(date +%Y%m%d_%H%M%S).log"

echo "📅 Enhanced Date Validation" | tee "$VALIDATION_LOG"
echo "==========================" | tee -a "$VALIDATION_LOG"
echo "" | tee -a "$VALIDATION_LOG"

ERRORS=0
WARNINGS=0
TOTAL_FILES=0
CHECKED_FILES=0

# Function to extract date from file
extract_date_from_file() {
    local file="$1"
    local date_value=""
    
    # Try different date patterns
    if grep -q "\*\*Last Updated\*\*:" "$file" 2>/dev/null; then
        date_value=$(grep "\*\*Last Updated\*\*:" "$file" | tail -1 | sed 's/.*\*\*Last Updated\*\*: *//' | sed 's/ *$//' | tr -d '\n')
    elif grep -q "\*Last Updated\*:" "$file" 2>/dev/null; then
        date_value=$(grep "\*Last Updated:" "$file" | tail -1 | sed 's/.*\*Last Updated: *//' | sed 's/\*.*$//' | tr -d '\n')
    elif grep -q "Last Updated:" "$file" 2>/dev/null; then
        date_value=$(grep "Last Updated:" "$file" | tail -1 | sed 's/.*Last Updated: *//' | sed 's/ *$//' | tr -d '\n')
    fi
    
    echo "$date_value"
}

# Function to get file modification date in different formats
get_file_mod_date() {
    local file="$1"
    local format="$2"
    
    case "$format" in
        "precise")
            # Format: 2025-09-14 @ 12:05
            stat -c %y "$file" | cut -d. -f1 | sed 's/\([0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\}\) \([0-9]\{2\}:[0-9]\{2\}\).*/\1 @ \2/'
            ;;
        "month_year")
            # Format: 14 September 25 @ 13:41
            local file_date=$(stat -c %y "$file" | cut -d' ' -f1)
            date -d "$file_date" "+%B %Y"
            ;;
        "iso_date")
            # Format: 2025-09-14
            stat -c %y "$file" | cut -d' ' -f1
            ;;
    esac
}

# Function to determine date format from content
determine_date_format() {
    local date_str="$1"
    
    if [[ "$date_str" =~ [0-9]{4}-[0-9]{2}-[0-9]{2}\ @\ [0-9]{2}:[0-9]{2} ]]; then
        echo "precise"
    elif [[ "$date_str" =~ ^[A-Z][a-z]+\ [0-9]{4}$ ]]; then
        echo "month_year"
    elif [[ "$date_str" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        echo "iso_date"
    else
        echo "unknown"
    fi
}

# Function to validate date in file
validate_date_in_file() {
    local file="$1"
    local current_date=""
    local expected_date=""
    local date_format=""
    
    TOTAL_FILES=$((TOTAL_FILES + 1))
    
    current_date=$(extract_date_from_file "$file")
    
    if [[ -z "$current_date" ]]; then
        return 0  # No date to validate
    fi
    
    CHECKED_FILES=$((CHECKED_FILES + 1))
    
    date_format=$(determine_date_format "$current_date")
    expected_date=$(get_file_mod_date "$file" "$date_format")
    
    if [[ "$date_format" == "unknown" ]]; then
        echo "⚠️  Unknown date format in $file: '$current_date'" | tee -a "$VALIDATION_LOG"
        WARNINGS=$((WARNINGS + 1))
    elif [[ "$current_date" == "$expected_date" ]]; then
        echo "✅ $file: $current_date" | tee -a "$VALIDATION_LOG"
    else
        echo "❌ $file: '$current_date' (expected: '$expected_date')" | tee -a "$VALIDATION_LOG"
        ERRORS=$((ERRORS + 1))
    fi
}

# Validate all markdown files with dates
echo "🔍 Scanning for files with 'Last Updated' dates..." | tee -a "$VALIDATION_LOG"
echo "" | tee -a "$VALIDATION_LOG"

while IFS= read -r -d '' md_file; do
    if [[ "$md_file" != *"node_modules"* ]] && [[ "$md_file" != *"/.git/"* ]]; then
        validate_date_in_file "$md_file"
    fi
done < <(find . -name "*.md" -type f -print0)

# Final summary
end_time=$(date +%s)
duration=$((end_time - start_time))

echo "" | tee -a "$VALIDATION_LOG"
echo "📊 Date Validation Summary:" | tee -a "$VALIDATION_LOG"
echo "   Total files scanned: $TOTAL_FILES" | tee -a "$VALIDATION_LOG"
echo "   Files with dates checked: $CHECKED_FILES" | tee -a "$VALIDATION_LOG"
echo "   Date errors found: $ERRORS" | tee -a "$VALIDATION_LOG"
echo "   Warnings: $WARNINGS" | tee -a "$VALIDATION_LOG"
echo "   Duration: ${duration}s" | tee -a "$VALIDATION_LOG"
echo "" | tee -a "$VALIDATION_LOG"

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo "🎉 All dates are perfectly synchronized!" | tee -a "$VALIDATION_LOG"
    exit 0
elif [ $ERRORS -eq 0 ]; then
    echo "⚠️  All dates are correct, but found $WARNINGS warnings" | tee -a "$VALIDATION_LOG"
    echo "🔧 Consider reviewing warnings above" | tee -a "$VALIDATION_LOG"
    exit 0
else
    echo "💥 Found $ERRORS date mismatches and $WARNINGS warnings!" | tee -a "$VALIDATION_LOG"
    echo "🔧 Run './scripts/sync-dates.sh' to fix inconsistencies" | tee -a "$VALIDATION_LOG"
    echo "📝 Full log saved to: $VALIDATION_LOG" | tee -a "$VALIDATION_LOG"
    exit 1
fi