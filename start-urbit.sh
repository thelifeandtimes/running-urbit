#!/bin/bash

# --- CONFIGURATION ---
PIER_NAME="my-comet"
SESSION_NAME="urbit-session"
# Color codes for better visual separation
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
DIM='\033[2m'
BOLD='\033[1m'
NC='\033[0m' # No Color
# ---------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PILL_PATH="/home/thelifeandtimes/vanta/projects/urbit-work/workspace/pills/test/brass.pill"
# TODO: Replace with production pill URL and final pill before shipping.

# Function to print script messages with formatting
script_msg() {
    echo -e "${GREEN}${BOLD}==> ${NC}${BOLD}$1${NC}"
}

script_info() {
    echo -e "${CYAN}    $1${NC}"
}

script_error() {
    echo -e "${RED}Error: $1${NC}"
}

PKG_MANAGERS=()
PKG_MANAGER_LABEL="not detected"

detect_pkg_managers() {
    PKG_MANAGERS=()

    if command -v brew &> /dev/null; then
        PKG_MANAGERS+=("brew")
    fi

    if command -v apt &> /dev/null || command -v apt-get &> /dev/null; then
        PKG_MANAGERS+=("apt")
    fi

    if command -v dnf &> /dev/null; then
        PKG_MANAGERS+=("dnf")
    fi

    if command -v pacman &> /dev/null; then
        PKG_MANAGERS+=("pacman")
    fi

    if [ ${#PKG_MANAGERS[@]} -eq 0 ]; then
        PKG_MANAGER_LABEL="not detected"
    else
        PKG_MANAGER_LABEL="$(IFS=", "; echo "${PKG_MANAGERS[*]}")"
    fi
}

menu_select() {
    local prompt="$1"
    shift
    local options=("$@")
    local selected=0
    local total=${#options[@]}
    local key

    while true; do
        printf "\033[2K\r${CYAN}    %s${NC}\n" "$prompt"

        for i in "${!options[@]}"; do
            if [ "$i" -eq "$selected" ]; then
                printf "\033[2K\r${GREEN}    > %s${NC}\n" "${options[$i]}"
            else
                printf "\033[2K\r      %s\n" "${options[$i]}"
            fi
        done

        IFS= read -rsn1 key < /dev/tty
        if [[ -z "$key" ]]; then
            echo
            return "$selected"
        fi

        if [[ "$key" =~ [1-9] ]] && [ "$key" -le "$total" ]; then
            echo
            return $((key - 1))
        fi

        if [[ "$key" == $'\x1b' ]]; then
            read -rsn2 key < /dev/tty
            if [[ "$key" == "[A" ]]; then
                if [ "$selected" -gt 0 ]; then
                    selected=$((selected - 1))
                fi
            elif [[ "$key" == "[B" ]]; then
                if [ "$selected" -lt $((total - 1)) ]; then
                    selected=$((selected + 1))
                fi
            fi
        fi

        printf "\033[%dA" $((total + 1))
    done
}

install_hint() {
    local pkg="$1"

    if [ ${#PKG_MANAGERS[@]} -eq 0 ]; then
        script_info "Install $pkg with your package manager."
        return
    fi

    for manager in "${PKG_MANAGERS[@]}"; do
        case "$manager" in
            brew)
                script_info "Install with: brew install $pkg"
                ;;
            apt)
                script_info "Install with: sudo apt install $pkg"
                ;;
            dnf)
                script_info "Install with: sudo dnf install $pkg"
                ;;
            pacman)
                script_info "Install with: sudo pacman -S $pkg"
                ;;
        esac
    done
}

wrap_list() {
    local label="$1"
    shift
    local items=("$@")
    local line=""
    local first=1

    for item in "${items[@]}"; do
        if [ -z "$line" ]; then
            line="$item"
        else
            line="$line $item"
        fi

        if [ ${#line} -ge 52 ]; then
            if [ "$first" -eq 1 ]; then
                script_info "${BOLD}${label}:${NC} $line"
                first=0
            else
                script_info "$line"
            fi
            line=""
        fi
    done

    if [ -n "$line" ]; then
        if [ "$first" -eq 1 ]; then
            script_info "${BOLD}${label}:${NC} $line"
        else
            script_info "$line"
        fi
    fi
}

AVAILABLE_TOOLS=()

check_dependencies() {
    local required=("$@")
    local missing=()
    local available=()

    for cmd in "${required[@]}"; do
        if command -v "$cmd" &> /dev/null; then
            available+=("$cmd")
        else
            missing+=("$cmd")
        fi
    done

    if command -v wl-copy &> /dev/null; then
        available+=("wl-copy")
    fi

    if command -v xclip &> /dev/null; then
        available+=("xclip")
    fi

    if command -v pbcopy &> /dev/null; then
        available+=("pbcopy")
    fi

    if [ ${#missing[@]} -gt 0 ]; then
        script_error "Missing required tools."
        wrap_list "Missing" "${missing[@]}"
        for cmd in "${missing[@]}"; do
            install_hint "$cmd"
        done
        script_info "Install the missing tools, then re-run."
        read -r -p "Press Enter to exit." _ < /dev/tty
        exit 1
    fi

    AVAILABLE_TOOLS=("${available[@]}")
}

get_runtime_label() {
    if [ -x "./urbit" ]; then
        local version
        version=$(./urbit --version 2>/dev/null | head -n 1)
        if [ -n "$version" ]; then
            echo "$version"
            return
        fi
    fi

    echo "urbit (latest)"
}

detect_ship_name() {
    local ship=""

    if [ ! -f "$LOGFILE" ]; then
        return
    fi

    ship=$(grep -E "mdns: .* registered" "$LOGFILE" | tail -1 | sed -n 's/.*mdns: \([^ ]*\) registered.*/\1/p')
    if [ -z "$ship" ]; then
        ship=$(grep -E "pier .* live" "$LOGFILE" | tail -1 | sed -n 's/.*pier \(~\?[a-z-]*\) live.*/\1/p')
    fi

    if [ -n "$ship" ]; then
        if [[ "$ship" != ~* ]]; then
            ship="~$ship"
        fi
        echo "$ship"
    fi
}

ensure_pill() {
    if [ ! -f "$PILL_PATH" ]; then
        script_error "Boot pill not found."
        script_info "Expected pill path:"
        script_info "~/projects/urbit-work/workspace/pills/test/brass.pill"
        script_info "This script expects a local test pill for now."
        exit 1
    fi
}

# Function to strip ANSI escape sequences and format log output
format_log() {
    # Strip ANSI escape sequences and dim each line
    while IFS= read -r line; do
        # Remove all ANSI escape sequences
        clean_line=$(echo "$line" | sed 's/\x1B\[[0-9;]*[A-Za-z]//g' | sed 's/\x1B\]//g' | sed 's/\r//g')
        echo -e "${DIM}${clean_line}${NC}"
    done
}

# 0. Setup and Safety Cleanup
clear
cd ~
mkdir -p running-urbit-quest
cd running-urbit-quest || exit

# Kill any zombie tail processes from previous runs
if command -v pkill &> /dev/null; then
    pkill -f "tail -f.*urbit-boot.log" 2>/dev/null
fi

OS="$(uname -s)"; ARCH="$(uname -m)"
# 1. Detect System & URL
if [ "$OS" = "Linux" ]; then
   OPEN_CMD="xdg-open"
   if [ "$ARCH" = "x86_64" ]; then URL="https://urbit.org/install/linux-x86_64/latest";
   elif [ "$ARCH" = "aarch64" ]; then URL="https://urbit.org/install/linux-aarch64/latest"; fi
elif [ "$OS" = "Darwin" ]; then
   OPEN_CMD="open"
   if [ "$ARCH" = "x86_64" ]; then URL="https://urbit.org/install/macos-x86_64/latest";
   elif [ "$ARCH" = "arm64" ]; then URL="https://urbit.org/install/macos-aarch64/latest";
   else script_error "Unknown macOS system architecture"; exit 1; fi
fi

if [ -z "$URL" ]; then script_error "Unsupported System."; exit 1; fi

detect_pkg_managers

# 2. Dependency Checks
check_dependencies "curl" "tar" "screen" "grep" "sed" "tail" "$OPEN_CMD"

# 3. Download (Silent)
if [ ! -f "./urbit" ]; then
   script_msg "Downloading Urbit runtime..."
   if [ "$OS" = "Darwin" ]; then
       curl -sS -L "$URL" | tar xzk -s '/.*/urbit/'
   elif [ "$OS" = "Linux" ]; then
       curl -sS -L "$URL" | tar xzk --transform='s/.*/urbit/g'
   fi
fi

RUNTIME_LABEL=$(get_runtime_label)

script_msg "Environment"
script_info "${BOLD}OS:${NC} $OS ($ARCH)"
script_info "${BOLD}Runtime:${NC} $RUNTIME_LABEL"
script_info "${BOLD}Pkg mgr:${NC} $PKG_MANAGER_LABEL"

if [ ${#AVAILABLE_TOOLS[@]} -gt 0 ]; then
    wrap_list "Available" "${AVAILABLE_TOOLS[@]}"
fi

RECONNECT_MODE=0

# 4. Check for duplicate screen session
if screen -list | grep -q "$SESSION_NAME"; then
   script_msg "Session '$SESSION_NAME' already running."
   SESSION_OPTIONS=(
       "Reconnect script (logs + browser)"
       "Attach to screen"
       "Exit"
   )

   menu_select "Choose an option (↑/↓ + Enter):" "${SESSION_OPTIONS[@]}"
   SESSION_CHOICE=$?

   case "$SESSION_CHOICE" in
       0)
           RECONNECT_MODE=1
           ;;
       1)
           script_msg "Attaching to screen..."
           screen -r "$SESSION_NAME"
           exit 0
           ;;
       2)
           script_msg "Exiting without changes."
           exit 0
           ;;
       *)
           script_error "Invalid choice."
           exit 1
           ;;
   esac
fi

# 5. Config Setup (Persistent)
WORK_DIR=$(pwd)
LOGFILE="$WORK_DIR/urbit-boot.log"
CONFIG_FILE="$WORK_DIR/.screenrc.urbit"

if [ "$RECONNECT_MODE" -eq 0 ]; then
    rm -f "$LOGFILE"
fi

cat <<EOF > "$CONFIG_FILE"
logfile $LOGFILE
logfile flush 0
defscrollback 5000
msgwait 0
EOF

if [ "$RECONNECT_MODE" -eq 1 ] && [ ! -f "$LOGFILE" ]; then
    script_error "Log file not found."
    script_info "Expected: ~/running-urbit-quest/urbit-boot.log"
    script_info "Try: screen -r $SESSION_NAME"
    exit 1
fi

# 6. Prepare boot command
if [ -d "$PIER_NAME" ]; then
   script_msg "Found existing ship '$PIER_NAME'."
   PIER_OPTIONS=(
       "Resume (pick up where you left off)"
       "Recreate (delete and restart)"
       "Delete (delete piers and runtime)"
       "Exit (close this program)"
   )

   menu_select "Choose an option (↑/↓ + Enter):" "${PIER_OPTIONS[@]}"
   PIER_CHOICE=$?

   case "$PIER_CHOICE" in
       0)
           script_msg "Resuming existing ship '$PIER_NAME'..."
           CMD="./urbit $PIER_NAME"
           ;;
       1)
           read -r -p "Type RECREATE to confirm: " CONFIRM < /dev/tty
           if [ "$CONFIRM" != "RECREATE" ]; then
               script_msg "Recreate canceled."
               exit 0
           fi
           script_msg "Deleting existing ship '$PIER_NAME'..."
           rm -rf "$PIER_NAME"
           ensure_pill
           script_msg "Creating new Comet '$PIER_NAME'..."
           CMD="./urbit -B \"$PILL_PATH\" -c $PIER_NAME"
           ;;
       2)
           read -r -p "Type DELETE to confirm: " CONFIRM < /dev/tty
           if [ "$CONFIRM" != "DELETE" ]; then
               script_msg "Delete canceled."
               exit 0
           fi
           script_msg "Deleting ship '$PIER_NAME'..."
           rm -rf "$PIER_NAME"
           script_msg "Removing runtime and logs..."
           rm -f "$WORK_DIR/urbit" "$LOGFILE" "$CONFIG_FILE"
           script_msg "Cleanup complete."
           exit 0
           ;;
       3)
           script_msg "Exiting without changes."
           exit 0
           ;;
       *)
           script_error "Invalid choice."
           exit 1
           ;;
   esac
else
   ensure_pill
   script_msg "Creating new Comet '$PIER_NAME'..."
   CMD="./urbit -B \"$PILL_PATH\" -c $PIER_NAME"
fi

# 7. Start Session
if [ "$RECONNECT_MODE" -eq 0 ]; then
    script_msg "Launching screen session '$SESSION_NAME'..."

    screen -L -c "$CONFIG_FILE" -dmS "$SESSION_NAME" bash -c "$CMD; exec bash"

    sleep 2

    if ! screen -list | grep -q "$SESSION_NAME"; then
        script_error "Screen session died immediately."
        exit 1
    fi
else
    if ! screen -list | grep -q "$SESSION_NAME"; then
        script_error "Screen session is no longer running."
        exit 1
    fi
    script_msg "Reconnected to running session '$SESSION_NAME'."
fi

echo -e "\n${YELLOW}════════════════════════════════════════════════════════════════${NC}"
script_msg "Urbit is running. Booting..."
script_info "Watching for the web interface."
echo -e "${YELLOW}════════════════════════════════════════════════════════════════${NC}\n"

# ----------------------------------------------
# PHASE 1: Wait for URL
# ----------------------------------------------

FILTER_PATTERN="urbit [0-9]|boot: downloading|boot: home|boot: found|bootstrap|clay: kernel|clay: base|vere: checking|http: web interface|pier .* live|mdns: .* registered"

# ----------------------------------------------
# PHASE 2: Wait for URL
# ----------------------------------------------

URL_FOUND=""
URL_TIMEOUT=600
COUNTER=0

while [ $COUNTER -lt $URL_TIMEOUT ]; do
   if [ -f "$LOGFILE" ]; then
       DETECTED_URL=$(grep "http: web interface live on http://localhost:" "$LOGFILE" | grep -o "http://localhost:[0-9]*" | tail -1)
       if [ ! -z "$DETECTED_URL" ]; then
           URL_FOUND="$DETECTED_URL"
           break
       fi
   fi
   sleep 2
   ((COUNTER+=2))
done

if [ -z "$URL_FOUND" ]; then
    script_error "Timeout waiting for Urbit URL."
    exit 1
fi

# ==========================================================
# PAUSE! Clean up the terminal
# ==========================================================

echo ""
sleep 1

echo -e "\n${BLUE}════════════════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}${BOLD}✓ Web interface is live at ${YELLOW}$URL_FOUND${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}\n"

# ----------------------------------------------
# PHASE 3: Get Code (Quietly)
# ----------------------------------------------

script_msg "Waiting for Dojo to retrieve +code..."
sleep 15

if screen -list | grep -q "$SESSION_NAME"; then
    screen -S "$SESSION_NAME" -p 0 -X stuff "+code$(printf \\r)"
else
    script_error "Screen session died unexpectedly."
    exit 1
fi

# Wait for code
CODE_FOUND=""
CODE_COUNTER=0
while [ $CODE_COUNTER -lt 20 ]; do
   if [ -f "$LOGFILE" ]; then
        DETECTED_CODE=$(grep -A 5 "+code" "$LOGFILE" | grep -oE "[~]?[a-z]{6}-[a-z]{6}-[a-z]{6}-[a-z]{6}" | tail -1 | tr -d '\r')

        if [ ! -z "$DETECTED_CODE" ]; then
            CODE_FOUND="$DETECTED_CODE"
            break
        fi

   fi
   sleep 1
   ((CODE_COUNTER++))
done

LOGIN_URL="$URL_FOUND"

if [ ! -z "$CODE_FOUND" ]; then
   CODE_TOKEN="${CODE_FOUND#~}"
   echo -e "\n${BLUE}════════════════════════════════════════════════════════════════${NC}"
   echo -e "${GREEN}${BOLD}✓ LOGIN CODE: ${YELLOW}${BOLD}$CODE_TOKEN${NC}"
   echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    if [ "$OS" = "Darwin" ]; then
        echo -n "$CODE_TOKEN" | pbcopy
        echo -e "${CYAN}(Copied to macOS clipboard)${NC}"
    elif command -v wl-copy &> /dev/null; then
        echo -n "$CODE_TOKEN" | wl-copy
        echo -e "${CYAN}(Copied to Linux clipboard via wl-copy)${NC}"
    elif command -v xclip &> /dev/null; then
        echo -n "$CODE_TOKEN" | xclip -selection clipboard
        echo -e "${CYAN}(Copied to Linux clipboard via xclip)${NC}"
    else
        script_info "Clipboard tool not found."
        script_info "Install wl-clipboard or xclip."
    fi

    LOGIN_URL=$(printf "%s/apps/hawk/login/%s" "$URL_FOUND" "$CODE_TOKEN")
    script_info "Auto-login URL:"
    script_info "$LOGIN_URL"
else
   script_msg "Could not retrieve code automatically."
fi

SHIP_NAME=$(detect_ship_name)
if [ -n "$SHIP_NAME" ]; then
    script_info "Comet: $SHIP_NAME"
fi

echo ""
script_msg "Opening Browser..."
sleep 2
$OPEN_CMD "$LOGIN_URL"

# ----------------------------------------------
# PHASE 4: Interactive Monitor (Resume)
# ----------------------------------------------

echo -e "\n${YELLOW}════════════════════════════════════════════════════════════════${NC}"
echo -e "${BOLD}Urbit is running in background session '$SESSION_NAME'.${NC}"
echo -e "${DIM}Live logs appear below.${NC}"
echo -e "${CYAN}Press 'q' to quit (Urbit stays running).${NC}"
echo -e "${RED}Press 'x' to kill Urbit and exit.${NC}"
echo -e "${YELLOW}════════════════════════════════════════════════════════════════${NC}\n"

# Restart monitor with error suppression
tail -f "$LOGFILE" 2>/dev/null | grep --line-buffered -E "$FILTER_PATTERN" | format_log &
TAIL_PID=$!
trap "kill $TAIL_PID 2>/dev/null" EXIT

while true; do
    read -n 1 -s -r -p "" INPUT < /dev/tty
    if [[ "$INPUT" == "q" ]]; then
        echo ""
        script_msg "Exiting monitor."
        disown $TAIL_PID
        kill $TAIL_PID 2>/dev/null
        break
    elif [[ "$INPUT" == "x" ]]; then
        echo ""
        script_msg "Killing Urbit session..."
        disown $TAIL_PID
        kill $TAIL_PID 2>/dev/null
        screen -S "$SESSION_NAME" -X quit
        script_msg "Done."
        break
    fi
done
