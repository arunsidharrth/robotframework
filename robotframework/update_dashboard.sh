#!/bin/bash

# Auto Dashboard Updater Script
# Automatically updates the dashboard with latest test results

echo "🚀 Robot Framework Dashboard Auto-Updater"
echo "========================================="

# Change to the robotframework directory
cd "$(dirname "$0")"

echo "📂 Working directory: $(pwd)"

# Check if Python script exists
if [ ! -f "update_dashboard.py" ]; then
    echo "❌ Error: update_dashboard.py not found!"
    exit 1
fi

# Run the Python dashboard updater
echo "🔄 Updating dashboard with latest results..."
python3 update_dashboard.py

# Check if update was successful
if [ $? -eq 0 ]; then
    echo "✅ Dashboard update completed successfully!"
    echo "📊 View updated dashboard: results/latest_dashboard.html"

    # Open dashboard in browser (optional - uncomment if desired)
    # xdg-open results/latest_dashboard.html 2>/dev/null || open results/latest_dashboard.html 2>/dev/null
else
    echo "❌ Dashboard update failed!"
    exit 1
fi

echo "========================================="
echo "🎯 Dashboard auto-update complete!"