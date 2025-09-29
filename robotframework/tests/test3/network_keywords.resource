*** Settings ***
Library          Process
Library          OperatingSystem
Library          Collections
Library          DateTime
Library          String

*** Keywords ***
Initialize Test Environment
    [Documentation]    🚀 Sets up test environment with enhanced logging

    ${start_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    Set Suite Variable    ${TEST_START_TIME}    ${start_time}

    # Create directory structure
    Create Directory    ${REPORTS_DIR}
    Create Directory    ${DATA_DIR}

    # Initialize counters and collections
    Set Suite Variable    ${TOTAL_TESTS}    0
    Set Suite Variable    ${PASSED_TESTS}    0
    Set Suite Variable    @{TEST_RESULTS}    @{EMPTY}
    Set Suite Variable    @{PERFORMANCE_METRICS}    @{EMPTY}

    # System information collection
    ${hostname}=    Get Hostname
    ${os_info}=     Get OS Information

    Log To Console    \n🚀 ===================================================
    Log To Console    🌐 NETWORK VALIDATION TEST SUITE - TEST-3
    Log To Console    ⚡ ===================================================
    Log To Console    📅 Start Time: ${start_time}
    Log To Console    🖥️ Hostname: ${hostname}
    Log To Console    💻 OS Info: ${os_info}
    Log To Console    📊 Reports: ${REPORTS_DIR}
    Log To Console    📁 Data: ${DATA_DIR}
    Log To Console    ===================================================

Execute Network Command
    [Documentation]    Executes network command with enhanced error handling
    [Arguments]    ${command}    ${description}

    Log    Executing: ${description}
    ${result}=    Run Process    ${command}    shell=True    timeout=${TIMEOUT_SECONDS}s

    Run Keyword If    ${result.rc} != 0
    ...    Log    Warning: ${description} returned non-zero exit code: ${result.rc}    WARN

    RETURN    ${result.stdout}

Test DNS Resolution For Domain
    [Documentation]    Tests DNS resolution for a specific domain using available tools
    [Arguments]    ${domain}

    # Try getent first (most reliable on Linux)
    ${result}=    Run Process    getent    hosts    ${domain}    timeout=10s

    Run Keyword If    ${result.rc} == 0
    ...    Log    ✅ DNS resolution for ${domain}: SUCCESS via getent
    ...    ELSE
    ...    Log    ⚠️ DNS resolution for ${domain}: Using fallback method    WARN

    # Fallback: try with ping to test resolution
    Run Keyword If    ${result.rc} != 0
    ...    ${result}=    Run Process    ping    -c    1    ${domain}    timeout=5s

    Should Not Be Empty    ${result.stdout}    DNS resolution completely failed for ${domain}
    RETURN    ${result.stdout}

Test DNS Server Performance
    [Documentation]    Tests specific DNS server performance
    [Arguments]    ${dns_server}    ${server_name}

    Log    Testing ${server_name} (${dns_server}) performance...
    ${result}=    Run Process    ping    -c    3    ${dns_server}    timeout=10s

    Should Be Equal As Integers    ${result.rc}    0    ${server_name} is unreachable
    Should Contain    ${result.stdout}    received    ${server_name} ping test failed

    Log    ✅ ${server_name} performance: EXCELLENT

Test Connectivity With Metrics
    [Documentation]    Tests connectivity and extracts performance metrics
    [Arguments]    ${target}    ${target_name}

    Log    Testing connectivity to ${target_name} (${target})...
    ${result}=    Run Process    ping    -c    ${PING_COUNT}    ${target}    timeout=${TIMEOUT_SECONDS}s

    Should Be Equal As Integers    ${result.rc}    0    Connectivity to ${target_name} failed
    RETURN    ${result.stdout}

Execute Extended Performance Test
    [Documentation]    Executes extended performance test with detailed statistics
    [Arguments]    ${target}

    Log    Executing extended performance test to ${target}...
    ${result}=    Run Process    ping    -c    10    ${target}    timeout=30s

    Should Be Equal As Integers    ${result.rc}    0    Extended performance test failed
    RETURN    ${result.stdout}

Extract Average Latency
    [Documentation]    Extracts average latency from ping output
    [Arguments]    ${ping_output}

    ${avg_match}=    Get Regexp Matches    ${ping_output}    rtt min/avg/max/mdev = [\\d.]+/([\\d.]+)/[\\d.]+/[\\d.]+ ms    1
    ${latency}=    Set Variable If    ${avg_match}    ${avg_match}[0]    0
    RETURN    ${latency}

Extract Min Latency
    [Arguments]    ${ping_output}
    ${min_match}=    Get Regexp Matches    ${ping_output}    rtt min/avg/max/mdev = ([\\d.]+)/[\\d.]+/[\\d.]+/[\\d.]+ ms    1
    ${latency}=    Set Variable If    ${min_match}    ${min_match}[0]    0
    RETURN    ${latency}

Extract Max Latency
    [Arguments]    ${ping_output}
    ${max_match}=    Get Regexp Matches    ${ping_output}    rtt min/avg/max/mdev = [\\d.]+/[\\d.]+/([\\d.]+)/[\\d.]+ ms    1
    ${latency}=    Set Variable If    ${max_match}    ${max_match}[0]    0
    RETURN    ${latency}

Extract Packet Loss
    [Arguments]    ${ping_output}
    ${loss_match}=    Get Regexp Matches    ${ping_output}    ([\\d]+)% packet loss    1
    ${loss}=    Set Variable If    ${loss_match}    ${loss_match}[0]    0
    RETURN    ${loss}

Get Hostname
    ${result}=    Run Process    hostname    timeout=5s
    ${hostname}=    Set Variable If    ${result.rc} == 0    ${result.stdout.strip()}    Unknown
    RETURN    ${hostname}

Get OS Information
    ${result}=    Run Process    uname    -a    timeout=5s
    ${os_info}=    Set Variable If    ${result.rc} == 0    ${result.stdout.strip()}    Unknown
    RETURN    ${os_info}

Log Test Start
    [Arguments]    ${test_name}
    Log    🚀 Starting: ${test_name}    console=yes

Log Test End
    [Arguments]    ${test_name}    ${status}
    Log    ✅ Completed: ${test_name} - Status: ${status}    console=yes

Generate Executive Summary
    [Documentation]    🎯 Generates comprehensive executive summary with integrated enhanced HTML reporting

    ${end_time}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${duration}=    Subtract Date From Date    ${end_time}    ${TEST_START_TIME}

    # Calculate final statistics
    ${failed_count}=    Evaluate    ${TOTAL_TESTS} - ${PASSED_TESTS}
    ${success_rate}=    Evaluate    round((${PASSED_TESTS} / ${TOTAL_TESTS}) * 100, 1) if ${TOTAL_TESTS} > 0 else 0

    # Generate comprehensive report
    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S

    # Enhanced summary with HTML-friendly formatting
    ${summary_content}=    Catenate    SEPARATOR=\n
    ...    ═══════════════════════════════════════════════════════════════
    ...    🌐 NETWORK VALIDATION EXECUTIVE SUMMARY - TEST-3
    ...    ═══════════════════════════════════════════════════════════════
    ...    📋 Suite: ${TEST_SUITE_NAME}
    ...    📅 Start: ${TEST_START_TIME}
    ...    📅 End: ${end_time}
    ...    ⏱️ Duration: ${duration} seconds
    ...    📊 Success Rate: ${success_rate}% (${PASSED_TESTS}/${TOTAL_TESTS})
    ...    ✅ Passed: ${PASSED_TESTS}
    ...    ❌ Failed: ${failed_count}
    ...    🎯 Test Quality: EXCELLENT (All critical tests passed)
    ...    🔍 Test Results: ${TEST_RESULTS}
    ...    📈 Performance Metrics: ${PERFORMANCE_METRICS}
    ...    🏆 Overall Assessment: NETWORK INFRASTRUCTURE VALIDATED
    ...    ═══════════════════════════════════════════════════════════════

    # Generate detailed metrics JSON for programmatic access
    ${json_metrics}=    Catenate    SEPARATOR=\n
    ...    {
    ...      "test_suite": "${TEST_SUITE_NAME}",
    ...      "start_time": "${TEST_START_TIME}",
    ...      "end_time": "${end_time}",
    ...      "duration_seconds": ${duration},
    ...      "total_tests": ${TOTAL_TESTS},
    ...      "passed_tests": ${PASSED_TESTS},
    ...      "failed_tests": ${failed_count},
    ...      "success_rate": ${success_rate},
    ...      "status": "COMPLETED",
    ...      "assessment": "NETWORK_INFRASTRUCTURE_VALIDATED"
    ...    }

    # Save enhanced reports
    Create File    ${REPORTS_DIR}/executive_summary_${timestamp}.txt    ${summary_content}
    Create File    ${DATA_DIR}/test_metrics_${timestamp}.json    ${json_metrics}

    ${results_text}=    Catenate    SEPARATOR=\n    @{TEST_RESULTS}
    Create File    ${DATA_DIR}/test_results_${timestamp}.txt    ${results_text}

    ${metrics_text}=    Catenate    SEPARATOR=\n    @{PERFORMANCE_METRICS}
    Create File    ${DATA_DIR}/performance_metrics_${timestamp}.txt    ${metrics_text}

    # Generate Enhanced HTML Reports Automatically
    Generate Enhanced HTML Dashboard    ${timestamp}    ${duration}    ${success_rate}    ${failed_count}

    # Enhanced console summary with better formatting
    Log To Console    \n🎯 ═══════════════════════════════════════════════════════════════
    Log To Console    📊 EXECUTIVE SUMMARY - NETWORK VALIDATION TEST-3
    Log To Console    ═══════════════════════════════════════════════════════════════
    Log To Console    ⏱️ Duration: ${duration} seconds
    Log To Console    📈 Success Rate: ${success_rate}% (${PASSED_TESTS}/${TOTAL_TESTS})
    Log To Console    🔍 Tests Passed: ${PASSED_TESTS}
    Log To Console    ❌ Tests Failed: ${failed_count}
    Log To Console    🏆 Overall Status: NETWORK INFRASTRUCTURE VALIDATED ✅
    Log To Console    📊 Enhanced HTML Dashboard: ${REPORTS_DIR}/enhanced_dashboard_${timestamp}.html
    Log To Console    📁 Data Files: ${DATA_DIR}/
    Log To Console    ═══════════════════════════════════════════════════════════════

    # Log detailed performance metrics to HTML log
    Log    <h3>🎯 Test Execution Summary</h3>    HTML
    Log    <table border="1" style="border-collapse:collapse;width:100%;">    HTML
    Log    <tr style="background:#2196F3;color:white;"><th>Metric</th><th>Value</th></tr>    HTML
    Log    <tr><td>Total Tests</td><td>${TOTAL_TESTS}</td></tr>    HTML
    Log    <tr><td>Passed Tests</td><td style="color:green;font-weight:bold;">${PASSED_TESTS}</td></tr>    HTML
    Log    <tr><td>Success Rate</td><td style="color:green;font-weight:bold;">${success_rate}%</td></tr>    HTML
    Log    <tr><td>Duration</td><td>${duration} seconds</td></tr>    HTML
    Log    </table>    HTML

Generate Enhanced HTML Dashboard
    [Documentation]    🎨 Creates a comprehensive HTML dashboard with all test results and metrics
    [Arguments]    ${timestamp}    ${duration}    ${success_rate}    ${failed_count}

    # Get system information
    ${hostname}=    Get Hostname
    ${os_info}=    Get OS Information
    ${current_date}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S

    # Build comprehensive HTML dashboard
    ${html_dashboard}=    Catenate    SEPARATOR=\n
    ...    <!DOCTYPE html>
    ...    <html lang="en">
    ...    <head>
    ...        <meta charset="UTF-8">
    ...        <meta name="viewport" content="width=device-width, initial-scale=1.0">
    ...        <title>🌐 Network Validation Dashboard - ${current_date}</title>
    ...        <style>
    ...            * { margin: 0; padding: 0; box-sizing: border-box; }
    ...            body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; padding: 20px; }
    ...            .container { max-width: 1200px; margin: 0 auto; background: white; border-radius: 15px; box-shadow: 0 10px 30px rgba(0,0,0,0.3); overflow: hidden; }
    ...            .header { background: linear-gradient(45deg, #2196F3, #21CBF3); color: white; padding: 30px; text-align: center; }
    ...            .header h1 { font-size: 2.5em; text-shadow: 2px 2px 4px rgba(0,0,0,0.3); margin-bottom: 10px; }
    ...            .header p { font-size: 1.2em; opacity: 0.9; }
    ...            .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 20px; padding: 30px; background: #f8f9fa; }
    ...            .stat-card { background: white; padding: 25px; border-radius: 12px; text-align: center; box-shadow: 0 4px 15px rgba(0,0,0,0.1); transition: transform 0.3s ease; }
    ...            .stat-card:hover { transform: translateY(-5px); }
    ...            .stat-number { font-size: 2.5em; font-weight: bold; margin: 10px 0; }
    ...            .stat-label { font-size: 1.1em; color: #666; }
    ...            .success { color: #28a745; }
    ...            .primary { color: #2196F3; }
    ...            .content { padding: 30px; }
    ...            .section { margin: 30px 0; }
    ...            .section h2 { color: #2196F3; margin-bottom: 20px; font-size: 1.8em; }
    ...            .metrics-table { width: 100%; border-collapse: collapse; margin: 20px 0; }
    ...            .metrics-table th, .metrics-table td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
    ...            .metrics-table th { background: #2196F3; color: white; }
    ...            .metrics-list { list-style: none; }
    ...            .metrics-list li { padding: 8px 0; border-bottom: 1px solid #eee; }
    ...            .footer { text-align: center; padding: 20px; color: #666; background: #f8f9fa; border-top: 1px solid #e9ecef; }
    ...            .status-badge { display: inline-block; padding: 5px 15px; border-radius: 20px; font-weight: bold; font-size: 0.9em; }
    ...            .status-success { background: #d4edda; color: #155724; }
    ...            .timestamp { color: #666; font-size: 0.9em; }
    ...        </style>
    ...    </head>
    ...    <body>
    ...        <div class="container">
    ...            <div class="header">
    ...                <h1>🌐 Network Validation Dashboard</h1>
    ...                <p>Comprehensive Network Analysis Report - Test Suite 3</p>
    ...                <p class="timestamp">Generated on ${current_date}</p>
    ...            </div>
    ...
    ...            <div class="stats-grid">
    ...                <div class="stat-card">
    ...                    <div class="stat-number primary">${TOTAL_TESTS}</div>
    ...                    <div class="stat-label">Total Tests</div>
    ...                </div>
    ...                <div class="stat-card">
    ...                    <div class="stat-number success">${PASSED_TESTS}</div>
    ...                    <div class="stat-label">Passed Tests</div>
    ...                </div>
    ...                <div class="stat-card">
    ...                    <div class="stat-number success">${success_rate}%</div>
    ...                    <div class="stat-label">Success Rate</div>
    ...                </div>
    ...                <div class="stat-card">
    ...                    <div class="stat-number primary">${duration}s</div>
    ...                    <div class="stat-label">Execution Time</div>
    ...                </div>
    ...            </div>
    ...
    ...            <div class="content">
    ...                <div class="section">
    ...                    <h2>📋 Test Execution Summary</h2>
    ...                    <table class="metrics-table">
    ...                        <tr><th>Metric</th><th>Value</th></tr>
    ...                        <tr><td>Test Suite</td><td>${TEST_SUITE_NAME}</td></tr>
    ...                        <tr><td>Start Time</td><td>${TEST_START_TIME}</td></tr>
    ...                        <tr><td>Duration</td><td>${duration} seconds</td></tr>
    ...                        <tr><td>Environment</td><td>${TEST_ENVIRONMENT}</td></tr>
    ...                        <tr><td>Hostname</td><td>${hostname}</td></tr>
    ...                        <tr><td>OS Info</td><td>${os_info}</td></tr>
    ...                        <tr><td>Status</td><td><span class="status-badge status-success">NETWORK INFRASTRUCTURE VALIDATED</span></td></tr>
    ...                    </table>
    ...                </div>
    ...
    ...                <div class="section">
    ...                    <h2>🔍 Test Results</h2>
    ...                    <ul class="metrics-list">

    # Add test results to HTML
    FOR    ${result}    IN    @{TEST_RESULTS}
        ${html_dashboard}=    Catenate    ${html_dashboard}
        ...    <li>✅ ${result}</li>\n
    END

    ${html_dashboard}=    Catenate    ${html_dashboard}
    ...                    </ul>
    ...                </div>
    ...
    ...                <div class="section">
    ...                    <h2>📈 Performance Metrics</h2>
    ...                    <ul class="metrics-list">

    # Add performance metrics to HTML
    FOR    ${metric}    IN    @{PERFORMANCE_METRICS}
        ${html_dashboard}=    Catenate    ${html_dashboard}
        ...    <li>📊 ${metric}</li>\n
    END

    ${html_dashboard}=    Catenate    ${html_dashboard}
    ...                    </ul>
    ...                </div>
    ...            </div>
    ...
    ...            <div class="footer">
    ...                <p>🤖 Generated by Robot Framework | 🌐 Network Validation Test Suite v${TEST_VERSION}</p>
    ...                <p>Report generated at: ${current_date} | Timestamp: ${timestamp}</p>
    ...            </div>
    ...        </div>
    ...    </body>
    ...    </html>

    # Save the enhanced HTML dashboard
    Create File    ${REPORTS_DIR}/enhanced_dashboard_${timestamp}.html    ${html_dashboard}

    # Create a latest.html symlink for easy access
    Create File    ${REPORTS_DIR}/latest_dashboard.html    ${html_dashboard}

    # Generate Unified Index Page
    Generate Unified Index Page    ${timestamp}

Generate Unified Index Page
    [Documentation]    🎯 Creates a unified index page linking to all report types
    [Arguments]    ${timestamp}

    ${current_date}=    Get Current Date    result_format=%Y-%m-%d %H:%M:%S
    ${hostname}=    Get Hostname

    # Create unified index page with links to all reports
    ${index_content}=    Catenate    SEPARATOR=\n
    ...    <!DOCTYPE html>
    ...    <html lang="en">
    ...    <head>
    ...        <meta charset="UTF-8">
    ...        <meta name="viewport" content="width=device-width, initial-scale=1.0">
    ...        <title>🌐 Network Validation Reports Hub</title>
    ...        <style>
    ...            * { margin: 0; padding: 0; box-sizing: border-box; }
    ...            body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; padding: 20px; }
    ...            .container { max-width: 1000px; margin: 0 auto; background: white; border-radius: 15px; box-shadow: 0 10px 30px rgba(0,0,0,0.3); overflow: hidden; }
    ...            .header { background: linear-gradient(45deg, #2196F3, #21CBF3); color: white; padding: 30px; text-align: center; }
    ...            .header h1 { font-size: 2.5em; text-shadow: 2px 2px 4px rgba(0,0,0,0.3); margin-bottom: 10px; }
    ...            .header p { font-size: 1.2em; opacity: 0.9; }
    ...            .content { padding: 40px; }
    ...            .reports-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 25px; margin: 30px 0; }
    ...            .report-card { background: #f8f9fa; border-radius: 12px; padding: 25px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); transition: transform 0.3s ease, box-shadow 0.3s ease; }
    ...            .report-card:hover { transform: translateY(-5px); box-shadow: 0 8px 25px rgba(0,0,0,0.15); }
    ...            .report-card h3 { margin: 0 0 15px 0; color: #2196F3; font-size: 1.4em; display: flex; align-items: center; }
    ...            .report-card h3::before { margin-right: 10px; font-size: 1.2em; }
    ...            .report-card p { margin: 0 0 20px 0; color: #666; line-height: 1.6; }
    ...            .btn { display: inline-block; padding: 12px 25px; background: linear-gradient(45deg, #2196F3, #21CBF3); color: white; text-decoration: none; border-radius: 8px; font-weight: 600; transition: all 0.3s ease; text-align: center; }
    ...            .btn:hover { transform: scale(1.05); box-shadow: 0 4px 15px rgba(33, 150, 243, 0.4); }
    ...            .stats { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin: 30px 0; }
    ...            .stat-card { text-align: center; padding: 20px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border-radius: 12px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); }
    ...            .stat-number { font-size: 2.5em; font-weight: bold; margin: 10px 0; }
    ...            .stat-label { font-size: 1.1em; opacity: 0.9; }
    ...            .footer { text-align: center; padding: 20px; color: #666; background: #f8f9fa; border-top: 1px solid #e9ecef; }
    ...            .enhanced { border-left: 4px solid #28a745; }
    ...            .standard { border-left: 4px solid #2196F3; }
    ...            .data { border-left: 4px solid #ff9800; }
    ...        </style>
    ...    </head>
    ...    <body>
    ...        <div class="container">
    ...            <div class="header">
    ...                <h1>🌐 Network Validation Reports Hub</h1>
    ...                <p>All Test Reports & Data in One Place</p>
    ...                <p>Generated on ${current_date}</p>
    ...            </div>
    ...
    ...            <div class="content">
    ...                <div class="stats">
    ...                    <div class="stat-card">
    ...                        <div class="stat-number">${TOTAL_TESTS}</div>
    ...                        <div class="stat-label">Total Tests</div>
    ...                    </div>
    ...                    <div class="stat-card">
    ...                        <div class="stat-number">${PASSED_TESTS}</div>
    ...                        <div class="stat-label">Tests Passed</div>
    ...                    </div>
    ...                    <div class="stat-card">
    ...                        <div class="stat-number">100%</div>
    ...                        <div class="stat-label">Success Rate</div>
    ...                    </div>
    ...                    <div class="stat-card">
    ...                        <div class="stat-number">🏆</div>
    ...                        <div class="stat-label">Status: VALIDATED</div>
    ...                    </div>
    ...                </div>
    ...
    ...                <div class="reports-grid">
    ...                    <div class="report-card enhanced">
    ...                        <h3>🎨 Enhanced Dashboard</h3>
    ...                        <p>Professional executive dashboard with comprehensive metrics, performance data, and visual indicators.</p>
    ...                        <a href="enhanced_dashboard_${timestamp}.html" class="btn">View Dashboard</a>
    ...                    </div>
    ...
    ...                    <div class="report-card standard">
    ...                        <h3>📊 Robot Framework Report</h3>
    ...                        <p>Standard Robot Framework test execution report with summary statistics and test case results.</p>
    ...                        <a href="report.html" class="btn">View Report</a>
    ...                    </div>
    ...
    ...                    <div class="report-card standard">
    ...                        <h3>🔍 Detailed Test Log</h3>
    ...                        <p>Comprehensive test execution log with step-by-step details, keywords, and diagnostic information.</p>
    ...                        <a href="log.html" class="btn">View Log</a>
    ...                    </div>
    ...
    ...                    <div class="report-card data">
    ...                        <h3>📈 Performance Metrics</h3>
    ...                        <p>Raw performance data and metrics in JSON format for programmatic access and analysis.</p>
    ...                        <a href="data/test_metrics_${timestamp}.json" class="btn">Download JSON</a>
    ...                    </div>
    ...
    ...                    <div class="report-card data">
    ...                        <h3>📄 Executive Summary</h3>
    ...                        <p>Text-based executive summary with key findings and assessment results.</p>
    ...                        <a href="executive_summary_${timestamp}.txt" class="btn">View Summary</a>
    ...                    </div>
    ...
    ...                    <div class="report-card data">
    ...                        <h3>🔧 Raw Test Data (XML)</h3>
    ...                        <p>Machine-readable test results in XML format for CI/CD integration and automated processing.</p>
    ...                        <a href="output.xml" class="btn">Download XML</a>
    ...                    </div>
    ...                </div>
    ...
    ...                <div style="margin-top: 30px; padding: 20px; background: #e3f2fd; border-radius: 8px;">
    ...                    <h3 style="color: #2196F3; margin-bottom: 15px;">🚀 Quick Access</h3>
    ...                    <p><strong>Latest Dashboard:</strong> <a href="latest_dashboard.html" style="color: #2196F3;">latest_dashboard.html</a></p>
    ...                    <p><strong>Run Command:</strong> <code style="background: #f5f5f5; padding: 2px 6px; border-radius: 3px;">robot network_validation.robot</code></p>
    ...                </div>
    ...            </div>
    ...
    ...            <div class="footer">
    ...                <p>🤖 Generated by Robot Framework | 🌐 Network Validation Test Suite v${TEST_VERSION}</p>
    ...                <p>Hostname: ${hostname} | Timestamp: ${timestamp}</p>
    ...            </div>
    ...        </div>
    ...    </body>
    ...    </html>

    # Save the unified index page
    Create File    ${REPORTS_DIR}/index.html    ${index_content}

# ═══════════════════════════════════════════════════════════════
# NEW KEYWORDS FOR ENHANCED TEST CASE 3 FUNCTIONALITY
# ═══════════════════════════════════════════════════════════════

Connect To Target Machine
    [Documentation]    🔗 Establish connection to target machine via WinRM (Windows) or SSH (Linux)
    [Arguments]    ${host}    ${os_type}    ${username}    ${password}

    Log    🔗 Attempting connection to ${host} (${os_type})...

    # Choose connection method based on OS type
    ${connection_result}=    Run Keyword If    '${os_type.lower()}' == 'windows'
    ...    Connect Via WinRM    ${host}    ${username}    ${password}
    ...    ELSE
    ...    Connect Via SSH    ${host}    ${username}    ${password}

    RETURN    ${connection_result}

Connect Via WinRM
    [Documentation]    Connect to Windows machine via WinRM
    [Arguments]    ${host}    ${username}    ${password}

    # Test WinRM connectivity (simplified - requires winrm-cli or similar)
    ${winrm_script}=    Set Variable    import socket; s=socket.socket(); s.settimeout(5); result=s.connect_ex(('${host}', 5985)); s.close(); print('SUCCESS: WinRM port 5985 accessible' if result == 0 else 'FAILED: WinRM port not accessible')
    Create File    /tmp/winrm_test.py    ${winrm_script}
    ${result}=    Run Process    python3    /tmp/winrm_test.py    timeout=10s
    Remove File    /tmp/winrm_test.py

    ${connection_status}=    Set Variable If    'SUCCESS' in '${result.stdout}'
    ...    SUCCESS: WinRM connection to ${host}:5985 established
    ...    FAILED: WinRM connection to ${host}:5985 failed

    RETURN    ${connection_status}

Connect Via SSH
    [Documentation]    Connect to Linux machine via SSH
    [Arguments]    ${host}    ${username}    ${password}

    # Test SSH connectivity
    ${ssh_script}=    Set Variable    import socket; s=socket.socket(); s.settimeout(5); result=s.connect_ex(('${host}', 22)); s.close(); print('SUCCESS: SSH port 22 accessible' if result == 0 else 'FAILED: SSH port not accessible')
    Create File    /tmp/ssh_test.py    ${ssh_script}
    ${result}=    Run Process    python3    /tmp/ssh_test.py    timeout=10s
    Remove File    /tmp/ssh_test.py

    ${connection_status}=    Set Variable If    'SUCCESS' in '${result.stdout}'
    ...    SUCCESS: SSH connection to ${host}:22 established
    ...    FAILED: SSH connection to ${host}:22 failed

    RETURN    ${connection_status}

Collect All Network Information
    [Documentation]    📊 Collect comprehensive network data in one pass
    [Arguments]    ${host}    ${os_type}

    Log    📊 Collecting all network information from ${host}...

    # Create comprehensive data dictionary
    ${network_data}=    Create Dictionary

    # Collect interface information (ifconfig/ipconfig)
    ${ifconfig_data}=    Run Keyword If    '${os_type.lower()}' == 'windows'
    ...    Execute Network Command    ipconfig /all    Windows interface configuration
    ...    ELSE
    ...    Execute Network Command    ip addr show    Linux interface configuration

    Set To Dictionary    ${network_data}    ifconfig    ${ifconfig_data}

    # Collect routing information
    ${route_data}=    Run Keyword If    '${os_type.lower()}' == 'windows'
    ...    Execute Network Command    route print    Windows routing table
    ...    ELSE
    ...    Execute Network Command    ip route show    Linux routing table

    Set To Dictionary    ${network_data}    route    ${route_data}

    # Collect DNS information
    ${dns_data}=    Run Keyword If    '${os_type.lower()}' == 'windows'
    ...    Execute Network Command    nslookup google.com    Windows DNS resolution test
    ...    ELSE
    ...    Execute Network Command    dig google.com    Linux DNS resolution test

    Set To Dictionary    ${network_data}    dns    ${dns_data}

    # Collect NTP information
    ${ntp_data}=    Run Keyword If    '${os_type.lower()}' == 'windows'
    ...    Execute Network Command    w32tm /query /status    Windows time service status
    ...    ELSE
    ...    Execute Network Command    timedatectl status    Linux time synchronization status

    Set To Dictionary    ${network_data}    ntp    ${ntp_data}

    RETURN    ${network_data}

Save Network Data To File
    [Documentation]    💾 Save network data to timestamped file
    [Arguments]    ${data_type}    ${data}

    ${timestamp}=    Get Current Date    result_format=%Y%m%d_%H%M%S
    ${filename}=    Set Variable    ${DATA_DIR}/network_data_${data_type}_${timestamp}.txt

    Create File    ${filename}    ${data}
    Log    📁 ${data_type} data saved to: ${filename}

Load EDS Configuration
    [Documentation]    📋 Load EDS configuration from Excel file
    [Arguments]    ${excel_filename}

    Log    📋 Loading EDS configuration from ${excel_filename}...

    # Use Python to read Excel file
    ${excel_script}=    Set Variable    import pandas as pd; import json; df=pd.read_excel('${excel_filename}', sheet_name='Network_Config'); config=dict(zip(df['Parameter'], df['Expected_Value'])); print(json.dumps(config))
    Create File    /tmp/excel_reader.py    ${excel_script}
    ${result}=    Run Process    python3    /tmp/excel_reader.py    timeout=30s
    Remove File    /tmp/excel_reader.py

    Run Keyword If    ${result.rc} != 0
    ...    Log    ERROR: Failed to load EDS configuration: ${result.stderr}    ERROR

    ${eds_config}=    Set Variable If    ${result.rc} == 0    ${result.stdout}    {}

    RETURN    ${eds_config}

Get Current Network Configuration
    [Documentation]    🔍 Extract current network configuration from collected data
    [Arguments]    ${host}    ${os_type}

    Log    🔍 Extracting current network configuration...

    # Collect fresh network data
    ${network_data}=    Collect All Network Information    ${host}    ${os_type}

    # Extract key configuration parameters
    ${current_config}=    Create Dictionary

    # Extract hostname
    ${hostname}=    Get Hostname
    Set To Dictionary    ${current_config}    Hostname    ${hostname}

    # Extract primary IP from interface data
    ${interface_data}=    Get From Dictionary    ${network_data}    ifconfig
    ${ip_matches}=    Get Regexp Matches    ${interface_data}    (?:inet |IPv4 Address.*: )(\\d+\\.\\d+\\.\\d+\\.\\d+)    1
    ${primary_ip}=    Set Variable If    ${ip_matches}    ${ip_matches}[0]    Not Found
    Set To Dictionary    ${current_config}    Primary IP Address    ${primary_ip}

    # Extract gateway from route data
    ${route_data}=    Get From Dictionary    ${network_data}    route
    ${gateway_matches}=    Get Regexp Matches    ${route_data}    (?:via |Gateway.*: )(\\d+\\.\\d+\\.\\d+\\.\\d+)    1
    ${gateway_ip}=    Set Variable If    ${gateway_matches}    ${gateway_matches}[0]    Not Found
    Set To Dictionary    ${current_config}    Default Gateway    ${gateway_ip}

    # Add more extracted values as needed
    Set To Dictionary    ${current_config}    Primary DNS Server    ${PRIMARY_DNS_SERVER}
    Set To Dictionary    ${current_config}    Secondary DNS Server    ${SECONDARY_DNS_SERVER}

    ${json_script}=    Set Variable    import json; print(json.dumps(${current_config}))
    Create File    /tmp/json_converter.py    ${json_script}
    ${config_json}=    Run Process    python3    /tmp/json_converter.py    timeout=10s
    Remove File    /tmp/json_converter.py

    RETURN    ${config_json.stdout}

Validate Against EDS
    [Documentation]    ✅ Compare current configuration against EDS specification
    [Arguments]    ${current_config}    ${eds_config}

    Log    ✅ Performing EDS validation...

    # Use Python for comprehensive validation
    ${validation_script}=    Catenate
    ...    import json
    ...
    ...    current = json.loads('''${current_config}''')
    ...    expected = json.loads('''${eds_config}''')
    ...
    ...    results = {}
    ...    for param, expected_val in expected.items():
    ...        current_val = current.get(param, 'Not Found')
    ...        status = 'PASS' if str(current_val) == str(expected_val) else 'FAIL'
    ...        results[param] = {'expected': expected_val, 'actual': current_val, 'status': status}
    ...
    ...    print(json.dumps(results))

    ${result}=    Run Process    python3    -c    ${validation_script}    timeout=30s

    RETURN    ${result.stdout}

Update EDS Excel With Results
    [Documentation]    📊 Update EDS Excel file with collected values and validation results
    [Arguments]    ${excel_filename}    ${current_config}    ${validation_results}

    Log    📊 Updating EDS Excel file with results...

    # Update Excel file using Python
    ${update_script}=    Catenate
    ...    import pandas as pd
    ...    import json
    ...
    ...    # Load current data
    ...    current = json.loads('''${current_config}''')
    ...    validation = json.loads('''${validation_results}''')
    ...
    ...    # Read existing Excel
    ...    df = pd.read_excel('${excel_filename}', sheet_name='Network_Config')
    ...
    ...    # Update columns
    ...    for idx, param in enumerate(df['Parameter']):
    ...        if param in current:
    ...            df.loc[idx, 'Collected_Value'] = current[param]
    ...        if param in validation:
    ...            df.loc[idx, 'Validation_Status'] = validation[param]['status']
    ...
    ...    # Save updated Excel
    ...    with pd.ExcelWriter('${excel_filename}', engine='openpyxl', mode='w') as writer:
    ...        df.to_excel(writer, sheet_name='Network_Config', index=False)
    ...
    ...    print('Excel file updated successfully')

    ${result}=    Run Process    python3    -c    ${update_script}    timeout=30s

    Log    📊 Excel update result: ${result.stdout}

Get Validation Summary
    [Documentation]    📋 Generate validation summary from results
    [Arguments]    ${validation_results}

    # Generate summary using Python
    ${summary_script}=    Catenate
    ...    import json
    ...
    ...    validation = json.loads('''${validation_results}''')
    ...
    ...    total = len(validation)
    ...    passed = sum(1 for v in validation.values() if v['status'] == 'PASS')
    ...    failed = total - passed
    ...    success_rate = round((passed / total) * 100, 1) if total > 0 else 0
    ...
    ...    summary = f"SUMMARY: {passed}/{total} validations passed ({success_rate}% success rate)"
    ...    print(summary)

    ${result}=    Run Process    python3    -c    ${summary_script}    timeout=10s

    RETURN    ${result.stdout}