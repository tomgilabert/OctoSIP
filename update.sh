#!/bin/bash
# =============================================================================
# OctoSIP Honeypot - Update script
# Run this to pull the latest code and restart services
# Usage: ./update.sh
# =============================================================================

set -e

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
info()  { echo -e "${GREEN}[+]${NC} $1"; }
warn()  { echo -e "${YELLOW}[!]${NC} $1"; }
error() { echo -e "${RED}[x]${NC} $1"; exit 1; }

[ "$EUID" -ne 0 ] && error "Run this script as root"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

info "Pulling latest code from git..."
cd "$SCRIPT_DIR"
git pull origin main

info "Reloading systemd units..."
systemctl daemon-reload

info "Restarting services..."
systemctl restart octosip-api octosip-web

info "Restarting rsyslog (parser reload)..."
systemctl restart rsyslog

sleep 2
systemctl is-active --quiet octosip-api && info "octosip-api:  OK" || warn "octosip-api:  FAIL"
systemctl is-active --quiet octosip-web && info "octosip-web:  OK" || warn "octosip-web:  FAIL"
systemctl is-active --quiet rsyslog     && info "rsyslog:      OK" || warn "rsyslog:      FAIL"

echo ""
info "Update complete."
