*** Variables ***
# Test Metadata
${TEST_SUITE_NAME}      Network Validation Test Suite - Test-3
${TEST_VERSION}         1.0.0
${TEST_ENVIRONMENT}     Production-Ready

# Directory Configuration - Test-specific data, global reports
${REPORTS_DIR}          ${CURDIR}/../../results
${DATA_DIR}             ${CURDIR}/../../results/test3/data

# Network Test Configuration
${PRIMARY_DNS_SERVER}   8.8.8.8
${SECONDARY_DNS_SERVER}   1.1.1.1
${TEST_DOMAINS}         google.com,github.com,stackoverflow.com
${PING_COUNT}           5
${TIMEOUT_SECONDS}      15

# Target Machine Configuration
${TARGET_HOST}          192.168.1.100
${TARGET_OS}            windows
${TARGET_USERNAME}      testuser
${TARGET_PASSWORD}      testpass123

# Test Execution Tracking (initialized values)
${TOTAL_TESTS}          0
${PASSED_TESTS}         0
@{TEST_RESULTS}
@{PERFORMANCE_METRICS}