#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════════
#                    FINDER - Installation Script
#              Automated Installation for All Required Tools
# ═══════════════════════════════════════════════════════════════════════════════
# 
# Author: MuhammadWaseem29 (@MuhammadWaseem29)
# Repository: https://github.com/MuhammadWaseem29/Subdomain-Finding-Tool
# Version: 2.0.0 Professional Edition
# License: MIT
#
# Description: This script automates the installation of all tools required
#              for FINDER - Professional Edition subdomain enumeration framework.
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
#   sudo ./install.sh                    # Install all tools
#
# ═══════════════════════════════════════════════════════════════════════════════

# Script Configuration
VERSION="2.0.0 Professional"
AUTHOR="MuhammadWaseem29"

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
BRIGHT_WHITE='\033[1;97m'

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
    echo -e "${BRIGHT_CYAN}${BOLD}║${NC}  ${BRIGHT_WHITE}${BOLD}Repository:${NC} ${BRIGHT_CYAN}https://github.com/MuhammadWaseem29/Subdomain-Finding-Tool${NC}        ${BRIGHT_CYAN}${BOLD}║${NC}"
    echo -e "${BRIGHT_CYAN}${BOLD}║${NC}                                                                               ${BRIGHT_CYAN}${BOLD}║${NC}"
    echo -e "${BRIGHT_CYAN}${BOLD}╚═══════════════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${BRIGHT_RED}▓${BRIGHT_YELLOW}▓${BRIGHT_GREEN}▓${BRIGHT_BLUE}▓${BRIGHT_PURPLE}▓${BRIGHT_CYAN}▓${PINK}▓${ORANGE}▓${BRIGHT_RED}▓${BRIGHT_YELLOW}▓${BRIGHT_GREEN}▓${BRIGHT_BLUE}▓${BRIGHT_PURPLE}▓${BRIGHT_CYAN}▓${PINK}▓${ORANGE}▓${BRIGHT_RED}▓${BRIGHT_YELLOW}▓${BRIGHT_GREEN}▓${BRIGHT_BLUE}▓${BRIGHT_PURPLE}▓${BRIGHT_CYAN}▓${PINK}▓${ORANGE}▓${BRIGHT_RED}▓${BRIGHT_YELLOW}▓${BRIGHT_GREEN}▓${BRIGHT_BLUE}▓${BRIGHT_PURPLE}▓${BRIGHT_CYAN}▓${PINK}▓${ORANGE}▓${NC}"
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

# Installation Function
install_tools() {
    show_banner
    log_info "Starting FINDER Professional automated tool installation... ✨❤️"
    
    # Check if running as root
    if [ "$EUID" -ne 0 ]; then
        log_error "Installation requires root privileges. Please run with sudo."
        log_info "Example: sudo ./install.sh"
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
            log_info "Note: You may need to configure Chaos API key separately"
        else
            log_error "Chaos installation failed"
        fi
    else
        log_success "Chaos is already installed - Skipping installation"
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
    log_info "Test with: ./Subdomains.sh --check"
    
    # Final verification
    echo ""
    echo -e "${PURPLE}${BOLD}═══════════════════════════════════════════════════════════════════════════════${NC}"
    echo -e "${PURPLE}${BOLD}                   ✨ FINDER INSTALLATION SUMMARY ❤️                         ${NC}"
    echo -e "${PURPLE}${BOLD}═══════════════════════════════════════════════════════════════════════════════${NC}"
    
    echo ""
    log_info "Verifying all tools..."
    
    local tools=("subfinder" "subdominator" "assetfinder" "findomain" "sublist3r" "subscraper" "chaos")
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
        echo -e "${BRIGHT_CYAN}✨ You can now run: ${BRIGHT_WHITE}./Subdomains.sh -d example.com${NC} ✨"
        echo -e "${BRIGHT_GREEN}🎉${BRIGHT_YELLOW}🎉${BRIGHT_GREEN}🎉${BRIGHT_YELLOW}🎉${BRIGHT_GREEN}🎉${BRIGHT_YELLOW}🎉${BRIGHT_GREEN}🎉${BRIGHT_YELLOW}🎉${BRIGHT_GREEN}🎉${BRIGHT_YELLOW}🎉${BRIGHT_GREEN}🎉${BRIGHT_YELLOW}🎉${BRIGHT_GREEN}🎉${BRIGHT_YELLOW}🎉${BRIGHT_GREEN}🎉${BRIGHT_YELLOW}🎉${BRIGHT_GREEN}🎉${BRIGHT_YELLOW}🎉${BRIGHT_GREEN}🎉${BRIGHT_YELLOW}🎉${BRIGHT_GREEN}🎉${BRIGHT_YELLOW}🎉${BRIGHT_GREEN}🎉${BRIGHT_YELLOW}🎉${BRIGHT_GREEN}🎉${BRIGHT_YELLOW}🎉${BRIGHT_GREEN}🎉${BRIGHT_YELLOW}🎉${NC}"
    elif [ $installed -gt 0 ]; then
        echo -e "${BRIGHT_YELLOW}${BOLD}⚠️  FINDER PARTIAL INSTALLATION COMPLETED ⚠️${NC}"
        echo -e "${ORANGE}Some tools may need manual configuration or PATH updates.${NC}"
        echo -e "${BRIGHT_CYAN}Available tools can still be used with: ${BRIGHT_WHITE}./Subdomains.sh -d example.com${NC}"
    else
        echo -e "${BRIGHT_RED}${BOLD}${BLINK}❌ FINDER INSTALLATION FAILED ❌${NC}"
        echo -e "${LIGHT_RED}Please check the error messages above and try manual installation.${NC}"
    fi
    
    echo ""
    echo -e "${BLUE}${BOLD}NEXT STEPS:${NC}"
    echo "1. Restart your terminal or run: source ~/.bashrc"
    echo "2. Test installation: ./Subdomains.sh --check"
    echo "3. Run enumeration: ./Subdomains.sh -d example.com"
    echo ""
}

# Main execution
if [ "${BASH_SOURCE[0]}" == "${0}" ]; then
    install_tools
fi

