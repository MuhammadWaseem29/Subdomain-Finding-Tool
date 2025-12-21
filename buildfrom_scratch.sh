#!/bin/bash

# Build from Scratch - Subfinder, Chaos & Subdominator Runner ✨❤️
# Simple script to run subfinder, subdominator, and chaos with user-provided domain or domains file
# Usage: ./buildfrom_scratch.sh -d example.com
#        ./buildfrom_scratch.sh -d example.com -o output.txt
#        ./buildfrom_scratch.sh -dL domains.txt
#        ./buildfrom_scratch.sh -dL domains.txt -o output.txt

# Color Definitions ✨
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Enhanced Colors ❤️
BRIGHT_RED='\033[1;31m'
BRIGHT_GREEN='\033[1;32m'
BRIGHT_YELLOW='\033[1;33m'
BRIGHT_BLUE='\033[1;34m'
BRIGHT_PURPLE='\033[1;35m'
BRIGHT_CYAN='\033[1;36m'
ORANGE='\033[0;33m'
PINK='\033[1;95m'

# Set Chaos API Key
export PDCP_API_KEY="45c4a78e-957e-486f-80b9-f506362d9ae4"

# Check if subfinder is installed
if ! command -v subfinder >/dev/null 2>&1; then
    echo -e "${BRIGHT_RED}${BOLD}❌ Error:${NC} ${RED}subfinder is not installed or not in PATH${NC}"
    echo -e "${YELLOW}Please install subfinder first:${NC}"
    echo -e "${CYAN}  go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest${NC}"
    exit 1
fi

# Check if chaos is installed
if ! command -v chaos >/dev/null 2>&1; then
    echo -e "${BRIGHT_RED}${BOLD}❌ Error:${NC} ${RED}chaos is not installed or not in PATH${NC}"
    echo -e "${YELLOW}Please install chaos first:${NC}"
    echo -e "${CYAN}  go install -v github.com/projectdiscovery/chaos-client/cmd/chaos@latest${NC}"
    exit 1
fi

# Check if subdominator is installed
if ! command -v subdominator >/dev/null 2>&1; then
    echo -e "${BRIGHT_RED}${BOLD}❌ Error:${NC} ${RED}subdominator is not installed or not in PATH${NC}"
    echo -e "${YELLOW}Please install subdominator first:${NC}"
    echo -e "${CYAN}  pipx install git+https://github.com/RevoltSecurities/Subdominator${NC}"
    echo -e "${CYAN}  or${NC}"
    echo -e "${CYAN}  pip install --upgrade git+https://github.com/RevoltSecurities/Subdominator --break-system-packages${NC}"
    exit 1
fi

# Check if arguments are provided
if [ $# -eq 0 ]; then
    echo -e "${BRIGHT_CYAN}${BOLD}✨ Usage:${NC} ${WHITE}$0 -d <domain> [-o <output_file>]${NC}"
    echo -e "${BRIGHT_CYAN}${BOLD}✨ Usage:${NC} ${WHITE}$0 -dL <domains_file> [-o <output_file>]${NC}"
    echo ""
    echo -e "${BRIGHT_YELLOW}${BOLD}💡 Examples:${NC}"
    echo -e "${GREEN}  $0 -d example.com${NC}                    ${CYAN}# Display results only ✨${NC}"
    echo -e "${GREEN}  $0 -d example.com -o results.txt${NC}     ${CYAN}# Save merged results to file ❤️${NC}"
    echo -e "${GREEN}  $0 -dL domains.txt${NC}                    ${CYAN}# Display results only ✨${NC}"
    echo -e "${GREEN}  $0 -dL domains.txt -o results.txt${NC}    ${CYAN}# Save merged results to file ❤️${NC}"
    exit 1
fi

# Initialize variables
domain=""
domains_file=""
output_file=""
use_output=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -d)
            if [ -z "$2" ]; then
                echo -e "${BRIGHT_RED}${BOLD}❌ Error:${NC} ${RED}Domain not provided${NC}"
                echo -e "${YELLOW}Usage:${NC} $0 -d <domain> [-o <output_file>]"
                exit 1
            fi
            domain="$2"
            shift 2
            ;;
        -dL)
            if [ -z "$2" ]; then
                echo -e "${BRIGHT_RED}${BOLD}❌ Error:${NC} ${RED}Domains file not provided${NC}"
                echo -e "${YELLOW}Usage:${NC} $0 -dL <domains_file> [-o <output_file>]"
                exit 1
            fi
            domains_file="$2"
            if [ ! -f "$domains_file" ]; then
                echo -e "${BRIGHT_RED}${BOLD}❌ Error:${NC} ${RED}File '$domains_file' not found${NC}"
                exit 1
            fi
            shift 2
            ;;
        -o)
            if [ -z "$2" ]; then
                echo -e "${BRIGHT_RED}${BOLD}❌ Error:${NC} ${RED}Output file not provided${NC}"
                exit 1
            fi
            output_file="$2"
            use_output=true
            shift 2
            ;;
        *)
            echo -e "${BRIGHT_RED}${BOLD}❌ Error:${NC} ${RED}Unknown option '$1'${NC}"
            echo -e "${YELLOW}Usage:${NC} $0 -d <domain> [-o <output_file>]"
            echo -e "${YELLOW}Usage:${NC} $0 -dL <domains_file> [-o <output_file>]"
            exit 1
            ;;
    esac
done

# Check if domain or domains_file is provided
if [ -z "$domain" ] && [ -z "$domains_file" ]; then
    echo -e "${BRIGHT_RED}${BOLD}❌ Error:${NC} ${RED}Must provide either -d <domain> or -dL <domains_file>${NC}"
    exit 1
fi

# Create temporary files for storing results
TEMP_DIR=$(mktemp -d)
SUBFINDER_OUTPUT="$TEMP_DIR/subfinder_results.txt"
CHAOS_OUTPUT="$TEMP_DIR/chaos_results.txt"
SUBDOMINATOR_OUTPUT="$TEMP_DIR/subdominator_results.txt"

# Cleanup function
cleanup() {
    rm -rf "$TEMP_DIR" 2>/dev/null
    # Kill any remaining subdominator processes
    pkill -f "subdominator" 2>/dev/null
}
trap cleanup EXIT

# Function to run subdominator with auto-kill after completion
run_subdominator_single() {
    local domain="$1"
    local output_file="$2"
    
    # Create a temporary file for capturing output
    local temp_output="$TEMP_DIR/subdominator_temp.txt"
    
    # Run subdominator in background and capture PID
    subdominator -d "$domain" -all > "$temp_output" 2>&1 &
    local subdominator_pid=$!
    
    # Monitor for completion or timeout
    local timeout=300  # 5 minutes max
    local elapsed=0
    local check_interval=2
    
    while kill -0 "$subdominator_pid" 2>/dev/null && [ $elapsed -lt $timeout ]; do
        sleep $check_interval
        elapsed=$((elapsed + check_interval))
        
        # Check if subdominator has completed (looking for completion message)
        if grep -q "Happy Hacking root" "$temp_output" 2>/dev/null; then
            sleep 1  # Give it a moment to finish writing
            kill "$subdominator_pid" 2>/dev/null
            wait "$subdominator_pid" 2>/dev/null
            break
        fi
    done
    
    # If still running after timeout, force kill
    if kill -0 "$subdominator_pid" 2>/dev/null; then
        kill -9 "$subdominator_pid" 2>/dev/null
        wait "$subdominator_pid" 2>/dev/null
    fi
    
    # Copy to output file and display
    cp "$temp_output" "$output_file" 2>/dev/null || cat "$temp_output" > "$output_file"
    cat "$output_file"
}

# Function to run subdominator with file list and auto-kill after completion
run_subdominator_file() {
    local domains_file="$1"
    local output_file="$2"
    
    # Create a temporary file to capture stderr/stdout for completion detection
    local temp_log="$TEMP_DIR/subdominator_log.txt"
    
    # Run subdominator in background and capture PID
    subdominator -dL "$domains_file" -all -V -o "$output_file" > "$temp_log" 2>&1 &
    local subdominator_pid=$!
    
    # Monitor for completion or timeout
    local timeout=600  # 10 minutes max for file list
    local elapsed=0
    local check_interval=3
    
    while kill -0 "$subdominator_pid" 2>/dev/null && [ $elapsed -lt $timeout ]; do
        sleep $check_interval
        elapsed=$((elapsed + check_interval))
        
        # Check if subdominator has completed (looking for completion message)
        if grep -q "Happy Hacking root" "$temp_log" 2>/dev/null || grep -q "Happy Hacking root" "$output_file" 2>/dev/null; then
            sleep 2  # Give it a moment to finish writing
            kill "$subdominator_pid" 2>/dev/null
            wait "$subdominator_pid" 2>/dev/null
            break
        fi
    done
    
    # If still running, check one more time
    if kill -0 "$subdominator_pid" 2>/dev/null; then
        sleep 3
        if grep -q "Happy Hacking root" "$temp_log" 2>/dev/null || grep -q "Happy Hacking root" "$output_file" 2>/dev/null; then
            kill "$subdominator_pid" 2>/dev/null
            wait "$subdominator_pid" 2>/dev/null
        fi
    fi
    
    # Force kill if still running
    if kill -0 "$subdominator_pid" 2>/dev/null; then
        kill -9 "$subdominator_pid" 2>/dev/null
        wait "$subdominator_pid" 2>/dev/null
    fi
    
    # Display output if file was created
    if [ -f "$output_file" ]; then
        cat "$output_file"
    fi
}

# Run tools based on input type
if [ -n "$domain" ]; then
    # Single domain mode
    echo -e "${BRIGHT_CYAN}${BOLD}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BRIGHT_CYAN}${BOLD}║${NC}  ${BRIGHT_PURPLE}${BOLD}✨ Running Subdomain Enumeration ✨${NC}                              ${BRIGHT_CYAN}${BOLD}║${NC}"
    echo -e "${BRIGHT_CYAN}${BOLD}║${NC}  ${BRIGHT_YELLOW}${BOLD}🎯 Target:${NC} ${BRIGHT_GREEN}$domain${NC}                                    ${BRIGHT_CYAN}${BOLD}║${NC}"
    echo -e "${BRIGHT_CYAN}${BOLD}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if [ "$use_output" = true ]; then
        echo -e "${BRIGHT_BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BRIGHT_GREEN}${BOLD}🔍 Running Subfinder ✨${NC}"
        echo -e "${BRIGHT_BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        subfinder -d "$domain" -all -v | tee "$SUBFINDER_OUTPUT"
        subfinder_count=$(wc -l < "$SUBFINDER_OUTPUT" 2>/dev/null | tr -d ' ' || echo "0")
        echo ""
        echo -e "${BRIGHT_GREEN}${BOLD}✓ Subfinder found:${NC} ${BRIGHT_CYAN}${BOLD}$subfinder_count${NC} ${CYAN}subdomains ✨${NC}"
        
        echo ""
        echo -e "${BRIGHT_BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BRIGHT_YELLOW}${BOLD}⚡ Running Subdominator ✨${NC}"
        echo -e "${BRIGHT_BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        run_subdominator_single "$domain" "$SUBDOMINATOR_OUTPUT"
        subdominator_count=$(wc -l < "$SUBDOMINATOR_OUTPUT" 2>/dev/null | tr -d ' ' || echo "0")
        echo ""
        echo -e "${BRIGHT_YELLOW}${BOLD}✓ Subdominator found:${NC} ${BRIGHT_CYAN}${BOLD}$subdominator_count${NC} ${CYAN}subdomains ✨${NC}"
        
        echo ""
        echo -e "${BRIGHT_BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BRIGHT_PURPLE}${BOLD}🌀 Running Chaos ❤️${NC}"
        echo -e "${BRIGHT_BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        chaos -d "$domain" | tee "$CHAOS_OUTPUT"
        chaos_count=$(wc -l < "$CHAOS_OUTPUT" 2>/dev/null | tr -d ' ' || echo "0")
        echo ""
        echo -e "${BRIGHT_PURPLE}${BOLD}✓ Chaos found:${NC} ${BRIGHT_CYAN}${BOLD}$chaos_count${NC} ${CYAN}subdomains ❤️${NC}"
        
        # Merge results from all three tools
        echo ""
        echo -e "${BRIGHT_YELLOW}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BRIGHT_CYAN}${BOLD}✨ Merging results from subfinder, subdominator, and chaos ✨${NC}"
        echo -e "${BRIGHT_YELLOW}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        cat "$SUBFINDER_OUTPUT" "$SUBDOMINATOR_OUTPUT" "$CHAOS_OUTPUT" 2>/dev/null | sort -u > "$output_file"
        
        # Count total unique results (use already calculated counts if available, otherwise recalculate)
        if [ -z "$subfinder_count" ]; then
            subfinder_count=$(wc -l < "$SUBFINDER_OUTPUT" 2>/dev/null | tr -d ' ' || echo "0")
        fi
        if [ -z "$chaos_count" ]; then
            chaos_count=$(wc -l < "$CHAOS_OUTPUT" 2>/dev/null | tr -d ' ' || echo "0")
        fi
        if [ -z "$subdominator_count" ]; then
            subdominator_count=$(wc -l < "$SUBDOMINATOR_OUTPUT" 2>/dev/null | tr -d ' ' || echo "0")
        fi
        total_count=$(wc -l < "$output_file" 2>/dev/null || echo "0")
        total_count=$(echo "$total_count" | tr -d ' ')
        
        echo ""
        echo -e "${BRIGHT_GREEN}${BOLD}╔════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BRIGHT_GREEN}${BOLD}║${NC}  ${BRIGHT_WHITE}${BOLD}📊 Results Summary ❤️${NC}                                      ${BRIGHT_GREEN}${BOLD}║${NC}"
        echo -e "${BRIGHT_GREEN}${BOLD}╠════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${BRIGHT_GREEN}${BOLD}║${NC}  ${CYAN}✓ Subfinder found:${NC} ${BRIGHT_GREEN}${BOLD}$subfinder_count${NC} ${CYAN}subdomains ✨${NC}                    ${BRIGHT_GREEN}${BOLD}║${NC}"
        echo -e "${BRIGHT_GREEN}${BOLD}║${NC}  ${CYAN}✓ Subdominator found:${NC} ${BRIGHT_YELLOW}${BOLD}$subdominator_count${NC} ${CYAN}subdomains ✨${NC}                ${BRIGHT_GREEN}${BOLD}║${NC}"
        echo -e "${BRIGHT_GREEN}${BOLD}║${NC}  ${CYAN}✓ Chaos found:${NC} ${BRIGHT_PURPLE}${BOLD}$chaos_count${NC} ${CYAN}subdomains ❤️${NC}                        ${BRIGHT_GREEN}${BOLD}║${NC}"
        echo -e "${BRIGHT_GREEN}${BOLD}║${NC}  ${CYAN}✓ Total unique subdomains:${NC} ${BRIGHT_YELLOW}${BOLD}$total_count${NC} ${CYAN}✨${NC}                    ${BRIGHT_GREEN}${BOLD}║${NC}"
        echo -e "${BRIGHT_GREEN}${BOLD}║${NC}  ${CYAN}✓ Merged results saved to:${NC} ${BRIGHT_CYAN}${BOLD}$output_file${NC} ${CYAN}❤️${NC}        ${BRIGHT_GREEN}${BOLD}║${NC}"
        echo -e "${BRIGHT_GREEN}${BOLD}╚════════════════════════════════════════════════════════════╝${NC}"
    else
        echo -e "${BRIGHT_BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BRIGHT_GREEN}${BOLD}🔍 Subfinder Results ✨${NC}"
        echo -e "${BRIGHT_BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        subfinder -d "$domain" -all -v | tee "$SUBFINDER_OUTPUT"
        subfinder_count=$(wc -l < "$SUBFINDER_OUTPUT" 2>/dev/null | tr -d ' ' || echo "0")
        echo ""
        echo -e "${BRIGHT_GREEN}${BOLD}✓ Subfinder found:${NC} ${BRIGHT_CYAN}${BOLD}$subfinder_count${NC} ${CYAN}subdomains ✨${NC}"
        
        echo ""
        echo -e "${BRIGHT_BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BRIGHT_YELLOW}${BOLD}⚡ Subdominator Results ✨${NC}"
        echo -e "${BRIGHT_BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        run_subdominator_single "$domain" "$SUBDOMINATOR_OUTPUT"
        subdominator_count=$(wc -l < "$SUBDOMINATOR_OUTPUT" 2>/dev/null | tr -d ' ' || echo "0")
        echo ""
        echo -e "${BRIGHT_YELLOW}${BOLD}✓ Subdominator found:${NC} ${BRIGHT_CYAN}${BOLD}$subdominator_count${NC} ${CYAN}subdomains ✨${NC}"
        
        echo ""
        echo -e "${BRIGHT_BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BRIGHT_PURPLE}${BOLD}🌀 Chaos Results ❤️${NC}"
        echo -e "${BRIGHT_BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        chaos -d "$domain" | tee "$CHAOS_OUTPUT"
        chaos_count=$(wc -l < "$CHAOS_OUTPUT" 2>/dev/null | tr -d ' ' || echo "0")
        echo ""
        echo -e "${BRIGHT_PURPLE}${BOLD}✓ Chaos found:${NC} ${BRIGHT_CYAN}${BOLD}$chaos_count${NC} ${CYAN}subdomains ❤️${NC}"
        
        # Merge and count results
        MERGED_OUTPUT="$TEMP_DIR/merged_results.txt"
        cat "$SUBFINDER_OUTPUT" "$SUBDOMINATOR_OUTPUT" "$CHAOS_OUTPUT" 2>/dev/null | sort -u > "$MERGED_OUTPUT"
        
        # Count results
        subfinder_count=$(wc -l < "$SUBFINDER_OUTPUT" 2>/dev/null || echo "0")
        chaos_count=$(wc -l < "$CHAOS_OUTPUT" 2>/dev/null || echo "0")
        subdominator_count=$(wc -l < "$SUBDOMINATOR_OUTPUT" 2>/dev/null || echo "0")
        total_count=$(wc -l < "$MERGED_OUTPUT" 2>/dev/null || echo "0")
        
        echo ""
        echo -e "${BRIGHT_GREEN}${BOLD}╔════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BRIGHT_GREEN}${BOLD}║${NC}  ${BRIGHT_WHITE}${BOLD}📊 Results Summary ❤️${NC}                                      ${BRIGHT_GREEN}${BOLD}║${NC}"
        echo -e "${BRIGHT_GREEN}${BOLD}╠════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${BRIGHT_GREEN}${BOLD}║${NC}  ${CYAN}✓ Subfinder found:${NC} ${BRIGHT_GREEN}${BOLD}$subfinder_count${NC} ${CYAN}subdomains ✨${NC}                    ${BRIGHT_GREEN}${BOLD}║${NC}"
        echo -e "${BRIGHT_GREEN}${BOLD}║${NC}  ${CYAN}✓ Subdominator found:${NC} ${BRIGHT_YELLOW}${BOLD}$subdominator_count${NC} ${CYAN}subdomains ✨${NC}                ${BRIGHT_GREEN}${BOLD}║${NC}"
        echo -e "${BRIGHT_GREEN}${BOLD}║${NC}  ${CYAN}✓ Chaos found:${NC} ${BRIGHT_PURPLE}${BOLD}$chaos_count${NC} ${CYAN}subdomains ❤️${NC}                        ${BRIGHT_GREEN}${BOLD}║${NC}"
        echo -e "${BRIGHT_GREEN}${BOLD}║${NC}  ${CYAN}✓ Total unique subdomains:${NC} ${BRIGHT_YELLOW}${BOLD}$total_count${NC} ${CYAN}✨${NC}                    ${BRIGHT_GREEN}${BOLD}║${NC}"
        echo -e "${BRIGHT_GREEN}${BOLD}║${NC}  ${CYAN}💡 Use -o <file> to save merged results ❤️${NC}                      ${BRIGHT_GREEN}${BOLD}║${NC}"
        echo -e "${BRIGHT_GREEN}${BOLD}╚════════════════════════════════════════════════════════════╝${NC}"
    fi
else
    # Domains file mode
    echo -e "${BRIGHT_CYAN}${BOLD}╔════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BRIGHT_CYAN}${BOLD}║${NC}  ${BRIGHT_PURPLE}${BOLD}✨ Running Subdomain Enumeration ✨${NC}                              ${BRIGHT_CYAN}${BOLD}║${NC}"
    echo -e "${BRIGHT_CYAN}${BOLD}║${NC}  ${BRIGHT_YELLOW}${BOLD}📁 Domains file:${NC} ${BRIGHT_GREEN}$domains_file${NC}                              ${BRIGHT_CYAN}${BOLD}║${NC}"
    echo -e "${BRIGHT_CYAN}${BOLD}╚════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    if [ "$use_output" = true ]; then
        echo -e "${BRIGHT_BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BRIGHT_GREEN}${BOLD}🔍 Running Subfinder ✨${NC}"
        echo -e "${BRIGHT_BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        subfinder -dL "$domains_file" -all -v | tee "$SUBFINDER_OUTPUT"
        subfinder_count=$(wc -l < "$SUBFINDER_OUTPUT" 2>/dev/null | tr -d ' ' || echo "0")
        echo ""
        echo -e "${BRIGHT_GREEN}${BOLD}✓ Subfinder found:${NC} ${BRIGHT_CYAN}${BOLD}$subfinder_count${NC} ${CYAN}subdomains ✨${NC}"
        
        echo ""
        echo -e "${BRIGHT_BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BRIGHT_YELLOW}${BOLD}⚡ Running Subdominator ✨${NC}"
        echo -e "${BRIGHT_BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        run_subdominator_file "$domains_file" "$SUBDOMINATOR_OUTPUT"
        subdominator_count=$(wc -l < "$SUBDOMINATOR_OUTPUT" 2>/dev/null | tr -d ' ' || echo "0")
        echo ""
        echo -e "${BRIGHT_YELLOW}${BOLD}✓ Subdominator found:${NC} ${BRIGHT_CYAN}${BOLD}$subdominator_count${NC} ${CYAN}subdomains ✨${NC}"
        
        echo ""
        echo -e "${BRIGHT_BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BRIGHT_PURPLE}${BOLD}🌀 Running Chaos for each domain ❤️${NC}"
        echo -e "${BRIGHT_BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        > "$CHAOS_OUTPUT"  # Create empty file
        while IFS= read -r line; do
            if [ -n "$line" ]; then
                echo -e "${BRIGHT_YELLOW}${BOLD}🎯 Processing with Chaos:${NC} ${BRIGHT_CYAN}$line${NC} ${BRIGHT_PURPLE}❤️${NC}"
                chaos -d "$line" | tee -a "$CHAOS_OUTPUT"
                echo ""
            fi
        done < "$domains_file"
        chaos_count=$(wc -l < "$CHAOS_OUTPUT" 2>/dev/null | tr -d ' ' || echo "0")
        echo ""
        echo -e "${BRIGHT_PURPLE}${BOLD}✓ Chaos found:${NC} ${BRIGHT_CYAN}${BOLD}$chaos_count${NC} ${CYAN}subdomains ❤️${NC}"
        
        # Merge results from all three tools
        echo ""
        echo -e "${BRIGHT_YELLOW}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BRIGHT_CYAN}${BOLD}✨ Merging results from subfinder, subdominator, and chaos ✨${NC}"
        echo -e "${BRIGHT_YELLOW}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        cat "$SUBFINDER_OUTPUT" "$SUBDOMINATOR_OUTPUT" "$CHAOS_OUTPUT" 2>/dev/null | sort -u > "$output_file"
        
        # Count total unique results (use already calculated counts if available, otherwise recalculate)
        if [ -z "$subfinder_count" ]; then
            subfinder_count=$(wc -l < "$SUBFINDER_OUTPUT" 2>/dev/null | tr -d ' ' || echo "0")
        fi
        if [ -z "$chaos_count" ]; then
            chaos_count=$(wc -l < "$CHAOS_OUTPUT" 2>/dev/null | tr -d ' ' || echo "0")
        fi
        if [ -z "$subdominator_count" ]; then
            subdominator_count=$(wc -l < "$SUBDOMINATOR_OUTPUT" 2>/dev/null | tr -d ' ' || echo "0")
        fi
        total_count=$(wc -l < "$output_file" 2>/dev/null || echo "0")
        total_count=$(echo "$total_count" | tr -d ' ')
        
        echo ""
        echo -e "${BRIGHT_GREEN}${BOLD}╔════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BRIGHT_GREEN}${BOLD}║${NC}  ${BRIGHT_WHITE}${BOLD}📊 Results Summary ❤️${NC}                                      ${BRIGHT_GREEN}${BOLD}║${NC}"
        echo -e "${BRIGHT_GREEN}${BOLD}╠════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${BRIGHT_GREEN}${BOLD}║${NC}  ${CYAN}✓ Subfinder found:${NC} ${BRIGHT_GREEN}${BOLD}$subfinder_count${NC} ${CYAN}subdomains ✨${NC}                    ${BRIGHT_GREEN}${BOLD}║${NC}"
        echo -e "${BRIGHT_GREEN}${BOLD}║${NC}  ${CYAN}✓ Subdominator found:${NC} ${BRIGHT_YELLOW}${BOLD}$subdominator_count${NC} ${CYAN}subdomains ✨${NC}                ${BRIGHT_GREEN}${BOLD}║${NC}"
        echo -e "${BRIGHT_GREEN}${BOLD}║${NC}  ${CYAN}✓ Chaos found:${NC} ${BRIGHT_PURPLE}${BOLD}$chaos_count${NC} ${CYAN}subdomains ❤️${NC}                        ${BRIGHT_GREEN}${BOLD}║${NC}"
        echo -e "${BRIGHT_GREEN}${BOLD}║${NC}  ${CYAN}✓ Total unique subdomains:${NC} ${BRIGHT_YELLOW}${BOLD}$total_count${NC} ${CYAN}✨${NC}                    ${BRIGHT_GREEN}${BOLD}║${NC}"
        echo -e "${BRIGHT_GREEN}${BOLD}║${NC}  ${CYAN}✓ Merged results saved to:${NC} ${BRIGHT_CYAN}${BOLD}$output_file${NC} ${CYAN}❤️${NC}        ${BRIGHT_GREEN}${BOLD}║${NC}"
        echo -e "${BRIGHT_GREEN}${BOLD}╚════════════════════════════════════════════════════════════╝${NC}"
    else
        echo -e "${BRIGHT_BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BRIGHT_GREEN}${BOLD}🔍 Subfinder Results ✨${NC}"
        echo -e "${BRIGHT_BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        subfinder -dL "$domains_file" -all -v | tee "$SUBFINDER_OUTPUT"
        subfinder_count=$(wc -l < "$SUBFINDER_OUTPUT" 2>/dev/null | tr -d ' ' || echo "0")
        echo ""
        echo -e "${BRIGHT_GREEN}${BOLD}✓ Subfinder found:${NC} ${BRIGHT_CYAN}${BOLD}$subfinder_count${NC} ${CYAN}subdomains ✨${NC}"
        
        echo ""
        echo -e "${BRIGHT_BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BRIGHT_YELLOW}${BOLD}⚡ Subdominator Results ✨${NC}"
        echo -e "${BRIGHT_BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        run_subdominator_file "$domains_file" "$SUBDOMINATOR_OUTPUT"
        subdominator_count=$(wc -l < "$SUBDOMINATOR_OUTPUT" 2>/dev/null | tr -d ' ' || echo "0")
        echo ""
        echo -e "${BRIGHT_YELLOW}${BOLD}✓ Subdominator found:${NC} ${BRIGHT_CYAN}${BOLD}$subdominator_count${NC} ${CYAN}subdomains ✨${NC}"
        
        echo ""
        echo -e "${BRIGHT_BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BRIGHT_PURPLE}${BOLD}🌀 Chaos Results ❤️${NC}"
        echo -e "${BRIGHT_BLUE}${BOLD}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        > "$CHAOS_OUTPUT"  # Create empty file
        while IFS= read -r line; do
            if [ -n "$line" ]; then
                echo -e "${BRIGHT_YELLOW}${BOLD}🎯 Processing:${NC} ${BRIGHT_CYAN}$line${NC} ${BRIGHT_PURPLE}❤️${NC}"
                chaos -d "$line" | tee -a "$CHAOS_OUTPUT"
                echo ""
            fi
        done < "$domains_file"
        chaos_count=$(wc -l < "$CHAOS_OUTPUT" 2>/dev/null | tr -d ' ' || echo "0")
        echo ""
        echo -e "${BRIGHT_PURPLE}${BOLD}✓ Chaos found:${NC} ${BRIGHT_CYAN}${BOLD}$chaos_count${NC} ${CYAN}subdomains ❤️${NC}"
        
        # Merge and count results
        MERGED_OUTPUT="$TEMP_DIR/merged_results.txt"
        cat "$SUBFINDER_OUTPUT" "$SUBDOMINATOR_OUTPUT" "$CHAOS_OUTPUT" 2>/dev/null | sort -u > "$MERGED_OUTPUT"
        
        # Count results
        subfinder_count=$(wc -l < "$SUBFINDER_OUTPUT" 2>/dev/null || echo "0")
        chaos_count=$(wc -l < "$CHAOS_OUTPUT" 2>/dev/null || echo "0")
        subdominator_count=$(wc -l < "$SUBDOMINATOR_OUTPUT" 2>/dev/null || echo "0")
        total_count=$(wc -l < "$MERGED_OUTPUT" 2>/dev/null || echo "0")
        
        echo ""
        echo -e "${BRIGHT_GREEN}${BOLD}╔════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BRIGHT_GREEN}${BOLD}║${NC}  ${BRIGHT_WHITE}${BOLD}📊 Results Summary ❤️${NC}                                      ${BRIGHT_GREEN}${BOLD}║${NC}"
        echo -e "${BRIGHT_GREEN}${BOLD}╠════════════════════════════════════════════════════════════╣${NC}"
        echo -e "${BRIGHT_GREEN}${BOLD}║${NC}  ${CYAN}✓ Subfinder found:${NC} ${BRIGHT_GREEN}${BOLD}$subfinder_count${NC} ${CYAN}subdomains ✨${NC}                    ${BRIGHT_GREEN}${BOLD}║${NC}"
        echo -e "${BRIGHT_GREEN}${BOLD}║${NC}  ${CYAN}✓ Subdominator found:${NC} ${BRIGHT_YELLOW}${BOLD}$subdominator_count${NC} ${CYAN}subdomains ✨${NC}                ${BRIGHT_GREEN}${BOLD}║${NC}"
        echo -e "${BRIGHT_GREEN}${BOLD}║${NC}  ${CYAN}✓ Chaos found:${NC} ${BRIGHT_PURPLE}${BOLD}$chaos_count${NC} ${CYAN}subdomains ❤️${NC}                        ${BRIGHT_GREEN}${BOLD}║${NC}"
        echo -e "${BRIGHT_GREEN}${BOLD}║${NC}  ${CYAN}✓ Total unique subdomains:${NC} ${BRIGHT_YELLOW}${BOLD}$total_count${NC} ${CYAN}✨${NC}                    ${BRIGHT_GREEN}${BOLD}║${NC}"
        echo -e "${BRIGHT_GREEN}${BOLD}║${NC}  ${CYAN}💡 Use -o <file> to save merged results ❤️${NC}                      ${BRIGHT_GREEN}${BOLD}║${NC}"
        echo -e "${BRIGHT_GREEN}${BOLD}╚════════════════════════════════════════════════════════════╝${NC}"
    fi
fi
