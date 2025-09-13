#!/bin/bash

echo "⚡ Validating performance compliance..."

ERRORS=0

# Function to check for performance configuration
check_performance_config() {
    local config="$1"
    local files=("${@:2}")

    for file in "${files[@]}"; do
        if [ -f "$file" ] && grep -qi "$config" "$file"; then
            echo "✅ $config configured in $file"
            return 0
        fi
    done

    echo "❌ $config not found in configuration files"
    return 1
}

# Check for performance documentation
if grep -qi "performance\|optimization\|caching\|loading" "ARCHITECTURE.md" 2>/dev/null || grep -qi "performance" "docs/architecture/system-architecture.md" 2>/dev/null; then
    echo "✅ Performance considerations documented"
else
    echo "❌ No performance documentation found"
    ERRORS=$((ERRORS + 1))
fi

# Check for caching configuration
CONFIG_FILES=("next.config.js" "server.js" "app.js" "index.js" "package.json" ".env.example")
if check_performance_config "redis\|cache\|memcached" "${CONFIG_FILES[@]}"; then
    echo "✅ Caching configuration found"
else
    echo "⚠️  No explicit caching configuration found"
fi

# Check for bundling optimization
BUILD_CONFIG_FILES=("next.config.js" "webpack.config.js" "vite.config.js" ".env.example")
if [ -f "next.config.js" ] || [ -f "webpack.config.js" ] || [ -f "vite.config.js" ] || grep -qi "BUILD_OPTIMIZATION\|MINIFICATION" ".env.example" 2>/dev/null; then
    echo "✅ Build optimization configuration found"

    # Check for specific optimizations
    if grep -qi "compress\|gzip\|minify\|optimization\|BUILD_OPTIMIZATION\|MINIFICATION\|GZIP\|BROTLI" "${BUILD_CONFIG_FILES[@]}" 2>/dev/null; then
        echo "✅ Compression/minification configured"
    else
        echo "⚠️  No explicit compression configuration found"
    fi
else
    echo "⚠️  No build configuration found"
fi

# Check for image optimization
PERF_CONFIG_FILES=("next.config.js" "webpack.config.js" "vite.config.js" ".env.example")
if grep -qi "next/image\|image.*optimization\|webp\|responsive.*images\|IMAGE_OPTIMIZATION" "${PERF_CONFIG_FILES[@]}" 2>/dev/null; then
    echo "✅ Image optimization configured"
else
    echo "⚠️  No image optimization found (consider using Next.js Image or similar)"
fi

# Check for code splitting
if [ -d "src" ] || [ -d "pages" ] || [ -d "app" ]; then
    if find . \( -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" \) -print0 | xargs -0 grep -l "dynamic.*import\|lazy\|Suspense\|loadable" > /dev/null 2>&1; then
        echo "✅ Code splitting implementation found"
    else
        echo "⚠️  No code splitting found (consider implementing for better performance)"
    fi
fi

# Check for monitoring configuration
if check_performance_config "monitoring\|metrics\|telemetry\|analytics" "${CONFIG_FILES[@]}"; then
    echo "✅ Performance monitoring configured"
else
    echo "⚠️  No performance monitoring found (consider adding analytics/monitoring)"
fi

# Check for database optimization
if check_performance_config "index\|query.*optimization\|connection.*pool" "${CONFIG_FILES[@]}" "prisma/schema.prisma" "src/db" "lib/db"; then
    echo "✅ Database optimization configuration found"
else
    echo "⚠️  No database optimization configuration found"
fi

# Check for CDN configuration
if check_performance_config "cdn\|cloudfront\|cloudflare" "${CONFIG_FILES[@]}"; then
    echo "✅ CDN configuration found"
else
    echo "⚠️  No CDN configuration found (consider for static asset delivery)"
fi

# Check for performance testing
if [ -f "package.json" ]; then
    if grep -qi "lighthouse\|pagespeed\|performance.*test\|load.*test" "package.json"; then
        echo "✅ Performance testing scripts configured"
    else
        echo "⚠️  No performance testing scripts found"
    fi
fi

# Check for service worker / PWA
if [ -f "public/sw.js" ] || [ -f "src/sw.js" ] || grep -qi "service.*worker\|pwa\|workbox" "${CONFIG_FILES[@]}" 2>/dev/null; then
    echo "✅ Service Worker/PWA configuration found"
else
    echo "⚠️  No Service Worker found (consider for offline capabilities)"
fi

# Check for lazy loading
if find . \( -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" \) -print0 | xargs -0 grep -l "loading.*lazy\|intersection.*observer\|lazy.*load" > /dev/null 2>&1 || grep -qi "LAZY_LOADING" ".env.example" 2>/dev/null; then
    echo "✅ Lazy loading implementation found"
else
    echo "⚠️  No lazy loading found (consider for images and components)"
fi

# Check for compression middleware
COMPRESSION_FILES=("next.config.js" "server.js" "app.js" "index.js" ".env.example")
if grep -qi "compression\|gzip.*middleware\|COMPRESSION_ENABLED\|GZIP_ENABLED\|BROTLI_ENABLED" "${COMPRESSION_FILES[@]}" 2>/dev/null; then
    echo "✅ Compression middleware configured"
else
    echo "⚠️  No compression middleware found (consider adding gzip/brotli)"
fi

# Summary
echo ""
if [ $ERRORS -eq 0 ]; then
    echo "🎉 Performance validation passed!"
    exit 0
else
    echo "💥 Found $ERRORS performance compliance issues"
    exit 1
fi
