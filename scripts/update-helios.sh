#!/usr/bin/env bash
set -Eeuo pipefail

echo "========================================="
echo " Updating Project Helios"
echo "========================================="
echo

echo "Starting update service..."

sudo systemctl start helios-update.service

echo
echo "Update process started."
echo
echo "Logs:"
echo "/var/log/helios-update.log"
echo
echo "Press Enter to close."

read -r
