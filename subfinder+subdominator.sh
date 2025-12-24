#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
RESET='\033[0m'

# ✨ Subfinder + Subdominator Automation Output ✨
# 💖 Made with Love 💖

# Function to print banner
print_banner() {
    echo -e "${MAGENTA}"
    echo -e " ✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨"
    echo -e " ✨                                      ✨"
    echo -e " ✨      ${CYAN}SUBDOMAIN AUTOMATION${MAGENTA}              ✨"
    echo -e " ✨      ${YELLOW}Automate with ❤️  and ✨${MAGENTA}        ✨"
    echo -e " ✨                                      ✨"
    echo -e " ✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨"
    echo -e "${RESET}"
}

# Function to display help
usage() {
    print_banner
    echo -e "${MAGENTA}Usage: $0 [options]${RESET}"
    echo ""
    echo -e "${YELLOW}Options:${RESET}"
    echo "  -d   <domain>    Target domain for single scan"
    echo "  -dL  <file>      File containing list of domains"
    echo "  -o   <file>      Output file to save results (Optional)"
    echo ""
    echo -e "${YELLOW}Examples:${RESET}"
    echo "  $0 -d example.com -o sub.txt"
    echo "  $0 -dL domains.txt -o results.txt"
    exit 1
}

# Check if arguments are provided
if [ $# -eq 0 ]; then
    usage
fi

# Variables
DOMAIN=""
LIST=""
OUTPUT=""

# Parse arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -d) DOMAIN="$2"; shift ;;
        -dL) LIST="$2"; shift ;;
        -o) OUTPUT="$2"; shift ;;
        *) echo -e "${RED}❌ Unknown parameter passed: $1${RESET}"; usage ;;
    esac
    shift
done

# Validate requirements
if [[ -z "$DOMAIN" && -z "$LIST" ]]; then
    echo -e "${RED}❌ Error: Please provide a domain (-d) or a list (-dL).${RESET}"
    exit 1
fi

# Check for expect
if ! command -v expect &> /dev/null; then
    echo -e "${RED}❌ Error: 'expect' is not installed. Please install it (brew install expect).${RESET}"
    exit 1
fi

# Temporary files for merging
TEMP_SUBFINDER="temp_subfinder_out.txt"
TEMP_SUBDOMINATOR="temp_subdominator_out.txt"

# Function to run subdominator using expect
run_subdominator_expect() {
    local CMD_ARGS="$1"
    local DOMAIN_COUNT="$2"
    
    EXPECT_SCRIPT=$(mktemp)
    
    # Create the expect script
    cat <<EOF > "$EXPECT_SCRIPT"
#!/usr/bin/expect -f
set timeout -1
set domain_count $DOMAIN_COUNT
set completed 0
spawn subdominator $CMD_ARGS
expect {
    "Happy Hacking root" {
        incr completed
        if { \$completed >= \$domain_count } {
            send_user "\n\033\[0;35m✨ Detected final completion message! Stopping... 💖\033\[0m\n"
            close
            exit 0
        }
        exp_continue
    }
    eof {
        exit 0
    }
}
EOF

    chmod +x "$EXPECT_SCRIPT"
    
    # Run the expect script
    # We rely on subdominator's -o flag for the specific file output, 
    # but we can show stdout to the user as well.
    "$EXPECT_SCRIPT"
    
    rm -f "$EXPECT_SCRIPT"
}

print_banner
echo -e "${MAGENTA}✨ 💖 Starting Reconnaissance with Love 💖 ✨${RESET}"
echo -e "${CYAN}----------------------------------------${RESET}"

# Logic for Single Domain
if [[ -n "$DOMAIN" ]]; then
    echo -e "${MAGENTA}💝 Running Subfinder for: ${YELLOW}$DOMAIN${RESET}"
    subfinder -d "$DOMAIN" -v -all -o "$TEMP_SUBFINDER"
    
    echo -e "${MAGENTA}💝 Running Subdominator for: ${YELLOW}$DOMAIN${RESET}"
    run_subdominator_expect "-d $DOMAIN -V -all -o "$TEMP_SUBDOMINATOR"" 1

# Logic for List of Domains
elif [[ -n "$LIST" ]]; then
    echo -e "${MAGENTA}💝 Running Subfinder for list: ${YELLOW}$LIST${RESET}"
    subfinder -dL "$LIST" -v -all -o "$TEMP_SUBFINDER"
    
    echo -e "${MAGENTA}💝 Running Subdominator for list: ${YELLOW}$LIST${RESET}"
    # Count non-empty lines in the list
    COUNT=$(grep -c . "$LIST")
    run_subdominator_expect "-dL "$LIST" -V -all -o "$TEMP_SUBDOMINATOR"" "$COUNT"
fi

# Merging Results
echo -e "${CYAN}----------------------------------------${RESET}"
echo -e "${MAGENTA}✨ Merging and Cleaning Results... 💖${RESET}"

COMBINED_COUNT=0
if [[ -f "$TEMP_SUBFINDER" && -f "$TEMP_SUBDOMINATOR" ]]; then
    if [[ -n "$OUTPUT" ]]; then
        cat "$TEMP_SUBFINDER" "$TEMP_SUBDOMINATOR" 2>/dev/null | sort -u > "$OUTPUT"
        COMBINED_COUNT=$(wc -l < "$OUTPUT" | xargs)
    else
        # No output file, dry run merge to just count or display
        # If we just display, we can pipe to sort -u and then tee to /dev/tty or similar, 
        # but the user probably wants to see them.
        # Let's count them first.
        sort -u "$TEMP_SUBFINDER" "$TEMP_SUBDOMINATOR" 2>/dev/null > "temp_merged_all.txt"
        COMBINED_COUNT=$(wc -l < "temp_merged_all.txt" | xargs)
        cat "temp_merged_all.txt"
        rm -f "temp_merged_all.txt"
    fi
elif [[ -f "$TEMP_SUBFINDER" ]]; then
    if [[ -n "$OUTPUT" ]]; then
        cat "$TEMP_SUBFINDER" | sort -u > "$OUTPUT"
        COMBINED_COUNT=$(wc -l < "$OUTPUT" | xargs)
    else
        sort -u "$TEMP_SUBFINDER" > "temp_merged_all.txt"
        COMBINED_COUNT=$(wc -l < "temp_merged_all.txt" | xargs)
        cat "temp_merged_all.txt"
        rm -f "temp_merged_all.txt"
    fi
elif [[ -f "$TEMP_SUBDOMINATOR" ]]; then
    if [[ -n "$OUTPUT" ]]; then
        cat "$TEMP_SUBDOMINATOR" | sort -u > "$OUTPUT"
        COMBINED_COUNT=$(wc -l < "$OUTPUT" | xargs)
    else
        sort -u "$TEMP_SUBDOMINATOR" > "temp_merged_all.txt"
        COMBINED_COUNT=$(wc -l < "temp_merged_all.txt" | xargs)
        cat "temp_merged_all.txt"
        rm -f "temp_merged_all.txt"
    fi
else
    echo -e "${YELLOW}⚠️  No output generated to merge.${RESET}"
fi

# Remove temp files
rm -f "$TEMP_SUBFINDER" "$TEMP_SUBDOMINATOR"

# Final Stats
echo -e "${CYAN}----------------------------------------${RESET}"
if [[ "$COMBINED_COUNT" -gt 0 ]]; then
    echo -e "${GREEN}✅ Search Completed! 💖${RESET}"
    echo -e "${MAGENTA}✨ Total Unique Subdomains Found: ${YELLOW}$COMBINED_COUNT ${MAGENTA}✨${RESET}"
    if [[ -n "$OUTPUT" ]]; then
        echo -e "${BLUE}📂 Outcomes saved to: ${YELLOW}$OUTPUT${RESET}"
    else
        echo -e "${BLUE}📂 Outcomes displayed above (not saved to file)${RESET}"
    fi
    echo -e "${MAGENTA}💖 Happy Hacking! 💖${RESET}"
else
    echo -e "${RED}⚠️  No subdomains found or errors occurred. 💔${RESET}"
fi
