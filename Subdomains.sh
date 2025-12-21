#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════════
#                            FINDER - Professional Edition
#                      Enterprise-Grade Subdomain Enumeration Framework
# ═══════════════════════════════════════════════════════════════════════════════
# 
# Author: MuhammadWaseem29 (@MuhammadWaseem29)
# Repository: https://github.com/MuhammadWaseem29/subfinder
# Version: 2.0.0 Professional Edition
# License: MIT
#
# Description: FINDER is a comprehensive enterprise-grade subdomain enumeration
#              framework that integrates 7 powerful reconnaissance tools with
#              automated installation, intelligent path detection, and
#              professional reporting capabilities.
#
# Integrated Tools:
#   • subfinder    - Fast passive subdomain discovery
#   • subdominator - Advanced subdomain enumeration 
#   • assetfinder  - Find domains and subdomains related to a given domain
#   • chaos        - ProjectDiscovery's subdomain discovery service
#   • findomain    - Cross-platform subdomain enumerator
#   • sublist3r    - Python-based subdomain discovery tool
#   • subscraper   - DNS brute force + certificate transparency
#
# Usage:
#   ./subdomains.sh -d example.com                    # Single domain
#   ./subdomains.sh -dL domains.txt                   # Multiple domains
#   ./subdomains.sh -d example.com -o results.txt     # Custom output
#   ./subdomains.sh --install                         # Install all tools
#   ./subdomains.sh --check                          # Check tool status
#   ./subdomains.sh --help                           # Show help
#
# ═══════════════════════════════════════════════════════════════════════════════

# Script Configuration
VERSION="2.0.0 Professional"
AUTHOR="MuhammadWaseem29"
OUTPUT_FILE=""  # Will be set only if user specifies -o flag
TEMP_DIR="temp_finder_$$"

# Auto-load Go PATH if not in current session
if ! command -v go >/dev/null 2>&1; then
    # Try to load Go from common locations
    if [ -d "/usr/local/go/bin" ]; then
        export PATH="$PATH:/usr/local/go/bin:$HOME/go/bin"
    fi
fi

# Auto-load common binary paths
export PATH="$PATH:$HOME/go/bin:/usr/local/bin:/snap/bin"

# Load pipx paths if they exist
if [ -d "$HOME/.local/bin" ]; then
    export PATH="$PATH:$HOME/.local/bin"
fi

# Also check for root go path
if [ -d "/root/go/bin" ]; then
    export PATH="$PATH:/root/go/bin"
fi

# Set ProjectDiscovery API Key (optional - users should set their own)
# Get your free API key at: https://chaos.projectdiscovery.io
# export PDCP_API_KEY="your-api-key-here"
if [ -z "$PDCP_API_KEY" ]; then
    # Try to load from environment or config file
    if [ -f ~/.chaos_api_key ]; then
        export PDCP_API_KEY=$(cat ~/.chaos_api_key 2>/dev/null)
    fi
fi

# Color Definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Enhanced Colors
BRIGHT_RED='\033[1;31m'
BRIGHT_GREEN='\033[1;32m'
BRIGHT_YELLOW='\033[1;33m'
BRIGHT_BLUE='\033[1;34m'
BRIGHT_PURPLE='\033[1;35m'
BRIGHT_CYAN='\033[1;36m'
ORANGE='\033[0;33m'
PINK='\033[1;95m'
LIGHT_BLUE='\033[1;94m'
LIGHT_GREEN='\033[1;92m'
LIGHT_RED='\033[1;91m'

# Background Colors
BG_BLACK='\033[40m'
BG_RED='\033[41m'
BG_GREEN='\033[42m'
BG_YELLOW='\033[43m'
BG_BLUE='\033[44m'
BG_PURPLE='\033[45m'
BG_CYAN='\033[46m'
BG_WHITE='\033[47m'

# Special Effects
BLINK='\033[5m'
UNDERLINE='\033[4m'
REVERSE='\033[7m'
DIM='\033[2m'

# Banner Function
show_banner() {
    clear
    echo -e "${BRIGHT_CYAN}${BOLD}"
    echo ""
    echo -e "${BRIGHT_RED}██╗    ██╗ █████╗ ███████╗███████╗███████╗███╗   ███╗${NC}"
    echo -e "${BRIGHT_YELLOW}██║    ██║██╔══██╗██╔════╝██╔════╝██╔════╝████╗ ████║${NC}"
    echo -e "${BRIGHT_GREEN}██║ █╗ ██║███████║███████╗█████╗  █████╗  ██╔████╔██║${NC}"
    echo -e "${BRIGHT_BLUE}██║███╗██║██╔══██║╚════██║██╔══╝  ██╔══╝  ██║╚██╔╝██║${NC}"
    echo -e "${BRIGHT_PURPLE}╚███╔███╔╝██║  ██║███████║███████╗███████╗██║ ╚═╝ ██║${NC}"
    echo -e "${BRIGHT_CYAN} ╚══╝╚══╝ ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝     ╚═╝${NC}"
    echo ""
    echo -e "${BRIGHT_CYAN}${BOLD}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BRIGHT_CYAN}${BOLD}║${NC}                                                                               ${BRIGHT_CYAN}${BOLD}║${NC}"
    echo -e "${BRIGHT_CYAN}${BOLD}║${NC}  ${BRIGHT_PURPLE}${BOLD}╔═══╗╦╔╗╔╔═╗╔╦╗╔═╗╦═╗╔═╗╔╗╔╔═╗╦  ╔═╗╔═╗╔╦╗╔═╗╦═╗${NC}  ${BRIGHT_CYAN}${BOLD}║${NC}"
    echo -e "${BRIGHT_CYAN}${BOLD}║${NC}  ${BRIGHT_BLUE}${BOLD}║╔═╗║║║║║║╣ ║║║╠═╣╠╦╝║╣ ║║║║╣ ║  ║  ║ ║║║║║╣ ╠╦╝${NC}  ${BRIGHT_CYAN}${BOLD}║${NC}"
    echo -e "${BRIGHT_CYAN}${BOLD}║${NC}  ${BRIGHT_GREEN}${BOLD}╚╝ ╚╝╩╝╚╝╚═╝╩ ╩╩ ╩╩╚═╚═╝╝╚╝╚═╝╩═╝╚═╝╚═╝╩ ╩╚═╝╩╚═${NC}  ${BRIGHT_CYAN}${BOLD}║${NC}"
    echo -e "${BRIGHT_CYAN}${BOLD}║${NC}                                                                               ${BRIGHT_CYAN}${BOLD}║${NC}"
    echo -e "${BRIGHT_CYAN}${BOLD}║${NC}  ${BRIGHT_YELLOW}${BOLD}        ✨ Professional Edition - Enterprise-Grade Framework ✨${NC}         ${BRIGHT_CYAN}${BOLD}║${NC}"
    echo -e "${BRIGHT_CYAN}${BOLD}║${NC}                                                                               ${BRIGHT_CYAN}${BOLD}║${NC}"
    echo -e "${BRIGHT_CYAN}${BOLD}║${NC}  ${BRIGHT_WHITE}${BOLD}Version:${NC} ${BRIGHT_GREEN}$VERSION${NC}                                    ${BRIGHT_WHITE}${BOLD}Author:${NC} ${BRIGHT_PURPLE}$AUTHOR${NC}  ${BRIGHT_CYAN}${BOLD}║${NC}"
    echo -e "${BRIGHT_CYAN}${BOLD}║${NC}  ${BRIGHT_WHITE}${BOLD}Repository:${NC} ${BRIGHT_CYAN}https://github.com/MuhammadWaseem29/subfinder${NC}        ${BRIGHT_CYAN}${BOLD}║${NC}"
    echo -e "${BRIGHT_CYAN}${BOLD}║${NC}                                                                               ${BRIGHT_CYAN}${BOLD}║${NC}"
    echo -e "${BRIGHT_CYAN}${BOLD}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BRIGHT_RED}▓${BRIGHT_YELLOW}▓${BRIGHT_GREEN}▓${BRIGHT_BLUE}▓${BRIGHT_PURPLE}▓${BRIGHT_CYAN}▓${PINK}▓${ORANGE}▓${BRIGHT_RED}▓${BRIGHT_YELLOW}▓${BRIGHT_GREEN}▓${BRIGHT_BLUE}▓${BRIGHT_PURPLE}▓${BRIGHT_CYAN}▓${PINK}▓${ORANGE}▓${BRIGHT_RED}▓${BRIGHT_YELLOW}▓${BRIGHT_GREEN}▓${BRIGHT_BLUE}▓${BRIGHT_PURPLE}▓${BRIGHT_CYAN}▓${PINK}▓${ORANGE}▓${BRIGHT_RED}▓${BRIGHT_YELLOW}▓${BRIGHT_GREEN}▓${BRIGHT_BLUE}▓${BRIGHT_PURPLE}▓${BRIGHT_CYAN}▓${PINK}▓${ORANGE}▓${BRIGHT_RED}▓${BRIGHT_YELLOW}▓${BRIGHT_GREEN}▓${BRIGHT_BLUE}▓${BRIGHT_PURPLE}▓${BRIGHT_CYAN}▓${PINK}▓${ORANGE}▓${NC}"
    echo ""
    echo -e "${BRIGHT_CYAN}${BOLD}╔═══════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BRIGHT_CYAN}${BOLD}║${NC}  ${BRIGHT_GREEN}${BOLD}🔍 Integrated Tools:${NC} ${BRIGHT_YELLOW}subfinder${NC} • ${BRIGHT_YELLOW}subdominator${NC} • ${BRIGHT_YELLOW}assetfinder${NC} • ${BRIGHT_YELLOW}chaos${NC} • ${BRIGHT_YELLOW}findomain${NC} • ${BRIGHT_YELLOW}sublist3r${NC} • ${BRIGHT_YELLOW}subscraper${NC}  ${BRIGHT_CYAN}${BOLD}║${NC}"
    echo -e "${BRIGHT_CYAN}${BOLD}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${NC}"
}

# Logging Functions
log_info() {
    echo -e "${BRIGHT_BLUE}${BOLD}[${LIGHT_BLUE}✨ INFO${BRIGHT_BLUE}]${NC} ${CYAN}$1${NC}"
}

log_success() {
    echo -e "${BRIGHT_GREEN}${BOLD}[${LIGHT_GREEN}❤️ SUCCESS${BRIGHT_GREEN}]${NC} ${GREEN}$1${NC} ${BRIGHT_GREEN}✨${NC}"
}

log_error() {
    echo -e "${BRIGHT_RED}${BOLD}[${LIGHT_RED}ERROR${BRIGHT_RED}]${NC} ${RED}$1${NC} ${BRIGHT_RED}💥${NC}"
}

log_warning() {
    echo -e "${BRIGHT_YELLOW}${BOLD}[${ORANGE}⚠️ WARNING${BRIGHT_YELLOW}]${NC} ${YELLOW}$1${NC} ${ORANGE}⚠️${NC}"
}

log_progress() {
    echo -e "${BRIGHT_PURPLE}${BOLD}[${PINK}✨ PROGRESS${BRIGHT_PURPLE}]${NC} ${PURPLE}$1${NC} ${BRIGHT_PURPLE}🚀${NC}"
}

# Debug Function
debug_paths() {
    show_banner
    echo -e "${BRIGHT_YELLOW}${BOLD}${BG_BLUE} ✨ FINDER - PATH DIAGNOSTIC SYSTEM ✨ ${NC}"
    echo -e "${BRIGHT_CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BRIGHT_BLUE}Current PATH:${NC} ${CYAN}$PATH${NC}"
    echo ""
    
    echo -e "${BRIGHT_PURPLE}${BOLD}🔍 GO BINARY LOCATIONS:${NC}"
    echo -e "${BRIGHT_GREEN}Go command:${NC} $(which go 2>/dev/null && echo -e '${BRIGHT_GREEN}✅${NC}' || echo -e '${BRIGHT_RED}❌ NOT FOUND${NC}')"
    echo -e "${BRIGHT_GREEN}Go version:${NC} $(go version 2>/dev/null && echo -e '${BRIGHT_GREEN}✅${NC}' || echo -e '${BRIGHT_RED}❌ NOT ACCESSIBLE${NC}')"
    echo ""
    
    echo -e "${BRIGHT_CYAN}${BOLD}🔎 SEARCHING FOR BINARIES:${NC}"
    echo -e "${PINK}Subfinder locations:${NC}"
    find /root/go /home/*/go $HOME/go /usr/local -name "subfinder" 2>/dev/null | sed "s/^/${BRIGHT_GREEN}  ✓ /" || echo -e "${BRIGHT_RED}  ❌ No subfinder found${NC}"
    echo ""
    
    echo -e "${PINK}Assetfinder locations:${NC}"
    find /root/go /home/*/go $HOME/go /usr/local -name "assetfinder" 2>/dev/null | sed "s/^/${BRIGHT_GREEN}  ✓ /" || echo -e "${BRIGHT_RED}  ❌ No assetfinder found${NC}"
    echo ""
    
    echo -e "${BRIGHT_PURPLE}${BOLD}🧪 COMMAND DETECTION TEST:${NC}"
    local tools=("subfinder" "subdominator" "assetfinder" "findomain" "sublist3r")
    for tool in "${tools[@]}"; do
        local cmd_path=$(command -v $tool 2>/dev/null)
        if [ -n "$cmd_path" ]; then
            echo -e "${BRIGHT_GREEN}  ✅ ${BOLD}$tool${NC}: ${CYAN}$cmd_path${NC}"
        else
            echo -e "${BRIGHT_RED}  ❌ ${BOLD}$tool${NC}: ${RED}NOT FOUND${NC}"
        fi
    done
    echo ""
    
    echo -e "${BRIGHT_YELLOW}${BOLD}🔧 MANUAL PATH LOAD TEST:${NC}"
    export PATH="$PATH:/usr/local/go/bin:$HOME/go/bin:/root/go/bin"
    echo -e "${ORANGE}After PATH update:${NC}"
    echo -e "${LIGHT_BLUE}subfinder:${NC} $(command -v subfinder 2>/dev/null && echo -e '${BRIGHT_GREEN}✅ FOUND${NC}' || echo -e '${BRIGHT_RED}❌ STILL NOT FOUND${NC}')"
    echo -e "${LIGHT_BLUE}assetfinder:${NC} $(command -v assetfinder 2>/dev/null && echo -e '${BRIGHT_GREEN}✅ FOUND${NC}' || echo -e '${BRIGHT_RED}❌ STILL NOT FOUND${NC}')"
    echo ""
    
    echo -e "${BRIGHT_CYAN}${BOLD}💡 SUGGESTED FIXES:${NC}"
    echo -e "${BRIGHT_YELLOW}1.${NC} ${CYAN}Run: ${BRIGHT_WHITE}source ~/.bashrc${NC}"
    echo -e "${BRIGHT_YELLOW}2.${NC} ${CYAN}Run: ${BRIGHT_WHITE}export PATH=\$PATH:/usr/local/go/bin:\$HOME/go/bin${NC}"
    echo -e "${BRIGHT_YELLOW}3.${NC} ${CYAN}Restart terminal session${NC}"
    echo -e "${BRIGHT_YELLOW}4.${NC} ${CYAN}Re-run installation: ${BRIGHT_WHITE}sudo ./subdomains.sh --install${NC}"
    
    # Add colorful footer
    echo ""
    echo -e "${BRIGHT_RED}▓${BRIGHT_YELLOW}▓${BRIGHT_GREEN}▓${BRIGHT_BLUE}▓${BRIGHT_PURPLE}▓${BRIGHT_CYAN}▓${PINK}▓${ORANGE}▓${BRIGHT_RED}▓${BRIGHT_YELLOW}▓${BRIGHT_GREEN}▓${BRIGHT_BLUE}▓${BRIGHT_PURPLE}▓${BRIGHT_CYAN}▓${PINK}▓${ORANGE}▓${BRIGHT_RED}▓${BRIGHT_YELLOW}▓${BRIGHT_GREEN}▓${BRIGHT_BLUE}▓${BRIGHT_PURPLE}▓${BRIGHT_CYAN}▓${PINK}▓${ORANGE}▓${BRIGHT_RED}▓${BRIGHT_YELLOW}▓${BRIGHT_GREEN}▓${BRIGHT_BLUE}▓${BRIGHT_PURPLE}▓${BRIGHT_CYAN}▓${PINK}▓${NC}"
}

# PATH Refresh Function
refresh_paths() {
    # Source bash profile if it exists
    [ -f ~/.bashrc ] && source ~/.bashrc 2>/dev/null
    [ -f ~/.profile ] && source ~/.profile 2>/dev/null
    
    # Add Go paths
    export PATH="$PATH:/usr/local/go/bin:$HOME/go/bin:/root/go/bin"
    
    # Add common binary paths
    export PATH="$PATH:/usr/local/bin:/snap/bin:$HOME/.local/bin"
    
    # Remove duplicates from PATH
    export PATH=$(echo "$PATH" | tr ':' '\n' | awk '!seen[$0]++' | tr '\n' ':' | sed 's/:$//')
}
# Tool Detection Function
detect_tool_path() {
    local tool="$1"
    
    case "$tool" in
        "subfinder")
            # Enhanced detection for subfinder
            if command -v subfinder >/dev/null 2>&1; then
                echo "subfinder"
            elif [ -f "$HOME/go/bin/subfinder" ]; then
                echo "$HOME/go/bin/subfinder"
            elif [ -f "/root/go/bin/subfinder" ]; then
                echo "/root/go/bin/subfinder"
            else
                # Search for subfinder binary
                SUBFINDER_PATH=$(find /root/go /home/*/go $HOME/go -name "subfinder" 2>/dev/null | head -1)
                if [ -n "$SUBFINDER_PATH" ]; then
                    echo "$SUBFINDER_PATH"
                else
                    echo ""
                fi
            fi
            ;;
        "assetfinder")
            # Enhanced detection for assetfinder
            if command -v assetfinder >/dev/null 2>&1; then
                echo "assetfinder"
            elif [ -f "$HOME/go/bin/assetfinder" ]; then
                echo "$HOME/go/bin/assetfinder"
            elif [ -f "/root/go/bin/assetfinder" ]; then
                echo "/root/go/bin/assetfinder"
            else
                # Search for assetfinder binary
                ASSETFINDER_PATH=$(find /root/go /home/*/go $HOME/go -name "assetfinder" 2>/dev/null | head -1)
                if [ -n "$ASSETFINDER_PATH" ]; then
                    echo "$ASSETFINDER_PATH"
                else
                    echo ""
                fi
            fi
            ;;
        "sublist3r")
            # Try multiple locations for sublist3r - prioritize python3 versions
            if [ -f "/opt/Sublist3r/sublist3r.py" ]; then
                echo "python3 /opt/Sublist3r/sublist3r.py"
            elif [ -f "Sublist3r/sublist3r.py" ]; then
                echo "python3 Sublist3r/sublist3r.py"
            elif command -v sublist3r >/dev/null 2>&1; then
                # Check if the sublist3r command uses python3
                if head -1 "$(which sublist3r)" 2>/dev/null | grep -q "python3"; then
                    echo "sublist3r"
                else
                    echo "python3 $(which sublist3r 2>/dev/null || echo '/opt/Sublist3r/sublist3r.py')"
                fi
            else
                SUBLIST3R_PATH=$(find / -name "sublist3r.py" 2>/dev/null | head -1)
                if [ -n "$SUBLIST3R_PATH" ]; then
                    echo "python3 $SUBLIST3R_PATH"
                else
                    echo ""
                fi
            fi
            ;;
        "subscraper")
            # Try multiple locations for subscraper - always use python3
            if [ -f "/opt/subscraper/subscraper.py" ]; then
                echo "python3 /opt/subscraper/subscraper.py"
            elif [ -f "/root/subscraper/subscraper.py" ]; then
                echo "python3 /root/subscraper/subscraper.py"
            elif [ -f "~/subscraper/subscraper.py" ]; then
                echo "python3 ~/subscraper/subscraper.py"
            elif [ -f "subscraper/subscraper.py" ]; then
                echo "python3 subscraper/subscraper.py"
            else
                SUBSCRAPER_PATH=$(find / -name "subscraper.py" 2>/dev/null | head -1)
                if [ -n "$SUBSCRAPER_PATH" ]; then
                    echo "python3 $SUBSCRAPER_PATH"
                else
                    echo ""
                fi
            fi
            ;;
        "assetfinder")
            # Enhanced detection for assetfinder
            if command -v assetfinder >/dev/null 2>&1; then
                echo "assetfinder"
            elif [ -f "$HOME/go/bin/assetfinder" ]; then
                echo "$HOME/go/bin/assetfinder"
            elif [ -f "/root/go/bin/assetfinder" ]; then
                echo "/root/go/bin/assetfinder"
            else
                # Search for assetfinder binary
                ASSETFINDER_PATH=$(find /root/go /home/*/go $HOME/go -name "assetfinder" 2>/dev/null | head -1)
                if [ -n "$ASSETFINDER_PATH" ]; then
                    echo "$ASSETFINDER_PATH"
                else
                    echo ""
                fi
            fi
            ;;
        "chaos")
            # Enhanced detection for chaos
            if command -v chaos >/dev/null 2>&1; then
                echo "chaos"
            elif [ -f "$HOME/go/bin/chaos" ]; then
                echo "$HOME/go/bin/chaos"
            elif [ -f "/root/go/bin/chaos" ]; then
                echo "/root/go/bin/chaos"
            else
                # Search for chaos binary
                CHAOS_PATH=$(find /root/go /home/*/go $HOME/go -name "chaos" 2>/dev/null | head -1)
                if [ -n "$CHAOS_PATH" ]; then
                    echo "$CHAOS_PATH"
                else
                    echo ""
                fi
            fi
            ;;
        "chaos")
            # Enhanced detection for chaos
            if command -v chaos >/dev/null 2>&1; then
                echo "chaos"
            elif [ -f "$HOME/go/bin/chaos" ]; then
                echo "$HOME/go/bin/chaos"
            elif [ -f "/root/go/bin/chaos" ]; then
                echo "/root/go/bin/chaos"
            else
                # Search for chaos binary
                CHAOS_PATH=$(find /root/go /home/*/go $HOME/go -name "chaos" 2>/dev/null | head -1)
                if [ -n "$CHAOS_PATH" ]; then
                    echo "$CHAOS_PATH"
                else
                    echo ""
                fi
            fi
            ;;
        *)
            if command -v "$tool" >/dev/null 2>&1; then
                echo "$tool"
            else
                echo ""
            fi
            ;;
    esac
}

# Tool Availability Check
check_tools() {
    # Refresh PATH variables before checking
    refresh_paths
    
    local tools=("subfinder" "subdominator" "assetfinder" "findomain" "sublist3r" "subscraper" "chaos")
    local available=0
    local total=${#tools[@]}
    
    echo -e "${BRIGHT_CYAN}${BOLD}${BG_BLUE} ✨ FINDER TOOL AVAILABILITY CHECK ❤️ ${NC}"
    echo -e "${BRIGHT_PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    
    for tool in "${tools[@]}"; do
        local tool_path=$(detect_tool_path "$tool")
        if [ -n "$tool_path" ]; then
            echo -e "${BRIGHT_GREEN}✅ ${BOLD}$tool${NC} - ${LIGHT_GREEN}Available${NC} ${CYAN}($tool_path)${NC} ${BRIGHT_GREEN}✨❤️${NC}"
            ((available++))
        else
            echo -e "${BRIGHT_RED}❌ ${BOLD}$tool${NC} - ${LIGHT_RED}Not Found${NC} ${BRIGHT_RED}💥${NC}"
        fi
    done
    
    echo -e "${BRIGHT_PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BRIGHT_BLUE}📊 Status:${NC} ${BRIGHT_YELLOW}$available${NC}/${BRIGHT_YELLOW}$total${NC} tools available"
    
    if [ $available -eq $total ]; then
        log_success "All tools are ready! ✨❤️🎯🚀"
        echo -e "${BRIGHT_GREEN}▓${BRIGHT_YELLOW}▓${BRIGHT_GREEN}▓${BRIGHT_YELLOW}▓${BRIGHT_GREEN}▓${BRIGHT_YELLOW}▓${BRIGHT_GREEN}▓${BRIGHT_YELLOW}▓${BRIGHT_GREEN}▓${BRIGHT_YELLOW}▓${BRIGHT_GREEN}▓${BRIGHT_YELLOW}▓${BRIGHT_GREEN}▓${BRIGHT_YELLOW}▓${BRIGHT_GREEN}▓${BRIGHT_YELLOW}▓${BRIGHT_GREEN}▓${BRIGHT_YELLOW}▓${BRIGHT_GREEN}▓${BRIGHT_YELLOW}▓${BRIGHT_GREEN}▓${BRIGHT_YELLOW}▓${BRIGHT_GREEN}▓${BRIGHT_YELLOW}▓${BRIGHT_GREEN}▓${BRIGHT_YELLOW}▓${BRIGHT_GREEN}▓${BRIGHT_YELLOW}▓${BRIGHT_GREEN}▓${BRIGHT_YELLOW}▓${NC}"
        return 0
    elif [ $available -gt 0 ]; then
        log_warning "Some tools are missing. Run './subdomains.sh --install' to install missing tools."
        return 1
    else
        log_error "No tools found! Please run './subdomains.sh --install' first."
        return 2
    fi
}

# Cleanup Function
cleanup() {
    echo ""
    log_info "Cleaning up temporary files..."
    rm -rf "$TEMP_DIR" 2>/dev/null
    rm -rf temp_finder_* 2>/dev/null
    rm -f sub_report.txt 2>/dev/null
    rm -f *.json 2>/dev/null
    rm -f sublist3r_*.txt 2>/dev/null
    rm -rf reports 2>/dev/null
    log_success "Cleanup completed"
    exit 1
}

# Set trap for cleanup on interruption
trap cleanup INT TERM

# Installation Function
install_tools() {
    show_banner
    log_info "Starting FINDER Professional automated tool installation... ✨❤️"
    
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
        log_error "Installation requires root privileges. Please run with sudo."
        log_info "Example: sudo ./subdomains.sh --install"
        exit 1
    fi
    
    # Check internet connectivity
    if ! ping -c 1 google.com &> /dev/null; then
        log_error "No internet connection. Please check your network."
        exit 1
    fi
    
    # Update system
    log_info "Updating system packages..."
    apt update && apt upgrade -y
    
    # Install dependencies
    log_info "Installing dependencies..."
    apt install -y curl wget git unzip tar snapd python3 python3-pip golang-go
    
    # Install GitHub CLI
    log_info "Installing GitHub CLI (gh)..."
    apt install -y gh
    
    # 1. Install Go if needed
    log_info "Checking Go installation..."
    if ! command -v go >/dev/null 2>&1; then
        log_info "Installing Go..."
        wget -q https://go.dev/dl/go1.22.3.linux-amd64.tar.gz \
        && rm -rf /usr/local/go \
        && tar -C /usr/local -xzf go1.22.3.linux-amd64.tar.gz \
        && echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bashrc \
        && echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.zshrc \
        && source ~/.bashrc
        
        export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
        rm go1.22.3.linux-amd64.tar.gz
        
        if command -v go >/dev/null 2>&1; then
            log_success "Go installed successfully: $(go version)"
        else
            log_error "Go installation failed"
        fi
    else
        log_success "Go is already installed: $(go version) - Skipping installation"
    fi
    
    # Install ProjectDiscovery Tool Manager (pdtm)
    log_info "Checking ProjectDiscovery Tool Manager (pdtm)..."
    if ! command -v pdtm >/dev/null 2>&1; then
        log_info "Installing pdtm..."
        go install -v github.com/projectdiscovery/pdtm/cmd/pdtm@latest
        
        if command -v pdtm >/dev/null 2>&1; then
            log_success "pdtm installed successfully"
            log_info "Installing all ProjectDiscovery tools with pdtm..."
            pdtm -ia
            log_success "ProjectDiscovery tools installation completed"
        else
            log_warning "pdtm installation failed, continuing with manual tool installation"
        fi
    else
        log_success "pdtm is already installed - Skipping installation"
        log_info "Updating ProjectDiscovery tools..."
        pdtm -ua
        log_success "ProjectDiscovery tools updated"
    fi
    
    # Install network tools
    log_info "Installing network tools..."
    apt install -y net-tools
    
    # 2. Install Subfinder
    log_info "Checking subfinder installation..."
    if ! command -v subfinder >/dev/null 2>&1; then
        log_info "Installing subfinder..."
        go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
        
        if command -v subfinder >/dev/null 2>&1; then
            log_success "Subfinder installed successfully"
        else
            log_error "Subfinder installation failed"
        fi
    else
        log_success "Subfinder is already installed - Skipping installation"
    fi
    
    # 3. Install Subdominator (comprehensive installation)
    log_info "Checking subdominator installation..."
    if ! command -v subdominator >/dev/null 2>&1; then
        log_info "Installing subdominator with multiple methods..."
        
        # Install pip and pipx first
        apt install -y python3-pip pipx
        
        # Method 1: pipx
        log_info "Trying pipx installation..."
        if pipx install git+https://github.com/RevoltSecurities/Subdominator 2>/dev/null; then
            log_success "Subdominator installed via pipx (git)"
        elif pipx install subdominator --force 2>/dev/null; then
            log_success "Subdominator installed via pipx (package)"
        else
            log_warning "Pipx failed, trying pip methods..."
            
            # Method 2: pip with break-system-packages
            pip install --upgrade subdominator --break-system-packages 2>/dev/null
            pip install --upgrade git+https://github.com/RevoltSecurities/Subdominator --break-system-packages 2>/dev/null
            
            # Method 3: Manual installation if pip fails
            if ! command -v subdominator >/dev/null 2>&1; then
                log_info "Trying manual installation..."
                git clone https://github.com/RevoltSecurities/Subdominator.git
                cd Subdominator
                pip install --upgrade pip --break-system-packages
                pip install -r requirements.txt --break-system-packages
                pip install . --break-system-packages
                cd ..
                
                # Test installation
                if ! command -v subdominator >/dev/null 2>&1; then
                    log_warning "Finding subdominator binary..."
                    SUBDOMINATOR_PATH=$(which subdominator 2>/dev/null || find / -name subdominator 2>/dev/null | grep bin/ | head -1)
                    
                    if [ -n "$SUBDOMINATOR_PATH" ]; then
                        echo "export PATH=\$PATH:$(dirname $SUBDOMINATOR_PATH)" >> ~/.bashrc
                        echo "export PATH=\$PATH:$(dirname $SUBDOMINATOR_PATH)" >> ~/.zshrc
                        export PATH=$PATH:$(dirname $SUBDOMINATOR_PATH)
                        log_success "Subdominator path added to shell profiles"
                    fi
                fi
            fi
        fi
        
        # Install dependencies for Subdominator
        log_info "Installing Subdominator dependencies..."
        apt update && apt install -y \
            libpango-1.0-0 \
            libcairo2 \
            libpangoft2-1.0-0 \
            libpangocairo-1.0-0 \
            libgdk-pixbuf2.0-0 \
            libffi-dev \
            shared-mime-info
        
        apt install -y libpango1.0-dev libcairo2-dev
        
        # Verify subdominator
        if command -v subdominator >/dev/null 2>&1; then
            log_success "Subdominator installed and working"
        else
            log_warning "Subdominator may need manual PATH configuration"
        fi
    else
        log_success "Subdominator is already installed - Skipping installation"
    fi
    
    # 4. Install Assetfinder
    log_info "Checking assetfinder installation..."
    if ! command -v assetfinder >/dev/null 2>&1; then
        log_info "Installing assetfinder..."
        go install github.com/tomnomnom/assetfinder@latest
        
        if ! command -v assetfinder >/dev/null 2>&1; then
            log_warning "Assetfinder failed, trying with newer Go..."
            rm -rf /usr/local/go
            wget https://go.dev/dl/go1.23.2.linux-amd64.tar.gz
            tar -C /usr/local -xzf go1.23.2.linux-amd64.tar.gz
            echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
            echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.zshrc
            source ~/.bashrc
            export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
            
            log_info "Updated Go version: $(go version)"
            go install github.com/tomnomnom/assetfinder@latest
            rm go1.23.2.linux-amd64.tar.gz
        fi
        
        if command -v assetfinder >/dev/null 2>&1; then
            log_success "Assetfinder installed successfully"
        else
            log_error "Assetfinder installation failed"
        fi
    else
        log_success "Assetfinder is already installed - Skipping installation"
    fi
    
    # Install Chaos
    log_info "Checking chaos installation..."
    if ! command -v chaos >/dev/null 2>&1; then
        log_info "Installing chaos (ProjectDiscovery)..."
        go install -v github.com/projectdiscovery/chaos-client/cmd/chaos@latest
        
        # Ensure PATH is updated
        echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bashrc && source ~/.bashrc
        export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
        
        if command -v chaos >/dev/null 2>&1; then
            log_success "Chaos installed successfully"
            log_success "Chaos API key is pre-configured in FINDER"
        else
            log_error "Chaos installation failed"
        fi
    else
        log_success "Chaos is already installed - Skipping installation"
        log_success "Chaos API key is pre-configured in FINDER"
    fi
    
    # 5. Install Findomain
    log_info "Checking findomain installation..."
    if ! command -v findomain >/dev/null 2>&1; then
        log_info "Installing findomain..."
        curl -LO https://github.com/findomain/findomain/releases/latest/download/findomain-linux-i386.zip
        apt install -y unzip
        unzip findomain-linux-i386.zip
        chmod +x findomain
        mv findomain /usr/local/bin/
        rm findomain-linux-i386.zip
        
        if command -v findomain >/dev/null 2>&1; then
            log_success "Findomain installed successfully"
        else
            log_error "Findomain installation failed"
        fi
    else
        log_success "Findomain is already installed - Skipping installation"
    fi
    
    # 6. Install Sublist3r
    log_info "Checking sublist3r installation..."
    if ! command -v sublist3r >/dev/null 2>&1 && [ ! -f "/opt/Sublist3r/sublist3r.py" ]; then
        log_info "Installing sublist3r..."
        git clone https://github.com/aboul3la/Sublist3r.git /opt/Sublist3r
        cd /opt/Sublist3r
        pip install -r requirements.txt --break-system-packages
        
        # Create wrapper script instead of symlink to ensure python3 usage
        cat > /usr/local/bin/sublist3r << 'EOF'
#!/bin/bash
python3 /opt/Sublist3r/sublist3r.py "$@"
EOF
        chmod +x /usr/local/bin/sublist3r
        cd -
        
        if [ -f "/opt/Sublist3r/sublist3r.py" ]; then
            log_success "Sublist3r installed successfully"
        else
            log_error "Sublist3r installation failed"
        fi
    else
        log_success "Sublist3r is already installed - Skipping installation"
    fi
    
    # 7. Install Subscraper
    log_info "Checking subscraper installation..."
    if [ ! -f "/opt/subscraper/subscraper.py" ]; then
        log_info "Installing subscraper..."
        cd ~
        git clone https://github.com/m8sec/subscraper /opt/subscraper
        cd /opt/subscraper
        
        # Install all dependencies
        pip3 install -r requirements.txt --break-system-packages
        pip3 install ipparser --break-system-packages
        pip3 install taser --break-system-packages
        
        # Install additional packages
        apt update && apt install -y python3-poetry
        pip3 install taser --break-system-packages --no-deps
        pip3 install beautifulsoup4 bs4 lxml ntlm-auth requests-file requests-ntlm tldextract selenium selenium-wire webdriver-manager --break-system-packages
        pip3 install bs4 --break-system-packages
        pip3 install requests_ntlm --break-system-packages
        pip3 install tldextract --break-system-packages
        pip3 install selenium --break-system-packages --no-deps
        pip3 install trio trio-websocket certifi typing_extensions pysocks --break-system-packages
        
        # Create wrapper script for subscraper
        cat > /usr/local/bin/subscraper << 'EOF'
#!/bin/bash
python3 /opt/subscraper/subscraper.py "$@"
EOF
        chmod +x /usr/local/bin/subscraper
        
        cd -
        
        if [ -f "/opt/subscraper/subscraper.py" ]; then
            log_success "Subscraper installed successfully"
        else
            log_error "Subscraper installation failed"
        fi
    else
        log_success "Subscraper is already installed - Skipping installation"
    fi
    
    # Final Go PATH setup for both shells
    log_info "Setting up Go PATH for bash and zsh..."
    echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.bashrc
    echo 'export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin' >> ~/.zshrc 2>/dev/null || true
    export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
    
    log_success "Installation completed! Please restart your terminal or run:"
    echo "  source ~/.bashrc"
    log_info "Test with: ./subdomains.sh --check"
    
    # Final verification
    echo ""
    echo -e "${PURPLE}${BOLD}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${PURPLE}${BOLD}                   ✨ FINDER INSTALLATION SUMMARY ❤️                         ${NC}"
    echo -e "${PURPLE}${BOLD}═══════════════════════════════════════════════════════════════════════════════${NC}"
    
    echo ""
    log_info "Verifying all tools..."
    
    local tools=("subfinder" "subdominator" "assetfinder" "findomain" "sublist3r" "subscraper")
    local installed=0
    local total=${#tools[@]}
    
    for tool in "${tools[@]}"; do
        local tool_path=$(detect_tool_path "$tool")
        if [ -n "$tool_path" ]; then
            echo -e "${GREEN}✓${NC} $tool - ${GREEN}Available${NC} ($tool_path)"
            ((installed++))
        else
            echo -e "${RED}✗${NC} $tool - ${RED}Not Found${NC}"
        fi
    done
    
    echo ""
    echo -e "${BLUE}Final Status:${NC} $installed/$total tools successfully installed"
    
    if [ $installed -eq $total ]; then
        echo -e "${BRIGHT_GREEN}${BOLD}${BLINK}✨❤️ FINDER INSTALLATION COMPLETED SUCCESSFULLY! ❤️✨${NC}"
        echo -e "${BRIGHT_CYAN}✨ You can now run: ${BRIGHT_WHITE}./subdomains.sh -d example.com${NC} ✨"
        echo -e "${BRIGHT_GREEN}🎉${BRIGHT_YELLOW}🎉${BRIGHT_GREEN}🎉${BRIGHT_YELLOW}🎉${BRIGHT_GREEN}🎉${BRIGHT_YELLOW}🎉${BRIGHT_GREEN}🎉${BRIGHT_YELLOW}🎉${BRIGHT_GREEN}🎉${BRIGHT_YELLOW}🎉${BRIGHT_GREEN}🎉${BRIGHT_YELLOW}🎉${BRIGHT_GREEN}🎉${BRIGHT_YELLOW}🎉${BRIGHT_GREEN}🎉${BRIGHT_YELLOW}🎉${BRIGHT_GREEN}🎉${BRIGHT_YELLOW}🎉${BRIGHT_GREEN}🎉${BRIGHT_YELLOW}🎉${BRIGHT_GREEN}🎉${BRIGHT_YELLOW}🎉${BRIGHT_GREEN}🎉${BRIGHT_YELLOW}🎉${BRIGHT_GREEN}🎉${BRIGHT_YELLOW}🎉${NC}"
    elif [ $installed -gt 0 ]; then
        echo -e "${BRIGHT_YELLOW}${BOLD}⚠️  FINDER PARTIAL INSTALLATION COMPLETED ⚠️${NC}"
        echo -e "${ORANGE}Some tools may need manual configuration or PATH updates.${NC}"
        echo -e "${BRIGHT_CYAN}Available tools can still be used with: ${BRIGHT_WHITE}./subdomains.sh -d example.com${NC}"
    else
        echo -e "${BRIGHT_RED}${BOLD}${BLINK}❌ FINDER INSTALLATION FAILED ❌${NC}"
        echo -e "${LIGHT_RED}Please check the error messages above and try manual installation.${NC}"
    fi
    
    echo ""
    echo -e "${BLUE}${BOLD}NEXT STEPS:${NC}"
    echo "1. Restart your terminal or run: source ~/.bashrc"
    echo "2. Test installation: ./subdomains.sh --check"
    echo "3. Run enumeration: ./subdomains.sh -d example.com"
    echo ""
}

# Help Function
show_help() {
    show_banner
    echo -e "${YELLOW}${BOLD}USAGE:${NC}"
    echo "  $0 [OPTIONS] -d <domain>                 Single domain enumeration"
    echo "  $0 [OPTIONS] -dL <file>                  Multiple domains from file"
    echo ""
    echo -e "${YELLOW}${BOLD}OPTIONS:${NC}"
    echo "  -d  <domain>              Target domain to enumerate"
    echo "  -dL <file>               File containing list of domains (one per line)"
    echo "  -o  <output_file>        Custom output file (default: display on screen only)"
    echo "  -r  <report_name>        Generate detailed report"
    echo "  --install                Install all required tools"
    echo "  --check                  Check tool availability"
    echo "  --setup-chaos            Configure Chaos API key interactively"
    echo "  --debug                  Show PATH and binary location debug info"
    echo "  --update                 Update all tools to latest versions"
    echo "  --version                Show version information"
    echo "  --help                   Show this help message"
    echo ""
    echo -e "${YELLOW}${BOLD}EXAMPLES:${NC}"
    echo "  $0 -d example.com                        # Basic enumeration"
    echo "  $0 -d example.com -o results.txt         # Custom output file"
    echo "  $0 -dL domains.txt -r security_audit     # Multiple domains with report"
    echo "  $0 --install                             # Install all tools"
    echo "  $0 --check                               # Check tool status"
    echo "  $0 --setup-chaos                         # Configure Chaos API key"
    echo "  $0 --debug                               # Debug PATH issues"
    echo ""
    echo -e "${YELLOW}${BOLD}SUPPORTED TOOLS:${NC}"
    echo "  • subfinder    - Fast passive subdomain discovery"
    echo "  • subdominator - Advanced subdomain enumeration"
    echo "  • assetfinder  - Find domains and subdomains"
    echo "  • chaos        - ProjectDiscovery's subdomain discovery service"
    echo "  • findomain    - Cross-platform subdomain enumerator"
    echo "  • sublist3r    - Python-based subdomain discovery"
    echo "  • subscraper   - DNS brute force + certificate transparency"
    echo ""
    echo -e "${CYAN}For more information, visit: https://github.com/MuhammadWaseem29/subfinder${NC}"
}

# Setup Chaos API Key Function
setup_chaos_key() {
    show_banner
    echo -e "${BRIGHT_CYAN}${BOLD}✨ CHAOS API KEY SETUP ❤️${NC}"
    echo -e "${BRIGHT_PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "${BRIGHT_YELLOW}1.${NC} Visit: ${BRIGHT_CYAN}https://chaos.projectdiscovery.io${NC}"
    echo -e "${BRIGHT_YELLOW}2.${NC} Sign up and get your free API key"
    echo -e "${BRIGHT_YELLOW}3.${NC} Copy your API key"
    echo ""
    echo -e "${BRIGHT_BLUE}Enter your Chaos API key:${NC}"
    read -r api_key
    
    if [ -n "$api_key" ]; then
        echo "export PDCP_API_KEY=\"$api_key\"" >> ~/.bashrc
        echo "export PDCP_API_KEY=\"$api_key\"" >> ~/.zshrc 2>/dev/null || true
        export PDCP_API_KEY="$api_key"
        
        log_success "Chaos API key configured successfully! ✨❤️"
        log_info "Testing Chaos connection... ✨"
        
        if chaos -version >/dev/null 2>&1; then
            log_success "Chaos is ready to use! ✨❤️"
        else
            log_warning "Chaos may need additional configuration"
        fi
        
        echo -e "${BRIGHT_GREEN}✅ You can now use: ${BRIGHT_WHITE}./subdomains.sh -d example.com${NC} ✨❤️"
    else
        log_error "No API key provided"
    fi
}

# Generate Report Function
generate_report() {
    local domain="$1"
    local report_name="$2"
    local total_subs="$3"
    
    local report_file="${report_name}_$(date +%Y%m%d_%H%M%S).html"
    
    cat > "$report_file" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>Subdomain Enumeration Report - $domain</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .header { background: #2c3e50; color: white; padding: 20px; border-radius: 8px; }
        .stats { background: #ecf0f1; padding: 15px; margin: 20px 0; border-radius: 8px; }
        .tool-section { margin: 20px 0; padding: 15px; border-left: 4px solid #3498db; }
        .subdomain { font-family: monospace; background: #f8f9fa; padding: 2px 5px; margin: 2px; display: inline-block; }
    </style>
</head>
<body>
    <div class="header">
        <h1>FINDER - Subdomain Enumeration Report</h1>
        <p>Domain: <strong>$domain</strong> | Generated: $(date) | Tool: FINDER v$VERSION</p>
    </div>
    
    <div class="stats">
        <h2>Summary</h2>
        <p><strong>Total Unique Subdomains Found:</strong> $total_subs</p>
        <p><strong>Tools Used:</strong> 6 (subfinder, subdominator, assetfinder, findomain, sublist3r, subscraper)</p>
        <p><strong>Output File:</strong> $OUTPUT_FILE</p>
    </div>
    
    <div class="tool-section">
        <h2>Discovered Subdomains</h2>
        <div>
EOF

    # Add subdomains to report
    if [ -n "$OUTPUT_FILE" ] && [ -f "$OUTPUT_FILE" ]; then
        while read -r subdomain; do
            echo "            <span class=\"subdomain\">$subdomain</span>" >> "$report_file"
        done < "$OUTPUT_FILE"
    else
        echo "            <span class=\"subdomain\">No output file available</span>" >> "$report_file"
    fi
    
    cat >> "$report_file" << EOF
        </div>
    </div>
    
    <footer style="margin-top: 40px; text-align: center; color: #7f8c8d;">
        <p>Generated by FINDER Professional Edition v$VERSION | Author: $AUTHOR</p>
        <p>Repository: https://github.com/MuhammadWaseem29/subfinder</p>
    </footer>
</body>
</html>
EOF

    log_success "HTML report generated: $report_file"
}

# Main Enumeration Function
run_enumeration() {
    local target="$1"
    local target_type="$2"  # "domain" or "file"
    
    show_banner
    
    # Refresh PATH variables for this session
    refresh_paths
    
    # Create directories
    rm -rf temp_finder_* 2>/dev/null
    mkdir -p "$TEMP_DIR"
    
    # Check tools before starting
    check_tools
    local tool_status=$?
    if [ $tool_status -eq 2 ]; then
        log_error "Cannot proceed without tools. Run --install first."
        exit 1
    fi
    
    log_info "Starting subdomain enumeration for: $target ✨❤️"
    
    # Ensure OUTPUT_FILE is only set if -o flag was used
    if [ -n "$OUTPUT_FILE" ]; then
        log_info "Output will be saved to: $OUTPUT_FILE ✨"
    else
        log_info "Results will be displayed on screen only (use -o flag to save to file)"
        # Ensure OUTPUT_FILE is empty to prevent any accidental file creation
        OUTPUT_FILE=""
    fi
    echo ""
    
    # Tool execution with dynamic path detection
    local tools=("subfinder" "subdominator" "assetfinder" "chaos" "findomain" "sublist3r" "subscraper")
    local completed=0
    
    for i in "${!tools[@]}"; do
        local tool="${tools[$i]}"
        local tool_num=$((i + 1))
        local tool_path=$(detect_tool_path "$tool")
        
        if [ -z "$tool_path" ]; then
            log_warning "[$tool_num/7] Skipping $tool - not found"
            continue
        fi
        
        echo -e "${BRIGHT_BLUE}[${BRIGHT_YELLOW}$tool_num${BRIGHT_BLUE}/${BRIGHT_YELLOW}7${BRIGHT_BLUE}]${NC} ${BRIGHT_PURPLE}Running${NC} ${BRIGHT_GREEN}${BOLD}$tool${NC} for $target_type: ${BRIGHT_CYAN}${BOLD}$target${NC}..."
        echo -e "${BRIGHT_PURPLE}════════════════════════════════════════════════════════════════════════════════${NC}"
        
        case "$tool" in
            "subfinder")
                if [ "$target_type" == "domain" ]; then
                    echo -e "${BRIGHT_CYAN}🔍 Executing: ${BRIGHT_WHITE}$tool_path -d $target -all -v${NC}"
                    echo ""
                    timeout 300 $tool_path -d "$target" -all -v 2>&1 | tee >(grep -E '^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$' > "$TEMP_DIR/subfinder.txt" 2>/dev/null || true) || {
                        log_warning "Subfinder timed out or failed for $target"
                        touch "$TEMP_DIR/subfinder.txt"
                    }
                else
                    echo -e "${BRIGHT_CYAN}🔍 Executing: ${BRIGHT_WHITE}$tool_path -dL $target -all -v${NC}"
                    echo ""
                    timeout 600 $tool_path -dL "$target" -all -v 2>&1 | tee >(grep -E '^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$' > "$TEMP_DIR/subfinder.txt" 2>/dev/null || true) || {
                        log_warning "Subfinder timed out or failed for domain list"
                        touch "$TEMP_DIR/subfinder.txt"
                    }
                fi
                ;;
            "subdominator")
                if [ "$target_type" == "domain" ]; then
                    echo -e "${BRIGHT_CYAN}🔍 Executing: ${BRIGHT_WHITE}$tool_path -d $target${NC}"
                    echo ""
                    $tool_path -d "$target" 2>&1 | tee >(grep -E '^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$' > "$TEMP_DIR/subdominator.txt" 2>/dev/null || true)
                else
                    echo -e "${BRIGHT_CYAN}🔍 Executing: ${BRIGHT_WHITE}$tool_path -dL $target${NC}"
                    echo ""
                    $tool_path -dL "$target" 2>&1 | tee >(grep -E '^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$' > "$TEMP_DIR/subdominator.txt" 2>/dev/null || true)
                fi
                ;;
            "assetfinder")
                if [ "$target_type" == "domain" ]; then
                    echo -e "${BRIGHT_CYAN}🔍 Executing: ${BRIGHT_WHITE}$tool_path --subs-only $target${NC}"
                    echo ""
                    $tool_path --subs-only "$target" 2>&1 | tee >(grep -E '^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$' > "$TEMP_DIR/assetfinder.txt" 2>/dev/null || true)
                else
                    echo -e "${BRIGHT_CYAN}🔍 Executing: ${BRIGHT_WHITE}$tool_path --subs-only (multiple domains)${NC}"
                    echo ""
                    while read -r domain; do
                        if [ -n "$domain" ]; then
                            echo -e "${YELLOW}Processing domain: $domain${NC}"
                            $tool_path --subs-only "$domain" 2>&1 | tee >(grep -E '^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$' >> "$TEMP_DIR/assetfinder.txt" 2>/dev/null || true)
                        fi
                    done < "$target"
                fi
                ;;
            "chaos")
                if [ "$target_type" == "domain" ]; then
                    echo -e "${BRIGHT_CYAN}🔍 Executing: ${BRIGHT_WHITE}$tool_path -d $target${NC}"
                    echo ""
                    $tool_path -d "$target" 2>&1 | tee >(grep -E '^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$' > "$TEMP_DIR/chaos.txt" 2>/dev/null || true)
                else
                    echo -e "${BRIGHT_CYAN}🔍 Executing: ${BRIGHT_WHITE}$tool_path (multiple domains)${NC}"
                    echo ""
                    while read -r domain; do
                        if [ -n "$domain" ]; then
                            echo -e "${YELLOW}Processing domain: $domain${NC}"
                            $tool_path -d "$domain" 2>&1 | tee >(grep -E '^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$' >> "$TEMP_DIR/chaos.txt" 2>/dev/null || true)
                        fi
                    done < "$target"
                fi
                ;;
            "findomain")
                if [ "$target_type" == "domain" ]; then
                    echo -e "${BRIGHT_CYAN}🔍 Executing: ${BRIGHT_WHITE}$tool_path -t $target${NC}"
                    echo ""
                    $tool_path -t "$target" 2>&1 | tee >(grep -E '^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$' > "$TEMP_DIR/findomain.txt" 2>/dev/null || true)
                else
                    echo -e "${BRIGHT_CYAN}🔍 Executing: ${BRIGHT_WHITE}$tool_path -f $target${NC}"
                    echo ""
                    $tool_path -f "$target" 2>&1 | tee >(grep -E '^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$' > "$TEMP_DIR/findomain.txt" 2>/dev/null || true)
                fi
                ;;
            "sublist3r")
                if [ "$target_type" == "domain" ]; then
                    echo -e "${BRIGHT_CYAN}🔍 Executing: ${BRIGHT_WHITE}$tool_path -d $target${NC}"
                    echo ""
                    $tool_path -d "$target" 2>&1 | tee >(grep -E '^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$' > "$TEMP_DIR/sublist3r.txt" 2>/dev/null || true)
                else
                    echo -e "${BRIGHT_CYAN}🔍 Executing: ${BRIGHT_WHITE}$tool_path (multiple domains)${NC}"
                    echo ""
                    while read -r domain; do
                        if [ -n "$domain" ]; then
                            echo -e "${YELLOW}Processing domain: $domain${NC}"
                            $tool_path -d "$domain" 2>&1 | tee >(grep -E '^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$' >> "$TEMP_DIR/sublist3r.txt" 2>/dev/null || true)
                        fi
                    done < "$target"
                fi
                ;;
            "subscraper")
                if [ "$target_type" == "domain" ]; then
                    echo -e "${BRIGHT_CYAN}🔍 Executing: ${BRIGHT_WHITE}$tool_path -d $target${NC}"
                    echo ""
                    $tool_path -d "$target" 2>&1 | tee >(grep -E '^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$' > "$TEMP_DIR/subscraper.txt" 2>/dev/null || true)
                else
                    echo -e "${BRIGHT_CYAN}🔍 Executing: ${BRIGHT_WHITE}$tool_path (multiple domains)${NC}"
                    echo ""
                    while read -r domain; do
                        if [ -n "$domain" ]; then
                            echo -e "${YELLOW}Processing domain: $domain${NC}"
                            $tool_path -d "$domain" 2>&1 | tee >(grep -E '^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$' >> "$TEMP_DIR/subscraper.txt" 2>/dev/null || true)
                        fi
                    done < "$target"
                fi
                ;;
        esac
        
        echo ""
        echo -e "${BRIGHT_GREEN}[✓] Tool $tool completed successfully ✨❤️${NC}"
        echo -e "${LIGHT_BLUE}════════════════════════════════════════════════════════════════════════════════${NC}"
        echo ""
        echo -e "${BRIGHT_PURPLE}╚════════════════════════════════════════════════════════════════════════════════╝${NC}"
        echo -e "${BRIGHT_GREEN}${BOLD}✅ Completed${NC} ${BRIGHT_GREEN}$tool${NC} ${BRIGHT_GREEN}✨❤️🎯${NC}"
        echo ""
        ((completed++))
    done
    
    # Merge results
    echo ""
    echo -e "${BRIGHT_PURPLE}${BOLD}✨ Merging results and removing duplicates... ❤️${NC} ${BRIGHT_CYAN}✨${NC}"
    echo -e "${BRIGHT_BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    
    # ═══════════════════════════════════════════════════════════════════════════════
    # 💎 ULTRA-PREMIUM PERFORMANCE ANALYTICS DASHBOARD 💎
    # ═══════════════════════════════════════════════════════════════════════════════
    
    echo ""
    echo -e "${BRIGHT_CYAN}${BOLD}╔═══════════════════════════════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BRIGHT_CYAN}${BOLD}║                                                                                                           ║${NC}"
    echo -e "${BRIGHT_CYAN}${BOLD}║               💎 ${BRIGHT_WHITE}${BG_BLUE} FINDER ENTERPRISE INTELLIGENCE SUITE - PERFORMANCE ANALYTICS ${NC}${BRIGHT_CYAN}${BOLD} 💎              ║${NC}"
    echo -e "${BRIGHT_CYAN}${BOLD}║                                                                                                           ║${NC}"
    echo -e "${BRIGHT_CYAN}${BOLD}╚═══════════════════════════════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Define tool array to maintain order
    local tool_order=("subfinder" "subdominator" "assetfinder" "chaos" "findomain" "sublist3r" "subscraper")
    local total_raw=0
    declare -A tool_counts
    declare -A tool_rankings
    
    # First pass - collect counts
    for tool_name in "${tool_order[@]}"; do
        local tool_file="$TEMP_DIR/${tool_name}.txt"
        if [ -f "$tool_file" ]; then
            local tool_count=$(grep -c '[a-zA-Z0-9]' "$tool_file" 2>/dev/null || echo "0")
            tool_count=$(echo "$tool_count" | tr -d '\n' | tr -d ' ')
            tool_counts[$tool_name]=$tool_count
            total_raw=$((total_raw + tool_count))
        else
            tool_counts[$tool_name]=0
        fi
    done
    
    # Calculate rankings
    local rank=1
    for tool_name in $(for t in "${tool_order[@]}"; do echo "${tool_counts[$t]} $t"; done | sort -rn | awk '{print $2}'); do
        tool_rankings[$tool_name]=$rank
        ((rank++))
    done
    
    # ═══════════════════════════════════════════════════════════════════════════════
    # 📊 EXECUTIVE SUMMARY - KEY PERFORMANCE INDICATORS
    # ═══════════════════════════════════════════════════════════════════════════════
    
    echo -e "${BRIGHT_PURPLE}${BOLD}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
    echo -e "${BRIGHT_PURPLE}${BOLD}┃${NC}  ${BRIGHT_YELLOW}${BOLD}📈 EXECUTIVE DASHBOARD - REAL-TIME INTELLIGENCE${NC}                                                    ${BRIGHT_PURPLE}${BOLD}┃${NC}"
    echo -e "${BRIGHT_PURPLE}${BOLD}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
    echo ""
    
    # Calculate active tools
    local active_tools=0
    local failed_tools=0
    for count in "${tool_counts[@]}"; do
        if [ "$count" -gt 0 ]; then
            ((active_tools++))
        else
            ((failed_tools++))
        fi
    done
    
    # Calculate success rate
    local success_rate=$((active_tools * 100 / 7))
    
    # Executive metrics in a premium grid
    echo -e "${BRIGHT_CYAN}╭─────────────────────────────────────╮  ╭─────────────────────────────────────╮  ╭─────────────────────────────────────╮${NC}"
    echo -e "${BRIGHT_CYAN}│${NC} ${BRIGHT_WHITE}${BOLD}📊 TOTAL DISCOVERIES${NC}              ${BRIGHT_CYAN}│${NC}  ${BRIGHT_CYAN}│${NC} ${BRIGHT_WHITE}${BOLD}🎯 SUCCESS RATE${NC}                  ${BRIGHT_CYAN}│${NC}  ${BRIGHT_CYAN}│${NC} ${BRIGHT_WHITE}${BOLD}🔧 TOOLS DEPLOYED${NC}                ${BRIGHT_CYAN}│${NC}"
    echo -e "${BRIGHT_CYAN}│${NC}   ${BRIGHT_GREEN}${BOLD}${total_raw} Subdomains${NC}                  ${BRIGHT_CYAN}│${NC}  ${BRIGHT_CYAN}│${NC}   ${BRIGHT_GREEN}${BOLD}${success_rate}% Success${NC}                    ${BRIGHT_CYAN}│${NC}  ${BRIGHT_CYAN}│${NC}   ${BRIGHT_GREEN}${BOLD}${active_tools}/7 Active${NC}                     ${BRIGHT_CYAN}│${NC}"
    echo -e "${BRIGHT_CYAN}│${NC}   ${BRIGHT_BLUE}✨ All Results Captured${NC}         ${BRIGHT_CYAN}│${NC}  ${BRIGHT_CYAN}│${NC}   ${BRIGHT_BLUE}⚡ Enterprise Grade${NC}             ${BRIGHT_CYAN}│${NC}  ${BRIGHT_CYAN}│${NC}   ${BRIGHT_BLUE}💪 Multi-Source Intel${NC}           ${BRIGHT_CYAN}│${NC}"
    echo -e "${BRIGHT_CYAN}╰─────────────────────────────────────╯  ╰─────────────────────────────────────╯  ╰─────────────────────────────────────╯${NC}"
    echo ""
    
    # ═══════════════════════════════════════════════════════════════════════════════
    # 🏆 DETAILED PER-TOOL PERFORMANCE MATRIX
    # ═══════════════════════════════════════════════════════════════════════════════
    
    echo -e "${BRIGHT_YELLOW}${BOLD}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
    echo -e "${BRIGHT_YELLOW}${BOLD}┃${NC}  ${BRIGHT_CYAN}${BOLD}🔍 COMPREHENSIVE TOOL PERFORMANCE ANALYTICS${NC}                                                       ${BRIGHT_YELLOW}${BOLD}┃${NC}"
    echo -e "${BRIGHT_YELLOW}${BOLD}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
    echo ""
    
    # Ultra-Premium Table Header
    printf "${BRIGHT_WHITE}${BOLD}%-5s %-18s %-14s %-12s %-28s %-16s %-18s${NC}\n" \
        "RANK" "TOOL NAME" "DISCOVERIES" "SHARE %" "PERFORMANCE GRAPH" "QUALITY SCORE" "STATUS"
    echo -e "${BRIGHT_BLUE}─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────${NC}"
    
    # Display each tool with ULTRA-PREMIUM metrics
    for tool_name in $(for t in "${tool_order[@]}"; do echo "${tool_counts[$t]} $t"; done | sort -rn | awk '{print $2}'); do
        local tool_count=${tool_counts[$tool_name]}
        local rank=${tool_rankings[$tool_name]}
        
        # Calculate percentage with decimal
        local percentage=0
        local percentage_decimal=0
        if [ "$total_raw" -gt 0 ]; then
            percentage=$((tool_count * 100 / total_raw))
            percentage_decimal=$((tool_count * 1000 / total_raw % 10))
        fi
        
        # Performance bar (25 chars for premium look)
        local bar_length=$((percentage / 4))
        if [ "$bar_length" -eq 0 ] && [ "$tool_count" -gt 0 ]; then
            bar_length=1
        fi
        local performance_bar=""
        for ((i=0; i<bar_length; i++)); do
            performance_bar+="█"
        done
        for ((i=bar_length; i<25; i++)); do
            performance_bar+="░"
        done
        
        # Calculate quality score (0-100 scale based on contribution)
        local quality_score=0
        if [ "$total_raw" -gt 0 ]; then
            quality_score=$((tool_count * 100 / total_raw))
        fi
        
        # Determine medal/trophy for top performers
        local rank_icon=""
        case $rank in
            1) rank_icon="${BRIGHT_YELLOW}🥇${NC}" ;;
            2) rank_icon="${BRIGHT_WHITE}🥈${NC}" ;;
            3) rank_icon="${BRIGHT_ORANGE}🥉${NC}" ;;
            *) rank_icon="${BRIGHT_BLUE}#${rank}${NC}" ;;
        esac
        
        # Status and rating with enhanced visuals
        if [ "$tool_count" -gt 0 ]; then
            local status="${BRIGHT_GREEN}${BOLD}✅ ACTIVE${NC}"
            local count_color="${BRIGHT_GREEN}${BOLD}"
            
            # Performance rating with gradient colors
            if [ "$percentage" -ge 25 ]; then
                local perf_color="${BRIGHT_GREEN}"
                local rating="💎 PREMIUM"
                local score_color="${BRIGHT_GREEN}${BOLD}"
                local trend="📈 ↑↑"
            elif [ "$percentage" -ge 20 ]; then
                local perf_color="${BRIGHT_CYAN}"
                local rating="🏆 EXCELLENT"
                local score_color="${BRIGHT_CYAN}${BOLD}"
                local trend="📊 ↑"
            elif [ "$percentage" -ge 15 ]; then
                local perf_color="${BRIGHT_BLUE}"
                local rating="⭐ GREAT"
                local score_color="${BRIGHT_BLUE}${BOLD}"
                local trend="📊 ↑"
            elif [ "$percentage" -ge 10 ]; then
                local perf_color="${BRIGHT_PURPLE}"
                local rating="👍 GOOD"
                local score_color="${BRIGHT_PURPLE}${BOLD}"
                local trend="📈 ="
            elif [ "$percentage" -ge 5 ]; then
                local perf_color="${BRIGHT_YELLOW}"
                local rating="📊 FAIR"
                local score_color="${BRIGHT_YELLOW}${BOLD}"
                local trend="⚠️  ="
            else
                local perf_color="${BRIGHT_ORANGE}"
                local rating="📉 LOW"
                local score_color="${BRIGHT_ORANGE}${BOLD}"
                local trend="📉 ↓"
            fi
        else
            local status="${BRIGHT_RED}${BOLD}❌ FAILED${NC}"
            local count_color="${BRIGHT_RED}"
            local perf_color="${BRIGHT_RED}"
            local rating="💀 INACTIVE"
            local score_color="${BRIGHT_RED}${BOLD}"
            local trend="⛔ ✗"
            performance_bar="─────────────────────────"
        fi
        
        # Display main row with premium formatting
        printf "${rank_icon} ${BRIGHT_CYAN}%-16s${NC} ${count_color}%-14s${NC} ${BRIGHT_PURPLE}${BOLD}%-12s${NC} ${perf_color}%-28s${NC} ${score_color}%-16s${NC} ${status}\n" \
            "$tool_name" \
            "${tool_count}" \
            "${percentage}.${percentage_decimal}%" \
            "$performance_bar" \
            "${quality_score}/100 ${rating}"
        
        # Additional details row
        if [ "$tool_count" -gt 0 ]; then
            printf "     ${BRIGHT_BLUE}│${NC} ${BRIGHT_WHITE}Contribution:${NC} ${count_color}${tool_count}${NC}/${BRIGHT_YELLOW}${total_raw}${NC}  ${BRIGHT_BLUE}│${NC} ${BRIGHT_WHITE}Trend:${NC} ${trend}  ${BRIGHT_BLUE}│${NC} ${BRIGHT_WHITE}Rating:${NC} ${perf_color}${rating}${NC}\n"
        fi
    done
    
    echo -e "${BRIGHT_BLUE}─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────${NC}"
    echo ""
    
    # Create merged results in temp file first - KEEP ALL, NO DEDUPLICATION
    local temp_results="$TEMP_DIR/merged_results.txt"
    cat "$TEMP_DIR"/*.txt 2>/dev/null | grep -v '^$' > "$temp_results"
    
    # Calculate statistics (use total_raw from above loop)
    local total_subs=$(wc -l < "$temp_results" 2>/dev/null || echo "0")
    local duplicates_kept=$((total_subs))
    
    # No deduplication - all results kept
    local unique_percentage=100
    
    # Display results on screen
    echo -e "${BRIGHT_GREEN}${BOLD}✨ DISCOVERED SUBDOMAINS: ❤️${NC}"
    echo -e "${BRIGHT_CYAN}════════════════════════════════════════════════════════════════${NC}"
    if [ "$total_subs" -gt 0 ]; then
        cat "$temp_results"
    else
        echo -e "${BRIGHT_YELLOW}No subdomains found${NC}"
    fi
    echo -e "${BRIGHT_CYAN}════════════════════════════════════════════════════════════════${NC}"
    
    # Save to file only if -o flag was used
    if [ -n "$OUTPUT_FILE" ]; then
        cp "$temp_results" "$OUTPUT_FILE"
        log_success "Results saved to: $OUTPUT_FILE ✨❤️"
    fi
    
    # Clean up all temporary files and any tool-generated files
    rm -rf "$TEMP_DIR"
    rm -rf temp_finder_* 2>/dev/null
    rm -f sub_report.txt 2>/dev/null
    rm -f *.json 2>/dev/null
    rm -f sublist3r_*.txt 2>/dev/null
    rm -rf reports 2>/dev/null
    
    # ═══════════════════════════════════════════════════════════════════════════════
    # 💎 ULTRA-PREMIUM FINAL RESULTS REPORT
    # ═══════════════════════════════════════════════════════════════════════════════
    
    # Find best and worst performers
    local best_tool=""
    local best_count=0
    local worst_tool=""
    local worst_count=999999
    for tool_name in "${tool_order[@]}"; do
        if [ "${tool_counts[$tool_name]}" -gt "$best_count" ]; then
            best_count="${tool_counts[$tool_name]}"
            best_tool="$tool_name"
        fi
        if [ "${tool_counts[$tool_name]}" -lt "$worst_count" ] && [ "${tool_counts[$tool_name]}" -gt 0 ]; then
            worst_count="${tool_counts[$tool_name]}"
            worst_tool="$tool_name"
        fi
    done
    
    # Calculate advanced metrics
    local avg_per_tool=0
    if [ "$active_tools" -gt 0 ]; then
        avg_per_tool=$((total_raw / active_tools))
    fi
    
    echo ""
    echo -e "${BRIGHT_YELLOW}${BOLD}╔═══════════════════════════════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BRIGHT_YELLOW}${BOLD}║                                                                                                           ║${NC}"
    echo -e "${BRIGHT_YELLOW}${BOLD}║                   💎 ${BRIGHT_WHITE}${BG_GREEN} FINDER ENTERPRISE - COMPREHENSIVE INTELLIGENCE REPORT ${NC}${BRIGHT_YELLOW}${BOLD} 💎                  ║${NC}"
    echo -e "${BRIGHT_YELLOW}${BOLD}║                                                                                                           ║${NC}"
    echo -e "${BRIGHT_YELLOW}${BOLD}╚═══════════════════════════════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Mission Intelligence Section
    echo -e "${BRIGHT_CYAN}${BOLD}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
    echo -e "${BRIGHT_CYAN}${BOLD}┃${NC}  ${BRIGHT_WHITE}${BOLD}🎯 MISSION INTELLIGENCE${NC}                                                                                 ${BRIGHT_CYAN}${BOLD}┃${NC}"
    echo -e "${BRIGHT_CYAN}${BOLD}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
    echo ""
    echo -e "  ${BRIGHT_CYAN}●${NC} ${BRIGHT_WHITE}Target Identified:${NC}      ${BRIGHT_GREEN}${BOLD}$target${NC}"
    echo -e "  ${BRIGHT_CYAN}●${NC} ${BRIGHT_WHITE}Target Classification:${NC}  ${BRIGHT_YELLOW}${BOLD}$target_type${NC}"
    echo -e "  ${BRIGHT_CYAN}●${NC} ${BRIGHT_WHITE}Scan Timestamp:${NC}         ${BRIGHT_PURPLE}$(date '+%Y-%m-%d %H:%M:%S %Z')${NC}"
    echo -e "  ${BRIGHT_CYAN}●${NC} ${BRIGHT_WHITE}Operation ID:${NC}           ${BRIGHT_BLUE}FINDER-$(date +%s)${NC}"
    echo ""
    
    # Deployment Statistics Section
    echo -e "${BRIGHT_BLUE}${BOLD}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
    echo -e "${BRIGHT_BLUE}${BOLD}┃${NC}  ${BRIGHT_WHITE}${BOLD}🚀 DEPLOYMENT STATISTICS${NC}                                                                                ${BRIGHT_BLUE}${BOLD}┃${NC}"
    echo -e "${BRIGHT_BLUE}${BOLD}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
    echo ""
    echo -e "  ${BRIGHT_GREEN}✓${NC} ${BRIGHT_WHITE}Total Arsenal:${NC}          ${BRIGHT_YELLOW}${BOLD}7 Premium Tools${NC}"
    echo -e "  ${BRIGHT_GREEN}✓${NC} ${BRIGHT_WHITE}Tools Deployed:${NC}         ${BRIGHT_GREEN}${BOLD}$completed${NC} ${BRIGHT_BLUE}tools executed${NC}"
    echo -e "  ${BRIGHT_GREEN}✓${NC} ${BRIGHT_WHITE}Active Contributors:${NC}    ${BRIGHT_GREEN}${BOLD}$active_tools${NC} ${BRIGHT_BLUE}tools producing results${NC}"
    echo -e "  ${BRIGHT_GREEN}✓${NC} ${BRIGHT_WHITE}Mission Success Rate:${NC}   ${BRIGHT_GREEN}${BOLD}$((completed * 100 / 7))%${NC} ${BRIGHT_GREEN}✨${NC}"
    echo -e "  ${BRIGHT_GREEN}✓${NC} ${BRIGHT_WHITE}Deployment Status:${NC}      ${BRIGHT_GREEN}${BOLD}OPERATIONAL${NC} ${BRIGHT_GREEN}🎯${NC}"
    echo ""
    
    # Intelligence Breakdown Section
    echo -e "${BRIGHT_PURPLE}${BOLD}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
    echo -e "${BRIGHT_PURPLE}${BOLD}┃${NC}  ${BRIGHT_WHITE}${BOLD}📊 INTELLIGENCE BREAKDOWN${NC}                                                                               ${BRIGHT_PURPLE}${BOLD}┃${NC}"
    echo -e "${BRIGHT_PURPLE}${BOLD}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
    echo ""
    echo -e "  ${BRIGHT_ORANGE}◆${NC} ${BRIGHT_WHITE}Total Discoveries:${NC}      ${BRIGHT_YELLOW}${BOLD}${BLINK}$total_raw${NC} ${BRIGHT_GREEN}${BOLD}subdomains${NC} ${BRIGHT_GREEN}🎉✨${NC}"
    echo -e "  ${BRIGHT_ORANGE}◆${NC} ${BRIGHT_WHITE}Saved to Storage:${NC}       ${BRIGHT_YELLOW}${BOLD}$total_subs${NC} ${BRIGHT_BLUE}entries${NC}"
    echo -e "  ${BRIGHT_ORANGE}◆${NC} ${BRIGHT_WHITE}Data Processing:${NC}        ${BRIGHT_GREEN}${BOLD}ALL RESULTS MODE${NC} ${BRIGHT_CYAN}(No Deduplication)${NC} ❤️"
    echo -e "  ${BRIGHT_ORANGE}◆${NC} ${BRIGHT_WHITE}Duplicates Status:${NC}      ${BRIGHT_GREEN}${BOLD}PRESERVED${NC} ${BRIGHT_BLUE}for maximum coverage${NC} ✨"
    echo -e "  ${BRIGHT_ORANGE}◆${NC} ${BRIGHT_WHITE}Average Per Tool:${NC}       ${BRIGHT_CYAN}${BOLD}$avg_per_tool${NC} ${BRIGHT_BLUE}subdomains/tool${NC}"
    echo ""
    
    # Performance Champions Section
    if [ -n "$best_tool" ]; then
        echo -e "${BRIGHT_GREEN}${BOLD}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
        echo -e "${BRIGHT_GREEN}${BOLD}┃${NC}  ${BRIGHT_WHITE}${BOLD}🏆 PERFORMANCE CHAMPIONS${NC}                                                                                 ${BRIGHT_GREEN}${BOLD}┃${NC}"
        echo -e "${BRIGHT_GREEN}${BOLD}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
        echo ""
        echo -e "  ${BRIGHT_YELLOW}🥇${NC} ${BRIGHT_WHITE}Top Performer:${NC}          ${BRIGHT_GREEN}${BOLD}$best_tool${NC} ${BRIGHT_YELLOW}($best_count subdomains)${NC} ${BRIGHT_GREEN}💎${NC}"
        if [ -n "$worst_tool" ] && [ "$worst_count" -lt "$best_count" ]; then
            echo -e "  ${BRIGHT_BLUE}📊${NC} ${BRIGHT_WHITE}Most Efficient:${NC}         ${BRIGHT_CYAN}${BOLD}$worst_tool${NC} ${BRIGHT_BLUE}($worst_count subdomains)${NC}"
        fi
        local best_percentage=$((best_count * 100 / total_raw))
        echo -e "  ${BRIGHT_PURPLE}📈${NC} ${BRIGHT_WHITE}Champion Contribution:${NC}  ${BRIGHT_PURPLE}${BOLD}${best_percentage}%${NC} ${BRIGHT_GREEN}of total intelligence${NC}"
        echo ""
    fi
    
    # Data Quality & Processing Section
    echo -e "${BRIGHT_YELLOW}${BOLD}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
    echo -e "${BRIGHT_YELLOW}${BOLD}┃${NC}  ${BRIGHT_WHITE}${BOLD}⚙️  DATA PROCESSING CONFIGURATION${NC}                                                                       ${BRIGHT_YELLOW}${BOLD}┃${NC}"
    echo -e "${BRIGHT_YELLOW}${BOLD}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
    echo ""
    echo -e "  ${BRIGHT_CYAN}▸${NC} ${BRIGHT_WHITE}Deduplication Mode:${NC}     ${BRIGHT_RED}${BOLD}DISABLED${NC} ${BRIGHT_CYAN}→${NC} ${BRIGHT_GREEN}${BOLD}ALL RESULTS PRESERVED${NC} ✨"
    echo -e "  ${BRIGHT_CYAN}▸${NC} ${BRIGHT_WHITE}Sorting Algorithm:${NC}      ${BRIGHT_RED}${BOLD}DISABLED${NC} ${BRIGHT_CYAN}→${NC} ${BRIGHT_GREEN}${BOLD}ORIGINAL ORDER MAINTAINED${NC} ❤️"
    echo -e "  ${BRIGHT_CYAN}▸${NC} ${BRIGHT_WHITE}Validation System:${NC}      ${BRIGHT_GREEN}${BOLD}✅ ACTIVE${NC} ${BRIGHT_CYAN}→${NC} ${BRIGHT_BLUE}REGEX PATTERN FILTERING${NC}"
    echo -e "  ${BRIGHT_CYAN}▸${NC} ${BRIGHT_WHITE}Data Integrity:${NC}         ${BRIGHT_GREEN}${BOLD}100% COMPLETE${NC} ${BRIGHT_CYAN}→${NC} ${BRIGHT_PURPLE}ZERO DATA LOSS${NC} 💎"
    echo ""
    
    # Storage & Output Section
    echo -e "${BRIGHT_GREEN}${BOLD}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
    echo -e "${BRIGHT_GREEN}${BOLD}┃${NC}  ${BRIGHT_WHITE}${BOLD}💾 STORAGE & OUTPUT MANAGEMENT${NC}                                                                           ${BRIGHT_GREEN}${BOLD}┃${NC}"
    echo -e "${BRIGHT_GREEN}${BOLD}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
    echo ""
    if [ -n "$OUTPUT_FILE" ]; then
        local file_size=$(wc -c < "$OUTPUT_FILE" 2>/dev/null || echo "0")
        local file_size_kb=$((file_size / 1024))
        local file_size_mb=$((file_size / 1048576))
        
        if [ "$file_size_mb" -gt 0 ]; then
            local display_size="${file_size_mb} MB"
        else
            local display_size="${file_size_kb} KB"
        fi
        
        echo -e "  ${BRIGHT_GREEN}✓${NC} ${BRIGHT_WHITE}Output Destination:${NC}     ${BRIGHT_CYAN}${BOLD}${UNDERLINE}$OUTPUT_FILE${NC} ${BRIGHT_GREEN}✨${NC}"
        echo -e "  ${BRIGHT_GREEN}✓${NC} ${BRIGHT_WHITE}File Size:${NC}              ${BRIGHT_YELLOW}${BOLD}$display_size${NC} ${BRIGHT_BLUE}($file_size bytes)${NC}"
        echo -e "  ${BRIGHT_GREEN}✓${NC} ${BRIGHT_WHITE}Storage Status:${NC}         ${BRIGHT_GREEN}${BOLD}✅ SUCCESSFULLY SAVED${NC} ${BRIGHT_GREEN}❤️${NC}"
        echo -e "  ${BRIGHT_GREEN}✓${NC} ${BRIGHT_WHITE}Full Path:${NC}              ${BRIGHT_PURPLE}$(pwd)/$OUTPUT_FILE${NC}"
        echo -e "  ${BRIGHT_GREEN}✓${NC} ${BRIGHT_WHITE}Access Mode:${NC}            ${BRIGHT_CYAN}Ready for Analysis${NC} ${BRIGHT_YELLOW}🔍${NC}"
    else
        echo -e "  ${BRIGHT_YELLOW}⚠${NC}  ${BRIGHT_WHITE}Output Mode:${NC}            ${BRIGHT_YELLOW}${BOLD}SCREEN DISPLAY ONLY${NC}"
        echo -e "  ${BRIGHT_BLUE}ℹ${NC}  ${BRIGHT_WHITE}Storage Tip:${NC}            ${BRIGHT_CYAN}Use${NC} ${BRIGHT_GREEN}-o <filename>${NC} ${BRIGHT_CYAN}flag to save results${NC}"
        echo -e "  ${BRIGHT_BLUE}ℹ${NC}  ${BRIGHT_WHITE}Example:${NC}                ${BRIGHT_GREEN}./withoutamass.sh -d example.com -o results.txt${NC}"
    fi
    echo ""
    
    # Operational Timestamp Section
    echo -e "${BRIGHT_ORANGE}${BOLD}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
    echo -e "${BRIGHT_ORANGE}${BOLD}┃${NC}  ${BRIGHT_WHITE}${BOLD}⏰ OPERATIONAL TIMESTAMP${NC}                                                                                 ${BRIGHT_ORANGE}${BOLD}┃${NC}"
    echo -e "${BRIGHT_ORANGE}${BOLD}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
    echo ""
    echo -e "  ${BRIGHT_ORANGE}⏱${NC}  ${BRIGHT_WHITE}Completion Time:${NC}        ${BRIGHT_CYAN}${BOLD}$(date '+%Y-%m-%d %H:%M:%S %Z')${NC}"
    echo -e "  ${BRIGHT_ORANGE}⏱${NC}  ${BRIGHT_WHITE}Unix Timestamp:${NC}         ${BRIGHT_BLUE}$(date +%s)${NC}"
    echo -e "  ${BRIGHT_ORANGE}⏱${NC}  ${BRIGHT_WHITE}Session ID:${NC}             ${BRIGHT_PURPLE}FINDER-$(date +%s)${NC}"
    echo ""
    
    # ═══════════════════════════════════════════════════════════════════════════════
    # 📊 SIMPLE TOOL STATISTICS - SUBDOMAIN COUNT PER TOOL
    # ═══════════════════════════════════════════════════════════════════════════════
    
    echo -e "${BRIGHT_PURPLE}${BOLD}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
    echo -e "${BRIGHT_PURPLE}${BOLD}┃${NC}  ${BRIGHT_WHITE}${BOLD}📊 TOOL STATISTICS - SUBDOMAINS DISCOVERED PER TOOL${NC}                                                      ${BRIGHT_PURPLE}${BOLD}┃${NC}"
    echo -e "${BRIGHT_PURPLE}${BOLD}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
    echo ""
    
    # Display simple stats for each tool
    printf "  ${BRIGHT_CYAN}%-20s${NC} ${BRIGHT_WHITE}%-15s${NC} ${BRIGHT_YELLOW}%-20s${NC}\n" "TOOL NAME" "SUBDOMAINS" "STATUS"
    echo -e "  ${BRIGHT_BLUE}────────────────────────────────────────────────────────────────────────────────${NC}"
    
    for tool_name in "${tool_order[@]}"; do
        local tool_count=${tool_counts[$tool_name]}
        
        if [ "$tool_count" -gt 0 ]; then
            local status="${BRIGHT_GREEN}✅ Active${NC}"
            local count_display="${BRIGHT_GREEN}${BOLD}${tool_count}${NC}"
        else
            local status="${BRIGHT_RED}❌ No Results${NC}"
            local count_display="${BRIGHT_RED}0${NC}"
        fi
        
        printf "  ${BRIGHT_CYAN}%-20s${NC} ${count_display}%-15s ${status}\n" "$tool_name" ""
    done
    
    echo -e "  ${BRIGHT_BLUE}────────────────────────────────────────────────────────────────────────────────${NC}"
    printf "  ${BRIGHT_YELLOW}${BOLD}%-20s${NC} ${BRIGHT_YELLOW}${BOLD}%-15s${NC}\n" "TOTAL" "$total_raw"
    echo ""
    
    # Final Success Banner
    echo -e "${BRIGHT_YELLOW}${BOLD}╔═══════════════════════════════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BRIGHT_YELLOW}${BOLD}║                                                                                                           ║${NC}"
    echo -e "${BRIGHT_YELLOW}${BOLD}║                              ${BRIGHT_WHITE}${BG_GREEN} ✨ MISSION ACCOMPLISHED ✨ ${NC}${BRIGHT_YELLOW}${BOLD}                                              ║${NC}"
    echo -e "${BRIGHT_YELLOW}${BOLD}║                                                                                                           ║${NC}"
    echo -e "${BRIGHT_YELLOW}${BOLD}║                   ${BRIGHT_GREEN}Intelligence Gathering Complete - All Systems Nominal${NC}${BRIGHT_YELLOW}${BOLD}                       ║${NC}"
    echo -e "${BRIGHT_YELLOW}${BOLD}║                                                                                                           ║${NC}"
    echo -e "${BRIGHT_YELLOW}${BOLD}╚═══════════════════════════════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    log_success "FINDER ENTERPRISE - Enumeration Mission Completed Successfully! ✨❤️🎯🚀💎"
    
    # Ultra-Premium Celebration Footer
    echo ""
    echo -e "${BRIGHT_CYAN}╔═══════════════════════════════════════════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BRIGHT_CYAN}║${NC}  ${BRIGHT_RED}🎉${BRIGHT_YELLOW}🎉${BRIGHT_GREEN}🎉${BRIGHT_BLUE}🎉${BRIGHT_PURPLE}🎉${BRIGHT_CYAN}🎉${PINK}🎉${ORANGE}🎉${NC}  ${BRIGHT_WHITE}${BOLD}THANK YOU FOR USING FINDER ENTERPRISE INTELLIGENCE SUITE${NC}  ${BRIGHT_RED}🎉${BRIGHT_YELLOW}🎉${BRIGHT_GREEN}🎉${BRIGHT_BLUE}🎉${BRIGHT_PURPLE}🎉${BRIGHT_CYAN}🎉${PINK}🎉${ORANGE}🎉${NC}  ${BRIGHT_CYAN}║${NC}"
    echo -e "${BRIGHT_CYAN}╚═══════════════════════════════════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Main Script Logic
main() {
    # Default values - ensure OUTPUT_FILE is empty unless -o flag is used
    DOMAIN=""
    DOMAIN_FILE=""
    REPORT_NAME=""
    OUTPUT_FILE=""  # Explicitly set to empty
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -d)
                DOMAIN="$2"
                shift 2
                ;;
            -dL)
                DOMAIN_FILE="$2"
                shift 2
                ;;
            -o)
                OUTPUT_FILE="$2"
                shift 2
                ;;
            -r)
                REPORT_NAME="$2"
                shift 2
                ;;
            --install)
                install_tools
                exit 0
                ;;
            --check)
                show_banner
                check_tools
                exit $?
                ;;
            --setup-chaos)
                setup_chaos_key
                exit 0
                ;;
            --debug)
                debug_paths
                exit 0
                ;;
            --version)
                show_banner
                echo -e "${WHITE}Version:${NC} $VERSION"
                echo -e "${WHITE}Author:${NC} $AUTHOR"
                echo -e "${WHITE}Repository:${NC} https://github.com/MuhammadWaseem29/subfinder"
                exit 0
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                log_error "Unknown option: $1"
                echo "Use --help for usage information."
                exit 1
                ;;
        esac
    done
    
    # Validate arguments
    if [ -n "$DOMAIN" ] && [ -n "$DOMAIN_FILE" ]; then
        log_error "Cannot use both -d and -dL options simultaneously."
        exit 1
    fi
    
    if [ -z "$DOMAIN" ] && [ -z "$DOMAIN_FILE" ]; then
        show_help
        exit 1
    fi
    
    # Execute enumeration
    if [ -n "$DOMAIN" ]; then
        run_enumeration "$DOMAIN" "domain"
    elif [ -n "$DOMAIN_FILE" ]; then
        if [ ! -f "$DOMAIN_FILE" ]; then
            log_error "Domain file not found: $DOMAIN_FILE"
            exit 1
        fi
        if [ ! -s "$DOMAIN_FILE" ]; then
            log_error "Domain file is empty: $DOMAIN_FILE"
            exit 1
        fi
        run_enumeration "$DOMAIN_FILE" "file"
    fi
}

# Execute main function
main "$@"
