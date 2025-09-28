*** Settings ***
Documentation    🌐 Network Validation Test Suite - Test-3
...              Comprehensive networking validation with executive reporting
...              ✨ Features: DNS resolution, connectivity, performance, and compliance testing
...              📊 Results: Unified HTML reports with enhanced dashboard
...              🎯 Run with: robot network_validation.robot
...
Metadata         Test Suite    Network Validation Test-3
Metadata         Environment   Production-Ready
Metadata         Version       1.0.0
Metadata         Features      DNS, Connectivity, Performance, Routing
Metadata         Reporting     Unified HTML Reports + Enhanced Dashboard

Resource         ../../settings.resource
Resource         network_keywords.resource
Resource         variables.resource

# Configure Robot Framework to output to html_reports directory
Default Tags     network-validation
Force Tags       automated

Suite Setup      Initialize Test Environment
Suite Teardown   Generate Executive Summary

Test Setup       Log Test Start    ${TEST_NAME}
Test Teardown    Log Test End      ${TEST_NAME}    ${TEST_STATUS}

*** Test Cases ***
Critical - Network Interface Validation
    [Documentation]    🔧 Validates network interface configuration and IP assignment
    ...                Ensures proper network adapter setup and connectivity readiness
    [Tags]             critical    networking    interface    compliance

    Log    🔍 Analyzing network interface configuration...    console=yes
    ${total}=    Evaluate    ${TOTAL_TESTS} + 1
    Set Test Variable    ${TOTAL_TESTS}    ${total}

    # Collect interface information
    ${interface_data}=    Execute Network Command    ip addr show    Interface enumeration
    Should Not Be Empty    ${interface_data}    No network interfaces detected

    # Validate IP addresses are assigned
    Should Contain    ${interface_data}    inet    No IP addresses assigned to interfaces

    # Extract primary IP (simplified)
    ${ip_found}=    Get Regexp Matches    ${interface_data}    inet (\\d+\\.\\d+\\.\\d+\\.\\d+)/    1
    ${primary_ip}=    Set Variable If    ${ip_found}    ${ip_found}[0]    127.0.0.1

    Log    ✅ Network interface validation: PASSED    console=yes
    Log    📍 Primary IP Address: ${primary_ip}    console=yes
    Append To List    ${TEST_RESULTS}    Interface Validation: PASS - Primary IP: ${primary_ip}

    ${passed}=    Evaluate    ${PASSED_TESTS} + 1
    Set Test Variable    ${PASSED_TESTS}    ${passed}

Critical - DNS Resolution and Validation
    [Documentation]    🌐 Comprehensive DNS resolution testing using multiple methods
    ...                Tests both IPv4 and IPv6 resolution with fallback mechanisms
    [Tags]             critical    networking    dns    resolution

    Log    🔍 Testing DNS resolution capabilities...    console=yes
    ${total}=    Evaluate    ${TOTAL_TESTS} + 1
    Set Test Variable    ${TOTAL_TESTS}    ${total}

    # Test multiple domains for comprehensive validation
    @{domains}=    Split String    ${TEST_DOMAINS}    ,

    FOR    ${domain}    IN    @{domains}
        Log    Testing DNS resolution for: ${domain}
        ${dns_result}=    Test DNS Resolution For Domain    ${domain}
        Should Not Be Empty    ${dns_result}    DNS resolution failed for ${domain}
    END

    # Test DNS servers
    Test DNS Server Performance    ${PRIMARY_DNS_SERVER}    Primary DNS
    Test DNS Server Performance    ${SECONDARY_DNS_SERVER}    Secondary DNS

    Log    ✅ DNS resolution validation: PASSED    console=yes
    Log    🌐 Successfully resolved ${domains.__len__()} domains    console=yes
    Append To List    ${TEST_RESULTS}    DNS Resolution: PASS - Multiple domains resolved

    ${passed}=    Evaluate    ${PASSED_TESTS} + 1
    Set Test Variable    ${PASSED_TESTS}    ${passed}

Critical - Internet Connectivity Assessment
    [Documentation]    🌍 Multi-tier internet connectivity validation
    ...                Tests connectivity to multiple public servers with performance metrics
    [Tags]             critical    networking    connectivity    performance

    Log    🔍 Assessing internet connectivity performance...    console=yes
    ${total}=    Evaluate    ${TOTAL_TESTS} + 1
    Set Test Variable    ${TOTAL_TESTS}    ${total}

    # Test connectivity to primary DNS
    ${ping_result_primary}=    Test Connectivity With Metrics    ${PRIMARY_DNS_SERVER}    Google DNS
    Should Contain    ${ping_result_primary}    received    Primary DNS connectivity failed

    # Test connectivity to secondary DNS
    ${ping_result_secondary}=    Test Connectivity With Metrics    ${SECONDARY_DNS_SERVER}    Cloudflare DNS
    Should Contain    ${ping_result_secondary}    received    Secondary DNS connectivity failed

    # Extract performance metrics
    ${primary_latency}=    Extract Average Latency    ${ping_result_primary}
    ${secondary_latency}=    Extract Average Latency    ${ping_result_secondary}

    # Store performance data
    Append To List    ${PERFORMANCE_METRICS}    Primary DNS Latency: ${primary_latency}ms
    Append To List    ${PERFORMANCE_METRICS}    Secondary DNS Latency: ${secondary_latency}ms

    Log    ✅ Internet connectivity: EXCELLENT    console=yes
    Log    📊 Primary DNS latency: ${primary_latency}ms    console=yes
    Log    📊 Secondary DNS latency: ${secondary_latency}ms    console=yes
    Append To List    ${TEST_RESULTS}    Internet Connectivity: PASS - Latency: ${primary_latency}ms avg

    ${passed}=    Evaluate    ${PASSED_TESTS} + 1
    Set Test Variable    ${PASSED_TESTS}    ${passed}

Normal - Routing Infrastructure Analysis
    [Documentation]    🛣️ Comprehensive routing table analysis and gateway validation
    ...                Ensures proper network path configuration and redundancy
    [Tags]             normal    networking    routing    infrastructure

    Log    🔍 Analyzing routing infrastructure...    console=yes
    ${total}=    Evaluate    ${TOTAL_TESTS} + 1
    Set Test Variable    ${TOTAL_TESTS}    ${total}

    # Collect routing information
    ${route_data}=    Execute Network Command    ip route show    Routing table collection
    Should Not Be Empty    ${route_data}    Routing table is empty or inaccessible

    # Validate default gateway exists
    Should Contain    ${route_data}    default    No default gateway configured

    # Extract gateway information (simplified)
    ${gateway_matches}=    Get Regexp Matches    ${route_data}    via (\\d+\\.\\d+\\.\\d+\\.\\d+)    1
    ${gateway_ip}=    Set Variable If    ${gateway_matches}    ${gateway_matches}[0]    Unknown

    # Count available routes
    ${lines}=    Split To Lines    ${route_data}
    ${route_count}=    Get Length    ${lines}
    Should Be True    ${route_count} > 0    No routes configured

    Log    ✅ Routing analysis: COMPLETED    console=yes
    Log    🛣️ Default Gateway: ${gateway_ip}    console=yes
    Log    📊 Total Routes: ${route_count}    console=yes
    Append To List    ${TEST_RESULTS}    Routing Analysis: PASS - Gateway: ${gateway_ip}, Routes: ${route_count}

    ${passed}=    Evaluate    ${PASSED_TESTS} + 1
    Set Test Variable    ${PASSED_TESTS}    ${passed}

Normal - Network Performance Baseline
    [Documentation]    📈 Establishes comprehensive network performance baseline
    ...                Measures latency, jitter, and throughput characteristics
    [Tags]             normal    networking    performance    baseline    monitoring

    Log    🔍 Establishing network performance baseline...    console=yes
    ${total}=    Evaluate    ${TOTAL_TESTS} + 1
    Set Test Variable    ${TOTAL_TESTS}    ${total}

    # Extended performance test with statistics
    ${performance_data}=    Execute Extended Performance Test    ${PRIMARY_DNS_SERVER}
    Should Contain    ${performance_data}    received    Performance test failed

    # Extract detailed metrics
    ${min_latency}=    Extract Min Latency    ${performance_data}
    ${max_latency}=    Extract Max Latency    ${performance_data}
    ${avg_latency}=    Extract Average Latency    ${performance_data}
    ${packet_loss}=    Extract Packet Loss    ${performance_data}

    # Validate performance thresholds
    Should Be True    ${avg_latency} < 500    Average latency too high: ${avg_latency}ms
    Should Be True    ${packet_loss} <= 5    Excessive packet loss: ${packet_loss}%

    # Store comprehensive performance metrics
    Append To List    ${PERFORMANCE_METRICS}    Minimum Latency: ${min_latency}ms
    Append To List    ${PERFORMANCE_METRICS}    Maximum Latency: ${max_latency}ms
    Append To List    ${PERFORMANCE_METRICS}    Average Latency: ${avg_latency}ms
    Append To List    ${PERFORMANCE_METRICS}    Packet Loss: ${packet_loss}%

    Log    ✅ Performance baseline: ESTABLISHED    console=yes
    Log    📊 Latency Range: ${min_latency}-${max_latency}ms (avg: ${avg_latency}ms)    console=yes
    Log    📊 Packet Loss: ${packet_loss}%    console=yes
    Append To List    ${TEST_RESULTS}    Performance Baseline: PASS - Avg: ${avg_latency}ms, Loss: ${packet_loss}%

    ${passed}=    Evaluate    ${PASSED_TESTS} + 1
    Set Test Variable    ${PASSED_TESTS}    ${passed}

Critical - Target Machine Connection
    [Documentation]    🔗 Establish direct connection to target machine via WinRM/SSH
    ...                Tests connectivity and authentication to remote systems
    [Tags]             critical    networking    connection    remote    winrm    ssh

    Log    🔍 Establishing connection to target machine...    console=yes
    ${total}=    Evaluate    ${TOTAL_TESTS} + 1
    Set Test Variable    ${TOTAL_TESTS}    ${total}

    # Test connection based on target OS type
    ${connection_result}=    Connect To Target Machine    ${TARGET_HOST}    ${TARGET_OS}    ${TARGET_USERNAME}    ${TARGET_PASSWORD}
    Should Contain    ${connection_result}    SUCCESS    Failed to connect to target machine

    # Validate connection details
    Should Not Be Empty    ${connection_result}    Connection result is empty
    Log    ✅ Target connection: ESTABLISHED    console=yes
    Log    🔗 Connection: ${connection_result}    console=yes
    Append To List    ${TEST_RESULTS}    Target Connection: PASS - ${connection_result}

    ${passed}=    Evaluate    ${PASSED_TESTS} + 1
    Set Test Variable    ${PASSED_TESTS}    ${passed}

Critical - Comprehensive Network Data Collection
    [Documentation]    📊 Execute all network commands in one pass and capture outputs
    ...                Collects ifconfig, route, DNS, NTP data and saves to files
    [Tags]             critical    networking    data-collection    comprehensive

    Log    🔍 Collecting comprehensive network data...    console=yes
    ${total}=    Evaluate    ${TOTAL_TESTS} + 1
    Set Test Variable    ${TOTAL_TESTS}    ${total}

    # Collect all network information in one pass
    ${network_data}=    Collect All Network Information    ${TARGET_HOST}    ${TARGET_OS}
    Should Not Be Empty    ${network_data}    Network data collection failed

    # Save ifconfig data to file as requested
    ${ifconfig_data}=    Get From Dictionary    ${network_data}    ifconfig
    Save Network Data To File    ifconfig    ${ifconfig_data}

    # Validate all required data was collected
    Should Contain    ${network_data}    ifconfig    Interface data not collected
    Should Contain    ${network_data}    route    Routing data not collected
    Should Contain    ${network_data}    dns    DNS data not collected
    Should Contain    ${network_data}    ntp    NTP data not collected

    Log    ✅ Network data collection: COMPLETED    console=yes
    Log    📁 Data saved to: ${DATA_DIR}/network_data_*.txt    console=yes
    Append To List    ${TEST_RESULTS}    Network Data Collection: PASS - All data collected

    ${passed}=    Evaluate    ${PASSED_TESTS} + 1
    Set Test Variable    ${PASSED_TESTS}    ${passed}

Critical - EDS Validation Against Specification
    [Documentation]    📋 Compare collected network data against EDS documentation
    ...                Validates IP, VLAN, DNS, NTP against Engineering Design Spec
    [Tags]             critical    networking    validation    eds    compliance

    Log    🔍 Validating against EDS specification...    console=yes
    ${total}=    Evaluate    ${TOTAL_TESTS} + 1
    Set Test Variable    ${TOTAL_TESTS}    ${total}

    # Load EDS configuration from Excel
    ${eds_config}=    Load EDS Configuration    EDS_Network_Configuration.xlsx
    Should Not Be Empty    ${eds_config}    EDS configuration file not found or empty

    # Collect current network configuration
    ${current_config}=    Get Current Network Configuration    ${TARGET_HOST}    ${TARGET_OS}
    Should Not Be Empty    ${current_config}    Current network configuration not available

    # Perform comprehensive validation
    ${validation_results}=    Validate Against EDS    ${current_config}    ${eds_config}
    Should Not Be Empty    ${validation_results}    Validation process failed

    # Update EDS Excel with results
    Update EDS Excel With Results    EDS_Network_Configuration.xlsx    ${current_config}    ${validation_results}

    # Check validation summary
    ${validation_summary}=    Get Validation Summary    ${validation_results}
    Should Contain    ${validation_summary}    SUMMARY    Validation summary not generated

    Log    ✅ EDS validation: COMPLETED    console=yes
    Log    📊 Validation Summary: ${validation_summary}    console=yes
    Append To List    ${TEST_RESULTS}    EDS Validation: ${validation_summary}

    ${passed}=    Evaluate    ${PASSED_TESTS} + 1
    Set Test Variable    ${PASSED_TESTS}    ${passed}

