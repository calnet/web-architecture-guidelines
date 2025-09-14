#!/bin/bash

# Enhanced Date Synchronization Script
# This script automatically synchronizes "Last Updated" dates with actual file modification dates

set -e

# Performance and logging
start_time=$(date +%s)
SYNC_LOG="/tmp/date_sync_$(date +%Y%m%d_%H%M%S).log"

echo "📅 Enhanced Date Synchronization" | tee "$SYNC_LOG"
echo "===============================" | tee -a "$SYNC_LOG"
echo "" | tee -a "$SYNC_LOG"

UPDATED_FILES=0
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
            # Format: September 2025
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

# Function to update date in file
update_date_in_file() {
    local file="$1"
    local backup_file="${file}.date_backup"
    local current_date=""
    local new_date=""
    local date_format=""
    
    current_date=$(extract_date_from_file "$file")
    
    if [[ -z "$current_date" ]]; then
        return 0  # No date to update
    fi
    
    # Create backup
    cp "$file" "$backup_file"
    
    date_format=$(determine_date_format "$current_date")
    
    if [[ "$date_format" == "unknown" ]]; then
        echo "⚠️  Skipping $file: Unknown date format '$current_date'" | tee -a "$SYNC_LOG"
        rm "$backup_file"
        SKIPPED_FILES=$((SKIPPED_FILES + 1))
        return 0
    fi
    
    new_date=$(get_file_mod_date "$file" "$date_format")
    
    # Update the date based on the pattern found
    if grep -q "\*\*Last Updated\*\*:" "$file" 2>/dev/null; then
        sed -i "s/\*\*Last Updated\*\*: [^*]*/\*\*Last Updated\*\*: $new_date/" "$file"
    elif grep -q "\*Last Updated\*:" "$file" 2>/dev/null; then
        sed -i "s/\*Last Updated: [^*]*/\*Last Updated: $new_date\*/" "$file"
    elif grep -q "Last Updated:" "$file" 2>/dev/null; then
        sed -i "s/Last Updated: .*/Last Updated: $new_date/" "$file"
    fi
    
    # Check if file was actually changed
    if diff -q "$file" "$backup_file" >/dev/null 2>&1; then
        echo "⚠️  No changes made to $file (already up to date)" | tee -a "$SYNC_LOG"
        SKIPPED_FILES=$((SKIPPED_FILES + 1))
    else
        echo "✅ Updated $file: '$current_date' → '$new_date'" | tee -a "$SYNC_LOG"
        UPDATED_FILES=$((UPDATED_FILES + 1))
    fi
    
    # Remove backup
    rm "$backup_file"
}

# Function to add missing date to file
add_date_to_file() {
    local file="$1"
    local file_type="$2"
    local backup_file="${file}.date_backup"
    
    # Skip if file already has a date
    if [[ -n "$(extract_date_from_file "$file")" ]]; then
        return 0
    fi
    
    # Create backup
    cp "$file" "$backup_file"
    
    # Determine what type of date to add based on file content and type
    local new_date=""
    if [[ "$file_type" == "precise" ]]; then
        new_date=$(get_file_mod_date "$file" "precise")
        echo "" >> "$file"
        echo "- **Last Updated**: $new_date" >> "$file"
    else
        new_date=$(get_file_mod_date "$file" "month_year")
        echo "" >> "$file"
        echo "- **Last Updated**: $new_date" >> "$file"
    fi
    
    echo "📝 Added date to $file: $new_date" | tee -a "$SYNC_LOG"
    UPDATED_FILES=$((UPDATED_FILES + 1))
    
    # Remove backup
    rm "$backup_file"
}

# Discover and update all files with dates
echo "🔍 Discovering files with dates..." | tee -a "$SYNC_LOG"
echo "" | tee -a "$SYNC_LOG"

# Update all markdown files with existing dates
echo "📝 Updating existing dates..." | tee -a "$SYNC_LOG"
while IFS= read -r -d '' md_file; do
    if [[ "$md_file" != *"node_modules"* ]] && [[ "$md_file" != *"/.git/"* ]]; then
        update_date_in_file "$md_file"
    fi
done < <(find . -name "*.md" -type f -print0)

# Optionally add dates to files that don't have them (if requested via parameter)
if [[ "$1" == "--add-missing" ]]; then
    echo "" | tee -a "$SYNC_LOG"
    echo "📝 Adding dates to files without them..." | tee -a "$SYNC_LOG"
    
    while IFS= read -r -d '' md_file; do
        if [[ "$md_file" != *"node_modules"* ]] && [[ "$md_file" != *"/.git/"* ]]; then
            # Determine if this should get a precise or general date
            if [[ "$md_file" == *"/ai-agents/"* ]] || [[ "$md_file" == *"/templates/"* ]]; then
                add_date_to_file "$md_file" "precise"
            else
                add_date_to_file "$md_file" "month_year"
            fi
        fi
    done < <(find . -name "*.md" -type f -print0)
fi

# Summary
end_time=$(date +%s)
duration=$((end_time - start_time))

echo "" | tee -a "$SYNC_LOG"
echo "🎉 Date synchronization completed!" | tee -a "$SYNC_LOG"
echo "📊 Summary:" | tee -a "$SYNC_LOG"
echo "   - Updated files: $UPDATED_FILES" | tee -a "$SYNC_LOG"
echo "   - Skipped files: $SKIPPED_FILES" | tee -a "$SYNC_LOG"
echo "   - Error files: $ERROR_FILES" | tee -a "$SYNC_LOG"
echo "   - Duration: ${duration}s" | tee -a "$SYNC_LOG"
echo "" | tee -a "$SYNC_LOG"
echo "📝 Full log saved to: $SYNC_LOG" | tee -a "$SYNC_LOG"
echo "🔍 To verify, run: ./scripts/validate-dates.sh" | tee -a "$SYNC_LOG"

if [[ "$1" == "--add-missing" ]]; then
    echo "" | tee -a "$SYNC_LOG"
    echo "ℹ️  Note: Added dates to files that were missing them" | tee -a "$SYNC_LOG"
    echo "📚 Use './scripts/sync-dates.sh' (without --add-missing) for regular updates" | tee -a "$SYNC_LOG"
fi