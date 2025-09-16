#!/bin/bash

# Date Format Conversion Script
# Converts all "Last Updated" dates to standardized "dd mmmm yyyy" format

set -e

# Performance and logging
start_time=$(date +%s)
CONVERT_LOG="/tmp/date_convert_$(date +%Y%m%d_%H%M%S).log"

echo "📅 Date Format Conversion to 'dd mmmm yyyy'" | tee "$CONVERT_LOG"
echo "===========================================" | tee -a "$CONVERT_LOG"
echo "" | tee -a "$CONVERT_LOG"

CONVERTED_FILES=0
SKIPPED_FILES=0
ERROR_FILES=0

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

# Function to convert any date to standardized format
convert_to_standard_format() {
    local date_str="$1"
    local standard_date=""
    
    # Already in dd mmmm yyyy format
    if [[ "$date_str" =~ ^[0-9]{1,2}\ [A-Z][a-z]+\ [0-9]{4}$ ]]; then
        echo "$date_str"
        return 0
    fi
    
    # From dd mmmm yyyy @ hh:mm format - remove time
    if [[ "$date_str" =~ ^[0-9]{1,2}\ [A-Z][a-z]+\ [0-9]{4}\ @\ [0-9]{2}:[0-9]{2}$ ]]; then
        echo "$date_str" | sed 's/ @ [0-9][0-9]:[0-9][0-9]$//'
        return 0
    fi
    
    # From ISO format yyyy-mm-dd @ hh:mm
    if [[ "$date_str" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}\ @\ [0-9]{2}:[0-9]{2}$ ]]; then
        local iso_date=$(echo "$date_str" | cut -d' ' -f1)
        date -d "$iso_date" "+%d %B %Y"
        return 0
    fi
    
    # From ISO format yyyy-mm-dd
    if [[ "$date_str" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
        date -d "$date_str" "+%d %B %Y"
        return 0
    fi
    
    # From month year format
    if [[ "$date_str" =~ ^[A-Z][a-z]+\ [0-9]{4}$ ]]; then
        # Can't be precise, use current day
        local month_year="$date_str"
        local current_day=$(date +%d)
        echo "$current_day $month_year"
        return 0
    fi
    
    # Unknown format - return as is
    echo "$date_str"
    return 1
}

# Function to convert date in file
convert_date_in_file() {
    local file="$1"
    local backup_file="${file}.convert_backup"
    local current_date=""
    local new_date=""
    
    current_date=$(extract_date_from_file "$file")
    
    if [[ -z "$current_date" ]]; then
        return 0  # No date to convert
    fi
    
    # Create backup
    cp "$file" "$backup_file"
    
    new_date=$(convert_to_standard_format "$current_date")
    if [ $? -ne 0 ]; then
        echo "⚠️  Could not convert unknown format in $file: '$current_date'" | tee -a "$CONVERT_LOG"
        rm "$backup_file"
        SKIPPED_FILES=$((SKIPPED_FILES + 1))
        return 0
    fi
    
    # Skip if already in correct format
    if [[ "$current_date" == "$new_date" ]]; then
        echo "✅ Already correct format in $file: '$current_date'" | tee -a "$CONVERT_LOG"
        rm "$backup_file"
        SKIPPED_FILES=$((SKIPPED_FILES + 1))
        return 0
    fi
    
    # Update the date based on the pattern found
    if grep -q "\*\*Last Updated\*\*:" "$file" 2>/dev/null; then
        sed -i "s/\*\*Last Updated\*\*: [^*]*/\*\*Last Updated\*\*: $new_date/" "$file"
    elif grep -q "\*Last Updated\*:" "$file" 2>/dev/null; then
        sed -i "s/\*Last Updated: [^*]*/\*Last Updated: $new_date\*/" "$file"
    elif grep -q "Last Updated:" "$file" 2>/dev/null; then
        sed -i "s/Last Updated: .*/Last Updated: $new_date/" "$file"
    fi
    
    echo "🔄 Converted $file: '$current_date' → '$new_date'" | tee -a "$CONVERT_LOG"
    CONVERTED_FILES=$((CONVERTED_FILES + 1))
    
    # Remove backup
    rm "$backup_file"
}

# Convert all markdown files with dates
echo "🔍 Converting all date formats to 'dd mmmm yyyy'..." | tee -a "$CONVERT_LOG"
echo "" | tee -a "$CONVERT_LOG"

while IFS= read -r -d '' md_file; do
    if [[ "$md_file" != *"node_modules"* ]] && [[ "$md_file" != *"/.git/"* ]]; then
        convert_date_in_file "$md_file"
    fi
done < <(find . -name "*.md" -type f -print0)

# Summary
end_time=$(date +%s)
duration=$((end_time - start_time))

echo "" | tee -a "$CONVERT_LOG"
echo "🎉 Date format conversion completed!" | tee -a "$CONVERT_LOG"
echo "📊 Summary:" | tee -a "$CONVERT_LOG"
echo "   - Converted files: $CONVERTED_FILES" | tee -a "$CONVERT_LOG"
echo "   - Skipped files: $SKIPPED_FILES" | tee -a "$CONVERT_LOG"
echo "   - Error files: $ERROR_FILES" | tee -a "$CONVERT_LOG"
echo "   - Duration: ${duration}s" | tee -a "$CONVERT_LOG"
echo "" | tee -a "$CONVERT_LOG"
echo "📝 Full log saved to: $CONVERT_LOG" | tee -a "$CONVERT_LOG"
echo "🔍 To verify, run: ./scripts/validate-dates.sh" | tee -a "$CONVERT_LOG"