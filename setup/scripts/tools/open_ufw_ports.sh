#!/bin/bash

# ==============================================================================
# Enable UFW Firewall and Open Specific Ports in Ubuntu
# ==============================================================================
#
# Description:
#   This script opens all the necessary TCP ports in Ubuntu's Uncomplicated
#   Firewall (UFW) to match the port forwarding rules set in VirtualBox.
#   It ensures SSH is allowed before enabling the firewall to prevent lockouts.
#
# Usage:
#   1. Copy this script to your Ubuntu VM.
#   2. Make it executable: chmod +x enable_vm_firewall.sh
#   3. Run it with sudo:     sudo ./enable_vm_firewall.sh
#
# ==============================================================================

# --- Configuration ---

# This list must match the list in the VirtualBox setup script.
ALLOWED_PORTS=(
  22 80 443 11436 17860 17861 17862 17863
  18000 18081 28080 8080 3389 10001 3000 15000
  14000 14001 14002 14003 14004 14005 14006 14007
  14008 14009 14010 14011 14012
  18567 18568 18569 18570 18571 18572 18573 18574 18575 18576
)

# --- Script Logic ---

echo "--- Configuring UFW Firewall in Ubuntu VM ---"

# IMPORTANT: Always allow SSH first to avoid locking yourself out.
echo "Step 1: Ensuring SSH access is allowed..."
ufw allow ssh
# The line above is equivalent to 'ufw allow 22/tcp'

# Loop through the array of ports and add an "allow" rule for each
echo "Step 2: Adding rules for all specified TCP ports..."
for port in "${ALLOWED_PORTS[@]}"; do
  echo "  -> Allowing port $port/tcp"
  ufw allow "$port/tcp"
done

# Enable the firewall if it's not already active
if ! ufw status | grep -q "Status: active"; then
  echo "Step 3: Firewall is inactive. Enabling UFW..."
  # The '-y' flag automatically answers 'yes' to the confirmation prompt
  ufw --force enable
else
  echo "Step 3: Firewall is already active. Reloading rules..."
  ufw reload
fi

echo ""
echo "--- Configuration complete! ---"
echo "Displaying final firewall status:"
echo ""
ufw status verbose

