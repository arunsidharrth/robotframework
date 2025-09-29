#!/usr/bin/env python3
"""
Auto Dashboard Updater
Automatically updates the dashboard with latest test results
"""

import os
import json
import glob
import datetime
from pathlib import Path

def get_latest_test_results():
    """Scan for latest test results from each test suite"""
    results_dir = Path("results")
    test_suites = {}

    # Scan each test directory
    for test_dir in results_dir.glob("test*"):
        if test_dir.is_dir():
            test_name = test_dir.name
            data_dir = test_dir / "data"

            if data_dir.exists():
                # Find latest metrics file
                metrics_files = list(data_dir.glob("test_metrics_*.json"))
                if metrics_files:
                    latest_metrics = max(metrics_files, key=os.path.getmtime)

                    # Find corresponding results file
                    timestamp = latest_metrics.stem.split('_')[-2] + '_' + latest_metrics.stem.split('_')[-1]
                    results_file = data_dir / f"test_results_{timestamp}.txt"

                    try:
                        with open(latest_metrics, 'r') as f:
                            metrics = json.load(f)

                        results_text = ""
                        if results_file.exists():
                            with open(results_file, 'r') as f:
                                results_text = f.read()

                        test_suites[test_name] = {
                            'metrics': metrics,
                            'results': results_text,
                            'timestamp': timestamp
                        }
                    except Exception as e:
                        print(f"Error reading {test_name}: {e}")

    return test_suites

def generate_unified_dashboard(test_suites):
    """Generate a unified dashboard with all latest test results"""
    current_time = datetime.datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    # Calculate overall statistics
    total_tests = sum(suite['metrics'].get('total_tests', 0) for suite in test_suites.values())
    total_passed = sum(suite['metrics'].get('passed_tests', 0) for suite in test_suites.values())
    total_failed = total_tests - total_passed
    overall_success_rate = round((total_passed / total_tests * 100) if total_tests > 0 else 0)

    # Define test suite descriptions
    suite_descriptions = {
        'test3': 'Network Validation - Interface validation, DNS resolution, connectivity assessment',
        'test4': 'VxRail VM Validation - vCenter API connection, VM discovery, EDS compliance',
        'test5': 'Disk Space Validation - SSH connection, disk space analysis, CPU validation',
        'test6': 'OS Installation Validation - Base OS validation, CIP-007 R2 compliance',
        'test7': 'Time Configuration Validation - Timezone validation, NTP configuration',
        'test8': 'Security Compliance Validation - User account security, firewall rules, SSH keys'
    }

    # Generate HTML dashboard
    html = f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>🌐 Latest Test Results Dashboard - {current_time}</title>
<style>
* {{ margin: 0; padding: 0; box-sizing: border-box; }}
body {{ font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); min-height: 100vh; padding: 20px; }}
.container {{ max-width: 1400px; margin: 0 auto; background: white; border-radius: 15px; box-shadow: 0 10px 30px rgba(0,0,0,0.3); overflow: hidden; }}
.header {{ background: linear-gradient(45deg, #2196F3, #21CBF3); color: white; padding: 30px; text-align: center; }}
.header h1 {{ font-size: 2.5em; text-shadow: 2px 2px 4px rgba(0,0,0,0.3); margin-bottom: 10px; }}
.header p {{ font-size: 1.2em; opacity: 0.9; }}
.stats-grid {{ display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; padding: 30px; background: #f8f9fa; }}
.stat-card {{ background: white; padding: 25px; border-radius: 12px; text-align: center; box-shadow: 0 4px 15px rgba(0,0,0,0.1); transition: transform 0.3s ease; }}
.stat-card:hover {{ transform: translateY(-5px); }}
.stat-number {{ font-size: 2.5em; font-weight: bold; margin: 10px 0; }}
.stat-label {{ font-size: 1.1em; color: #666; }}
.success {{ color: #28a745; }}
.warning {{ color: #ffc107; }}
.danger {{ color: #dc3545; }}
.primary {{ color: #2196F3; }}
.content {{ padding: 30px; }}
.section {{ margin: 30px 0; }}
.section h2 {{ color: #2196F3; margin-bottom: 20px; font-size: 1.8em; }}
.test-grid {{ display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; margin: 20px 0; }}
.test-card {{ background: #f8f9fa; border-radius: 12px; padding: 20px; box-shadow: 0 4px 15px rgba(0,0,0,0.1); border-left: 5px solid #2196F3; }}
.test-card.pass {{ border-left-color: #28a745; }}
.test-card.fail {{ border-left-color: #dc3545; }}
.test-card.partial {{ border-left-color: #ffc107; }}
.test-title {{ font-size: 1.3em; font-weight: bold; margin-bottom: 10px; color: #333; }}
.test-stats {{ display: flex; justify-content: space-between; margin: 15px 0; }}
.test-stat {{ text-align: center; }}
.test-stat-number {{ font-size: 1.8em; font-weight: bold; }}
.test-stat-label {{ font-size: 0.9em; color: #666; }}
.test-links {{ margin-top: 15px; }}
.btn {{ display: inline-block; padding: 8px 15px; margin: 2px; background: #2196F3; color: white; text-decoration: none; border-radius: 5px; font-size: 0.9em; transition: background 0.3s ease; }}
.btn:hover {{ background: #1976D2; }}
.btn-success {{ background: #28a745; }}
.btn-danger {{ background: #dc3545; }}
.btn-warning {{ background: #ffc107; color: #333; }}
.footer {{ text-align: center; padding: 20px; color: #666; background: #f8f9fa; border-top: 1px solid #e9ecef; }}
.timestamp {{ color: #666; font-size: 0.9em; }}
.status-badge {{ display: inline-block; padding: 5px 15px; border-radius: 20px; font-weight: bold; font-size: 0.9em; }}
.status-success {{ background: #d4edda; color: #155724; }}
.status-danger {{ background: #f8d7da; color: #721c24; }}
.status-warning {{ background: #fff3cd; color: #856404; }}
.latest-results {{ background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%); padding: 20px; border-radius: 10px; margin: 20px 0; }}
.result-item {{ display: flex; justify-content: space-between; align-items: center; padding: 10px 0; border-bottom: 1px solid #dee2e6; }}
.result-item:last-child {{ border-bottom: none; }}
.result-name {{ font-weight: bold; color: #333; }}
.result-details {{ color: #666; font-size: 0.9em; }}
</style>
</head>
<body>
<div class="container">
<div class="header">
<h1>🌐 Latest Test Results Dashboard</h1>
<p>Auto-Updated Test Execution Analysis - Tests 3-8</p>
<p class="timestamp">Generated on {current_time}</p>
</div>

<div class="stats-grid">
<div class="stat-card">
<div class="stat-number primary">{total_tests}</div>
<div class="stat-label">Total Test Cases</div>
</div>
<div class="stat-card">
<div class="stat-number success">{total_passed}</div>
<div class="stat-label">Tests Passed</div>
</div>
<div class="stat-card">
<div class="stat-number danger">{total_failed}</div>
<div class="stat-label">Tests Failed</div>
</div>
<div class="stat-card">
<div class="stat-number warning">{overall_success_rate}%</div>
<div class="stat-label">Success Rate</div>
</div>
</div>

<div class="content">
<div class="section">
<h2>📊 Latest Test Results Summary</h2>
<div class="latest-results">
"""

    # Add each test suite result
    for suite_name in sorted(test_suites.keys()):
        suite = test_suites[suite_name]
        metrics = suite['metrics']
        results = suite['results']

        total = metrics.get('total_tests', 0)
        passed = metrics.get('passed_tests', 0)
        failed = total - passed

        # Determine status
        if total == 0:
            status_class = "status-danger"
            status_text = "0/0 FAIL"
        elif passed == total:
            status_class = "status-success"
            status_text = f"{passed}/{total} PASS"
        elif passed > 0:
            status_class = "status-warning"
            status_text = f"{passed}/{total} PARTIAL"
        else:
            status_class = "status-danger"
            status_text = f"0/{total} FAIL"

        # Get description
        description = suite_descriptions.get(suite_name, "Test validation")

        # Extract key details from results
        details = "Status updated automatically"
        if results:
            # Try to extract meaningful details from results
            lines = results.split('\n')
            if len(lines) > 0:
                details = lines[0][:100] + "..." if len(lines[0]) > 100 else lines[0]

        html += f"""
<div class="result-item">
<div>
<div class="result-name">{suite_name.title()} - {description.split(' - ')[0] if ' - ' in description else description}</div>
<div class="result-details">{description.split(' - ')[1] if ' - ' in description else description}</div>
</div>
<div>
<span class="status-badge {status_class}">{status_text}</span>
<div class="result-details">{details}</div>
</div>
</div>"""

    html += """
</div>
</div>

<div class="test-grid">
"""

    # Add test cards for each suite
    for suite_name in sorted(test_suites.keys()):
        suite = test_suites[suite_name]
        metrics = suite['metrics']

        total = metrics.get('total_tests', 0)
        passed = metrics.get('passed_tests', 0)
        failed = total - passed
        duration = metrics.get('duration_seconds', 0)

        # Determine card class
        if total == 0 or passed == 0:
            card_class = "fail"
        elif passed == total:
            card_class = "pass"
        else:
            card_class = "partial"

        html += f"""
<div class="test-card {card_class}">
<div class="test-title">🌐 {suite_name.title()} - {suite_descriptions.get(suite_name, 'Test Validation').split(' - ')[0]}</div>
<div class="test-stats">
<div class="test-stat">
<div class="test-stat-number success">{passed}</div>
<div class="test-stat-label">Passed</div>
</div>
<div class="test-stat">
<div class="test-stat-number danger">{failed}</div>
<div class="test-stat-label">Failed</div>
</div>
<div class="test-stat">
<div class="test-stat-number primary">{duration}s</div>
<div class="test-stat-label">Duration</div>
</div>
</div>
<div class="test-links">
<a href="{suite_name}/report.html" class="btn btn-{'success' if card_class == 'pass' else 'warning' if card_class == 'partial' else 'danger'}">View Report</a>
<a href="{suite_name}/log.html" class="btn">View Log</a>
<a href="{suite_name}/data/" class="btn">View Data</a>
</div>
</div>
"""

    html += f"""
</div>

</div>

<div class="footer">
<p>🤖 Generated by Robot Framework Auto Dashboard Updater</p>
<p>Latest results from test executions automatically aggregated</p>
<p>Dashboard last updated: {current_time}</p>
</div>
</div>
</body>
</html>
"""

    return html

def main():
    """Main function to update dashboard"""
    print("🔄 Scanning for latest test results...")

    # Set results directory path
    results_dir = Path(__file__).parent / "results"

    if not results_dir.exists():
        print("❌ Results directory not found!")
        return

    # Change to robotframework directory (parent of results)
    os.chdir(Path(__file__).parent)

    # Get latest test results
    test_suites = get_latest_test_results()

    if not test_suites:
        print("❌ No test results found!")
        return

    print(f"✅ Found results for {len(test_suites)} test suites")

    # Generate unified dashboard
    dashboard_html = generate_unified_dashboard(test_suites)

    # Save updated dashboard to results directory
    results_dir = Path("results")
    with open(results_dir / "latest_dashboard.html", "w") as f:
        f.write(dashboard_html)

    # Also save with timestamp
    timestamp = datetime.datetime.now().strftime("%Y%m%d_%H%M%S")
    with open(results_dir / f"enhanced_dashboard_{timestamp}.html", "w") as f:
        f.write(dashboard_html)

    print(f"📊 Dashboard updated successfully!")
    print(f"📁 Files created:")
    print(f"   - latest_dashboard.html")
    print(f"   - enhanced_dashboard_{timestamp}.html")

if __name__ == "__main__":
    main()