#!/bin/bash

# Robot Framework Test Runner with Auto Dashboard Update
# Runs Robot Framework tests and automatically updates the dashboard

echo "🤖 Robot Framework Test Runner with Auto Dashboard Update"
echo "========================================================"

# Change to the robotframework directory
cd "$(dirname "$0")"

# Default test directory if none specified
TEST_DIR="${1:-tests}"
OUTPUT_DIR="results"

# Check if test directory exists
if [ ! -d "$TEST_DIR" ]; then
    echo "❌ Error: Test directory '$TEST_DIR' not found!"
    echo "Usage: $0 [test_directory]"
    exit 1
fi

echo "📂 Test Directory: $TEST_DIR"
echo "📂 Output Directory: $OUTPUT_DIR"

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Function to run tests for a specific test suite
run_test_suite() {
    local test_path="$1"
    local test_name=$(basename "$test_path")
    local output_subdir="$OUTPUT_DIR/$test_name"

    echo "🚀 Running $test_name..."

    # Create test-specific output directory
    mkdir -p "$output_subdir"

    # Run Robot Framework for this specific test
    robot --outputdir "$output_subdir" \
          --name "$test_name" \
          --loglevel INFO \
          "$test_path"

    local exit_code=$?

    if [ $exit_code -eq 0 ]; then
        echo "✅ $test_name completed successfully"
    else
        echo "⚠️ $test_name completed with issues (exit code: $exit_code)"
    fi

    return $exit_code
}

# Check if a specific test is requested
if [ $# -gt 1 ]; then
    # Run specific test
    run_test_suite "$TEST_DIR/$2"
    test_exit_code=$?
else
    # Run all tests in the directory
    echo "🔄 Scanning for test suites..."

    test_exit_code=0
    test_count=0

    # Find all .robot files
    for test_file in "$TEST_DIR"/*/*.robot; do
        if [ -f "$test_file" ]; then
            test_count=$((test_count + 1))
            test_dir=$(dirname "$test_file")

            run_test_suite "$test_dir"

            # Keep track of any failures
            if [ $? -ne 0 ]; then
                test_exit_code=1
            fi
        fi
    done

    if [ $test_count -eq 0 ]; then
        echo "❌ No .robot test files found in $TEST_DIR"
        exit 1
    fi

    echo "📊 Completed $test_count test suite(s)"
fi

echo ""
echo "🔄 Updating dashboard with latest results..."

# Run the dashboard updater
if [ -f "update_dashboard.py" ]; then
    python3 update_dashboard.py

    if [ $? -eq 0 ]; then
        echo "✅ Dashboard updated successfully!"
        echo "📊 View results at: $OUTPUT_DIR/latest_dashboard.html"
    else
        echo "⚠️ Dashboard update had issues"
    fi
else
    echo "⚠️ Dashboard updater not found (update_dashboard.py)"
fi

echo ""
echo "========================================================"

if [ $test_exit_code -eq 0 ]; then
    echo "🎉 All tests completed successfully!"
else
    echo "⚠️ Some tests completed with issues"
fi

echo "📁 Results available in: $OUTPUT_DIR/"
echo "========================================================"

exit $test_exit_code