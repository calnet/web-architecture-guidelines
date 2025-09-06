#!/bin/bash

# Enhanced Cross-Reference Validation Script
# Validates internal links and cross-references across versions

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$ROOT_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

ERRORS=0
WARNINGS=0

log() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    WARNINGS=$((WARNINGS + 1))
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
    ERRORS=$((ERRORS + 1))
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log "🔍 Enhanced Cross-Reference Validation"
log "======================================="

# 1. Validate internal markdown links
log ""
log "📄 Validating internal markdown links..."

find docs -name "*.md" -type f | while read -r file; do
    # Extract markdown links [text](path)
    grep -oE '\[([^\]]*)\]\(([^)]*)\)' "$file" 2>/dev/null | while read -r link; do
        # Extract the path part
        path=$(echo "$link" | sed 's/.*](\([^)]*\)).*/\1/')
        
        # Skip external links (http/https)
        if [[ "$path" =~ ^https?:// ]]; then
            continue
        fi
        
        # Skip anchors only (#section)
        if [[ "$path" =~ ^# ]]; then
            continue
        fi
        
        # Resolve relative path
        if [[ "$path" =~ ^\.\. ]]; then
            # Handle ../path
            base_dir=$(dirname "$file")
            resolved_path="$base_dir/$path"
        elif [[ "$path" =~ ^\. ]]; then
            # Handle ./path
            base_dir=$(dirname "$file")
            resolved_path="$base_dir/${path#./}"
        elif [[ "$path" =~ ^/ ]]; then
            # Absolute path from repo root
            resolved_path="${path#/}"
        else
            # Relative to current file
            base_dir=$(dirname "$file")
            resolved_path="$base_dir/$path"
        fi
        
        # Remove anchor if present
        resolved_path="${resolved_path%#*}"
        
        # Normalize path
        resolved_path=$(realpath -m "$resolved_path" 2>/dev/null || echo "$resolved_path")
        
        # Check if file exists
        if [[ ! -f "$resolved_path" ]]; then
            echo "❌ Broken link in $file: $link -> $resolved_path"
        fi
    done
done

# 2. Validate version cross-references
log ""
log "🔢 Validating version cross-references..."

CURRENT_VERSION=$(cat VERSION | tr -d '\n')

# Check for hardcoded version references that might be outdated
find docs -name "*.md" -type f -exec grep -l "version.*[0-9]\+\.[0-9]\+\.[0-9]\+" {} \; | while read -r file; do
    # Look for version patterns that don't match current version
    grep -n "version.*[0-9]\+\.[0-9]\+\.[0-9]\+" "$file" | while read -r line; do
        if ! echo "$line" | grep -q "$CURRENT_VERSION"; then
            warn "Possible outdated version reference in $file: $line"
        fi
    done
done

# 3. Validate template references
log ""
log "📋 Validating template references..."

# Find references to templates and ensure they exist
find docs -name "*.md" -type f | while read -r file; do
    # Look for template references like docs/templates/...
    grep -oE 'docs/templates/[^)\s]*' "$file" 2>/dev/null | while read -r template_ref; do
        if [[ ! -f "$template_ref" ]]; then
            error "Missing template referenced in $file: $template_ref"
        fi
    done
done

# 4. Validate architectural decision references  
log ""
log "🏗️ Validating architectural decision references..."

# Find ADR references and ensure they exist
find docs -name "*.md" -type f | while read -r file; do
    # Look for ADR references like adr-001, ADR-001, etc.
    grep -oiE 'adr-[0-9]{3}' "$file" 2>/dev/null | while read -r adr_ref; do
        adr_file="docs/architecture/decisions/${adr_ref,,}-*.md"
        if ! ls $adr_file 1> /dev/null 2>&1; then
            error "Missing ADR referenced in $file: $adr_ref"
        fi
    done
done

# 5. Validate code example references
log ""
log "💻 Validating code example references..."

# Find code example references and ensure they exist
find docs -name "*.md" -type f | while read -r file; do
    # Look for example references
    grep -oE 'examples/[^)\s]*' "$file" 2>/dev/null | while read -r example_ref; do
        if [[ ! -f "$example_ref" ]] && [[ ! -d "$example_ref" ]]; then
            warn "Missing example referenced in $file: $example_ref"
        fi
    done
done

# 6. Validate section references (anchors)
log ""
log "🔗 Validating section anchors..."

find docs -name "*.md" -type f | while read -r file; do
    # Extract links with anchors [text](file.md#section)
    grep -oE '\[([^\]]*)\]\(([^)]*#[^)]*)\)' "$file" 2>/dev/null | while read -r link; do
        # Extract the path and anchor
        full_path=$(echo "$link" | sed 's/.*](\([^)]*\)).*/\1/')
        file_part="${full_path%#*}"
        anchor_part="${full_path#*#}"
        
        # Skip external links
        if [[ "$file_part" =~ ^https?:// ]]; then
            continue
        fi
        
        # Resolve file path
        if [[ -n "$file_part" ]]; then
            if [[ "$file_part" =~ ^\.\. ]]; then
                base_dir=$(dirname "$file")
                target_file="$base_dir/$file_part"
            elif [[ "$file_part" =~ ^\. ]]; then
                base_dir=$(dirname "$file")
                target_file="$base_dir/${file_part#./}"
            elif [[ "$file_part" =~ ^/ ]]; then
                target_file="${file_part#/}"
            else
                base_dir=$(dirname "$file")
                target_file="$base_dir/$file_part"
            fi
        else
            # Same file anchor
            target_file="$file"
        fi
        
        # Normalize path
        target_file=$(realpath -m "$target_file" 2>/dev/null || echo "$target_file")
        
        if [[ -f "$target_file" ]]; then
            # Check if anchor exists in target file
            # Convert anchor to expected header format
            expected_header=$(echo "$anchor_part" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-')
            
            # Check for header in target file
            if ! grep -q "^#.*" "$target_file" | grep -q "$expected_header"; then
                # More lenient check - just look for the text
                if ! grep -qi "$anchor_part" "$target_file"; then
                    warn "Anchor '$anchor_part' not found in $target_file (referenced from $file)"
                fi
            fi
        fi
    done
done

# 7. Check for broken relative paths in different contexts
log ""
log "📁 Validating relative path contexts..."

# Check that relative paths work from different locations
find docs -name "*.md" -type f | while read -r file; do
    dir_depth=$(echo "$file" | tr -cd '/' | wc -c)
    if [[ $dir_depth -gt 2 ]]; then  # docs/subdir/file.md or deeper
        # Check for relative paths that might break
        grep -oE '\.\./[^)\s]*' "$file" 2>/dev/null | while read -r rel_path; do
            base_dir=$(dirname "$file")
            resolved=$(realpath -m "$base_dir/$rel_path" 2>/dev/null || echo "$base_dir/$rel_path")
            if [[ ! -f "$resolved" ]] && [[ ! -d "$resolved" ]]; then
                error "Broken relative path in $file: $rel_path -> $resolved"
            fi
        done
    fi
done

# 8. Summary
log ""
log "📊 Cross-Reference Validation Summary"
log "====================================="

if [[ $ERRORS -eq 0 ]] && [[ $WARNINGS -eq 0 ]]; then
    success "All cross-references are valid!"
elif [[ $ERRORS -eq 0 ]]; then
    warn "Validation completed with $WARNINGS warnings"
    exit 0
else
    error "Validation failed with $ERRORS errors and $WARNINGS warnings"
    exit 1
fi