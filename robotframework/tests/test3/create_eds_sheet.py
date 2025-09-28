#!/usr/bin/env python3
"""
EDS (Engineering Design Specification) Excel Sheet Creator
Creates a template Excel file with network configuration values for validation
"""

import pandas as pd
import os
from datetime import datetime

def create_eds_sheet():
    """Create EDS Excel sheet with sample network configuration values"""

    # Sample network configuration data
    network_config = {
        'Parameter': [
            'Hostname',
            'Primary IP Address',
            'Subnet Mask',
            'Default Gateway',
            'VLAN ID',
            'Primary DNS Server',
            'Secondary DNS Server',
            'NTP Server 1',
            'NTP Server 2',
            'Domain Name',
            'Network Interface',
            'MAC Address',
            'MTU Size',
            'DHCP Enabled',
            'Static Route 1',
            'Static Route 2',
            'Broadcast Address',
            'Network Address',
            'Connection Type',
            'Speed/Duplex'
        ],
        'Expected_Value': [
            'TEST-HOST-01',
            '192.168.1.100',
            '255.255.255.0',
            '192.168.1.1',
            '100',
            '8.8.8.8',
            '1.1.1.1',
            'pool.ntp.org',
            'time.nist.gov',
            'test.local',
            'eth0',
            '00:11:22:33:44:55',
            '1500',
            'False',
            '10.0.0.0/24 via 192.168.1.1',
            '172.16.0.0/16 via 192.168.1.1',
            '192.168.1.255',
            '192.168.1.0',
            'Ethernet',
            '1000/Full'
        ],
        'Collected_Value': [
            '',  # Will be filled during test execution
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            ''
        ],
        'Validation_Status': [
            '',  # Will be PASS/FAIL during validation
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            '',
            ''
        ],
        'Comments': [
            'System hostname/computer name',
            'Primary network interface IP',
            'Network subnet mask',
            'Default route gateway',
            'Virtual LAN identifier',
            'Primary DNS resolver',
            'Secondary DNS resolver',
            'Primary time server',
            'Secondary time server',
            'Network domain name',
            'Primary network interface name',
            'Hardware MAC address',
            'Maximum transmission unit',
            'DHCP client status',
            'Additional routing entry',
            'Additional routing entry',
            'Network broadcast address',
            'Network base address',
            'Physical connection type',
            'Interface speed and duplex mode'
        ]
    }

    # Create DataFrame
    df = pd.DataFrame(network_config)

    # Create Excel file with formatting
    output_dir = os.path.dirname(os.path.abspath(__file__))
    excel_path = os.path.join(output_dir, 'EDS_Network_Configuration.xlsx')

    with pd.ExcelWriter(excel_path, engine='openpyxl') as writer:
        # Write main configuration sheet
        df.to_excel(writer, sheet_name='Network_Config', index=False)

        # Create metadata sheet
        metadata = {
            'Property': [
                'Document Title',
                'Version',
                'Created Date',
                'Last Modified',
                'Description',
                'Usage Instructions',
                'Validation Rules'
            ],
            'Value': [
                'Engineering Design Specification - Network Configuration',
                '1.0',
                datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
                datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
                'Network configuration parameters for automated validation testing',
                'Update Expected_Value column with client requirements. Collected_Value and Validation_Status are auto-populated during test execution.',
                'Values are compared exactly unless marked as ranges or patterns in comments'
            ]
        }

        metadata_df = pd.DataFrame(metadata)
        metadata_df.to_excel(writer, sheet_name='Metadata', index=False)

        # Format the sheets
        workbook = writer.book

        # Format Network_Config sheet
        worksheet = writer.sheets['Network_Config']

        # Set column widths
        worksheet.column_dimensions['A'].width = 20  # Parameter
        worksheet.column_dimensions['B'].width = 25  # Expected_Value
        worksheet.column_dimensions['C'].width = 25  # Collected_Value
        worksheet.column_dimensions['D'].width = 18  # Validation_Status
        worksheet.column_dimensions['E'].width = 40  # Comments

        # Add header formatting
        from openpyxl.styles import Font, PatternFill, Alignment

        header_font = Font(bold=True, color='FFFFFF')
        header_fill = PatternFill(start_color='366092', end_color='366092', fill_type='solid')
        center_align = Alignment(horizontal='center', vertical='center')

        for cell in worksheet[1]:
            cell.font = header_font
            cell.fill = header_fill
            cell.alignment = center_align

        # Format Metadata sheet
        meta_worksheet = writer.sheets['Metadata']
        meta_worksheet.column_dimensions['A'].width = 20
        meta_worksheet.column_dimensions['B'].width = 80

        for cell in meta_worksheet[1]:
            cell.font = header_font
            cell.fill = header_fill
            cell.alignment = center_align

    print(f"✅ EDS Excel sheet created successfully: {excel_path}")
    print("📋 Sheet contains:")
    print("   - Network_Config: Main configuration parameters")
    print("   - Metadata: Document information and usage instructions")
    print("📝 Update the 'Expected_Value' column with your client's requirements")

    return excel_path

if __name__ == "__main__":
    create_eds_sheet()