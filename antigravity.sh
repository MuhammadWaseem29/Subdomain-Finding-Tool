#!/bin/bash

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
RESET='\033[0m'
BOLD='\033[1m'

# API Keys
export PDCP_API_KEY="45c4a78e-957e-486f-80b9-f506362d9ae4"

# Logs and Outputs (Global scope)
SUBFINDER_LOG=$(mktemp)
SUBDOM_LOG=$(mktemp)
CHAOS_LOG=$(mktemp)
SF_OUT=$(mktemp)
SD_OUT=$(mktemp)
CH_OUT=$(mktemp)

# Cleanup function
cleanup() {
    rm -f "$SUBFINDER_LOG" "$SUBDOM_LOG" "$CHAOS_LOG" "$SF_OUT" "$SD_OUT" "$CH_OUT"
}
trap cleanup EXIT

# Function to print banner
print_banner() {
    clear
    echo -e "${MAGENTA}"
    echo -e " ✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨"
    echo -e " ✨                                      ✨"
    echo -e " ✨      ${CYAN}ANTIGRAVITY ENGINE${MAGENTA}              ✨"
    echo -e " ✨      ${YELLOW}Automate with ❤️  and ✨${MAGENTA}        ✨"
    echo -e " ✨                                      ✨"
    echo -e " ✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨✨"
    echo -e "${RESET}"
}

# Function to display usage
usage() {
    echo -e ""
    echo -e " ${CYAN}USAGE:${RESET}"
    echo -e "   ${GREEN}$0 -d <domain> [-o <output_file>]${RESET}"
    echo -e "   ${GREEN}$0 -dL <domain_list> [-o <output_file>]${RESET}"
    echo -e ""
    echo -e " ${YELLOW}OPTIONS:${RESET}"
    echo -e "   ${BLUE}-d${RESET}    Single domain to search"
    echo -e "   ${BLUE}-dL${RESET}   List of domains to search"
    echo -e "   ${BLUE}-o${RESET}    Output file (optional)"
    echo -e ""
    echo -e " ${MAGENTA}EXAMPLES:${RESET}"
    echo -e "   ${CYAN}$0 -d example.com${RESET}"
    echo -e "   ${CYAN}$0 -d example.com -o subs.txt${RESET}"
    echo -e "   ${CYAN}$0 -dL domains.txt -o subs.txt${RESET}"
    echo -e ""
    echo -e " ✨ Make something awesome! ❤️"
    exit 1
}

# Initialize variables
DOMAIN=""
DOMAIN_LIST=""
OUTPUT_FILE=""

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -d) DOMAIN="$2"; shift ;;
        -dL) DOMAIN_LIST="$2"; shift ;;
        -o) OUTPUT_FILE="$2"; shift ;;
        *) usage ;;
    esac
    shift
done

# Print banner
print_banner

# Validation
if [[ -z "$DOMAIN" && -z "$DOMAIN_LIST" ]]; then
    echo -e " ${RED}❤️  Error: You must provide a domain (-d) or a domain list (-dL) ✨${RESET}"
    usage
fi

if [[ -n "$DOMAIN" && -n "$DOMAIN_LIST" ]]; then
    echo -e " ${RED}❤️  Error: Please provide either -d or -dL, not both! ✨${RESET}"
    usage
fi

# Check if tools are installed
if ! command -v subfinder &> /dev/null; then
    echo -e " ${RED}❤️  Error: subfinder is not installed or not in your PATH! ✨${RESET}"
    exit 1
fi

if ! command -v subdominator &> /dev/null; then
    echo -e " ${RED}❤️  Error: subdominator is not installed or not in your PATH! ✨${RESET}"
    exit 1
fi

if ! command -v expect &> /dev/null; then
     echo -e " ${RED}❤️  Error: expect is not installed. Please install it (brew install expect) ✨${RESET}"
     exit 1
fi

if ! command -v chaos &> /dev/null; then
    echo -e " ${RED}❤️  Error: chaos is not installed or not in your PATH! ✨${RESET}"
    exit 1
fi


# ==========================================
# SECTION 1: SUBFINDER
# ==========================================
echo -e " ${CYAN}✨ [Section 1] Starting Subfinder... ❤️${RESET}"
echo -e ""

# Construct command
CMD="subfinder -v -all -o $SF_OUT"

if [[ -n "$DOMAIN" ]]; then
    CMD="$CMD -d $DOMAIN"
    echo -e " ${CYAN}✨ Target Domain: ${YELLOW}$DOMAIN ❤️${RESET}"
elif [[ -n "$DOMAIN_LIST" ]]; then
    CMD="$CMD -dL $DOMAIN_LIST"
    echo -e " ${CYAN}✨ Target List: ${YELLOW}$DOMAIN_LIST ❤️${RESET}"
fi



echo -e ""
echo -e " ${MAGENTA}✨ Running Subfinder magic... please wait... ❤️${RESET}"
echo -e ""

# Execute subfinder - Capture stderr to logs too
eval "$CMD" 2>&1 | tee "$SUBFINDER_LOG"

echo -e ""
echo -e " ${GREEN}✨ Subfinder Completed! ❤️${RESET}"
echo -e ""

# ==========================================
# SECTION 2: SUBDOMINATOR
# ==========================================
echo -e " ${CYAN}✨ [Section 2] Starting Subdominator... ❤️${RESET}"
echo -e ""

# Construct command args for expect
SUBDOM_ARGS="-V -all -o $SD_OUT"

if [[ -n "$DOMAIN" ]]; then
    SUBDOM_ARGS="$SUBDOM_ARGS -d $DOMAIN"
    echo -e " ${CYAN}✨ Target Domain: ${YELLOW}$DOMAIN ❤️${RESET}"
elif [[ -n "$DOMAIN_LIST" ]]; then
    SUBDOM_ARGS="$SUBDOM_ARGS -dL $DOMAIN_LIST"
    echo -e " ${CYAN}✨ Target List: ${YELLOW}$DOMAIN_LIST ❤️${RESET}"
fi



echo -e ""
echo -e " ${MAGENTA}✨ Running Subdominator magic... please wait... ❤️${RESET}"
echo -e ""

# Calculate domain count for list processing
DOMAIN_COUNT=1
if [[ -n "$DOMAIN_LIST" ]]; then
    DOMAIN_COUNT=$(grep -c . "$DOMAIN_LIST")
fi

# Execute subdominator using expect
EXPECT_SCRIPT=$(mktemp)

cat <<EOF > "$EXPECT_SCRIPT"
#!/usr/bin/expect -f
set timeout -1
set domain_count $DOMAIN_COUNT
set completed 0
spawn subdominator $SUBDOM_ARGS
expect {
    "Happy Hacking root" {
        incr completed
        if { \$completed >= \$domain_count } {
            send_user "\n✨ Detected final completion message! Stopping... ❤️\n"
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
# Run expect script and capture output
"$EXPECT_SCRIPT" 2>&1 | tee "$SUBDOM_LOG"
rm -f "$EXPECT_SCRIPT"


echo -e ""
echo -e " ${GREEN}✨ Subdominator Completed! ❤️${RESET}"
echo -e ""

# ==========================================
# SECTION 3: CHAOS
# ==========================================
echo -e " ${CYAN}✨ [Section 3] Starting Chaos... ❤️${RESET}"
echo -e ""

# Construct command
CMD_CHAOS="chaos -o $CH_OUT"

if [[ -n "$DOMAIN" ]]; then
    CMD_CHAOS="$CMD_CHAOS -d $DOMAIN"
    echo -e " ${CYAN}✨ Target Domain: ${YELLOW}$DOMAIN ❤️${RESET}"
elif [[ -n "$DOMAIN_LIST" ]]; then
    CMD_CHAOS="$CMD_CHAOS -dL $DOMAIN_LIST"
    echo -e " ${CYAN}✨ Target List: ${YELLOW}$DOMAIN_LIST ❤️${RESET}"
fi



echo -e ""
echo -e " ${MAGENTA}✨ Running Chaos magic... please wait... ❤️${RESET}"
echo -e ""

# Execute chaos
eval "$CMD_CHAOS" 2>&1 | tee "$CHAOS_LOG"

echo -e ""
echo -e " ${GREEN}✨ Chaos Completed! ❤️${RESET}"
echo -e ""

# Get accurate counts from clean output files
SF_COUNT=$(wc -l < "$SF_OUT" | awk '{print $1}')
SD_COUNT=$(wc -l < "$SD_OUT" | awk '{print $1}')
CH_COUNT=$(wc -l < "$CH_OUT" | awk '{print $1}')

# Calculate Total Unique
ALL_SUBS_TMP=$(mktemp)
cat "$SF_OUT" "$SD_OUT" "$CH_OUT" > "$ALL_SUBS_TMP"
TOTAL_UNIQUE=$(sort -u "$ALL_SUBS_TMP" | grep -v "^$" | wc -l | awk '{print $1}')
rm -f "$ALL_SUBS_TMP"

# Fallback to 0 if empty
SF_COUNT=${SF_COUNT:-0}
SD_COUNT=${SD_COUNT:-0}
CH_COUNT=${CH_COUNT:-0}

echo -e "${MAGENTA}========================================${RESET}"
echo -e "${YELLOW}           ✨ STATISTICS ✨             ${RESET}"
echo -e "${MAGENTA}========================================${RESET}"
echo -e " ${CYAN}Subfinder Found    :${RESET} ${GREEN}${SF_COUNT}${RESET}"
echo -e " ${CYAN}Subdominator Found :${RESET} ${GREEN}${SD_COUNT}${RESET}"
echo -e " ${CYAN}Chaos Found        :${RESET} ${GREEN}${CH_COUNT}${RESET}"
echo -e "${MAGENTA}----------------------------------------${RESET}"
echo -e " ${BOLD}${YELLOW}Total Unique Found :${RESET} ${BOLD}${GREEN}${TOTAL_UNIQUE}${RESET}"
echo -e "${MAGENTA}========================================${RESET}"

# Save to output file if specified
if [[ -n "$OUTPUT_FILE" ]]; then
    echo -e " ${CYAN}✨ Saving Unique Subdomains to: ${YELLOW}$OUTPUT_FILE ❤️${RESET}"
    cat "$SF_OUT" "$SD_OUT" "$CH_OUT" | sort -u | grep -v "^$" > "$OUTPUT_FILE"
    echo -e " ${GREEN}✨ Done! Subdomains saved to $OUTPUT_FILE ✨${RESET}"
fi

echo -e ""