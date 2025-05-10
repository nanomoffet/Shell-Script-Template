#!/bin/bash

# ==============================================================================
# Script Name:   script_template.sh
# Description:   A template for new Bash scripts, demonstrating common practices
#                and usage of gh, jq, gum, and standard Linux utilities.
# Author:        [Your Name/Organization]
# Date:          Fri May 09 2025
# Version:       1.0.0
# Usage:         ./script_template.sh [-v] [-f <file>] [-o <output_dir>] [arg1 arg2 ...]
# Requirements:  bash, gh, jq, gum, coreutils (grep, sed, awk, date, etc.)
# License:       MIT
# ==============================================================================

# --- Configuration ---
# Strict mode: Exit on error, unset variable, and pipe failure
set -eou pipefail

# --- Script Variables ---
SCRIPT_NAME=$(basename "$0")
SCRIPT_DIR=$(dirname "$(readlink -f "$0")") # Absolute path to script's directory
VERBOSE=false
INPUT_FILE=""
OUTPUT_DIR="."
# Add other default script variables here

# --- Functions ---

# Function: log
# Description: Prints a message to STDOUT or STDERR.
# Usage: log "INFO" "This is an informational message."
#        log "ERROR" "This is an error message."
#        log "DEBUG" "This is a debug message." (Only if VERBOSE is true)
log() {
  local type="$1"
  local message="$2"
  local timestamp
  timestamp=$(date +"%Y-%m-%d %H:%M:%S")

  case "$type" in
  INFO)
    gum style --foreground 212 "[$timestamp INFO] $message"
    ;;
  SUCCESS)
    gum style --foreground 40 "[$timestamp SUCCESS] $message"
    ;;
  WARN)
    gum style --foreground 208 "[$timestamp WARN] $message"
    ;;
  ERROR)
    gum style --bold --foreground 196 "[$timestamp ERROR] $message" >&2
    ;;
  DEBUG)
    if [ "$VERBOSE" = true ]; then
      gum style --faint "[$timestamp DEBUG] $message"
    fi
    ;;
  *)
    echo "[$timestamp] $message"
    ;;
  esac
}

# Function: usage
# Description: Displays help information for the script.
# Usage: usage
usage() {
  gum style --padding "1 2" --border thick --border-foreground 212 \
    "Usage: $SCRIPT_NAME [OPTIONS] [ARGUMENTS...]" \
    "" \
    "Description:" \
    "  This is a template script demonstrating various functionalities." \
    "" \
    "Options:" \
    "  -h, --help         Show this help message and exit." \
    "  -v, --verbose      Enable verbose/debug output." \
    "  -f, --file <path>  Specify an input file." \
    "  -o, --output <dir> Specify an output directory (default: current)." \
    "" \
    "Arguments:" \
    "  arg1 arg2 ...    Positional arguments for the script." \
    "" \
    "Examples:" \
    "  $SCRIPT_NAME -v -f data.txt -o ./results item1 item2" \
    "  $SCRIPT_NAME --help"
  exit 0
}

# Function: check_dependencies
# Description: Checks if required command-line tools are installed.
# Usage: check_dependencies tool1 tool2 ...
check_dependencies() {
  local missing_deps=0
  for dep in "$@"; do
    if ! command -v "$dep" &>/dev/null; then
      log "ERROR" "Required dependency '$dep' is not installed. Please install it."
      missing_deps=$((missing_deps + 1))
    fi
  done
  if [ "$missing_deps" -gt 0 ]; then
    exit 1
  fi
  log "DEBUG" "All dependencies ($*) are present."
}

# Function: process_arguments
# Description: Parses command-line arguments.
# Usage: process_arguments "$@"
# Note: This function modifies global variables (VERBOSE, INPUT_FILE, OUTPUT_DIR)
#       and shifts arguments so that remaining ones are positional.
process_arguments() {
  # Use getopt for robust argument parsing (if available and preferred)
  # For simplicity, this example uses a while loop and case.
  local args_backup=("$@") # Backup arguments for positional ones later

  while [[ $# -gt 0 ]]; do
    case "$1" in
    -h | --help)
      usage
      ;;
    -v | --verbose)
      VERBOSE=true
      log "DEBUG" "Verbose mode enabled."
      shift
      ;;
    -f | --file)
      if [[ -n "${2-}" && ! "$2" =~ ^- ]]; then
        INPUT_FILE="$2"
        log "DEBUG" "Input file set to: $INPUT_FILE"
        shift 2
      else
        log "ERROR" "Option --file requires an argument."
        usage
      fi
      ;;
    -o | --output)
      if [[ -n "${2-}" && ! "$2" =~ ^- ]]; then
        OUTPUT_DIR="$2"
        log "DEBUG" "Output directory set to: $OUTPUT_DIR"
        shift 2
      else
        log "ERROR" "Option --output requires an argument."
        usage
      fi
      ;;
    --) # End of options
      shift
      break
      ;;
    -*)
      log "ERROR" "Unknown option: $1"
      usage
      ;;
    *) # No more options, start of positional arguments
      break
      ;;
    esac
  done

  # Remaining arguments are positional
  # For this template, we'll just store them in an array
  POSITIONAL_ARGS=("$@")
  log "DEBUG" "Positional arguments: ${POSITIONAL_ARGS[*]}"
}

# --- Main Logic ---
main() {
  # 0. Check Dependencies
  log "INFO" "Checking dependencies..."
  check_dependencies "gh" "jq" "gum" "curl" "date" "grep" "sed" "awk" "mkdir"
  log "SUCCESS" "Dependencies check passed."

  # 1. Process Command-Line Arguments
  process_arguments "$@" # Pass all script arguments to the function
  # Note: After this, positional arguments are in ${POSITIONAL_ARGS[@]}

  # 2. Example: GitHub CLI (gh) and jq usage
  log "INFO" "Fetching latest release for charmbracelet/gum using GitHub CLI..."
  if ! gh auth status &>/dev/null; then
    log "WARN" "GitHub CLI not authenticated. Attempting anonymous access."
    # Or prompt for login:
    # gum confirm "GitHub CLI not authenticated. Log in now?" && gh auth login
  fi

  LATEST_GUM_RELEASE_JSON=$(gh api repos/charmbracelet/gum/releases/latest 2>/dev/null || echo "{}")
  if [[ -z "$LATEST_GUM_RELEASE_JSON" || "$LATEST_GUM_RELEASE_JSON" == "{}" ]]; then
    log "ERROR" "Failed to fetch latest release info for charmbracelet/gum."
  else
    LATEST_GUM_TAG=$(echo "$LATEST_GUM_RELEASE_JSON" | jq -r '.tag_name // "N/A"')
    LATEST_GUM_URL=$(echo "$LATEST_GUM_RELEASE_JSON" | jq -r '.html_url // "N/A"')
    log "INFO" "Latest gum release tag: $LATEST_GUM_TAG (URL: $LATEST_GUM_URL)"
  fi

  # 3. Example: gum for user input
  log "INFO" "Demonstrating gum for user interaction."
  FAVORITE_COLOR=$(gum input --placeholder "What's your favorite color?")
  if [[ -n "$FAVORITE_COLOR" ]]; then
    log "INFO" "Your favorite color is: $(gum style --bold --foreground "$FAVORITE_COLOR" "$FAVORITE_COLOR")"
  else
    log "WARN" "No favorite color entered."
  fi

  # Example: gum choose
  CHOICE=$(gum choose "Option A" "Option B" "Option C" --header "Select an option:")
  if [[ -n "$CHOICE" ]]; then
    log "INFO" "You chose: $CHOICE"
  else
    log "WARN" "No choice made."
  fi

  # Example: gum confirm
  if gum confirm "Do you want to proceed with a dummy long task?"; then
    log "INFO" "Starting dummy long task..."
    # Example: gum spin for a long-running command
    gum spin --spinner dot --title "Processing..." -- sleep 3
    log "SUCCESS" "Dummy long task completed."
  else
    log "INFO" "Skipping dummy long task."
  fi

  # 4. Example: Common Linux utilities
  log "INFO" "Demonstrating common Linux utilities."

  # Date usage
  CURRENT_DATETIME=$(date +"%Y-%m-%d %T %Z")
  log "INFO" "Current date and time: $CURRENT_DATETIME"

  # File operations (using OUTPUT_DIR specified by -o)
  if [ ! -d "$OUTPUT_DIR" ]; then
    log "INFO" "Creating output directory: $OUTPUT_DIR"
    mkdir -p "$OUTPUT_DIR"
  fi
  EXAMPLE_OUTPUT_FILE="$OUTPUT_DIR/example_output_$(date +"%Y%m%d_%H%M%S").txt"
  echo "This is an example output file generated by $SCRIPT_NAME at $CURRENT_DATETIME" >"$EXAMPLE_OUTPUT_FILE"
  log "SUCCESS" "Created example output file: $EXAMPLE_OUTPUT_FILE"

  # curl and grep/sed/awk (example: fetch public IP)
  log "INFO" "Fetching public IP address..."
  PUBLIC_IP=$(curl -s https://ifconfig.me || echo "N/A")
  log "INFO" "Your public IP address appears to be: $PUBLIC_IP"

  # Process input file if provided
  if [[ -n "$INPUT_FILE" ]]; then
    if [[ -f "$INPUT_FILE" ]]; then
      log "INFO" "Processing input file: $INPUT_FILE"
      log "INFO" "First 3 lines of $INPUT_FILE (if it has them):"
      head -n 3 "$INPUT_FILE" | gum table
      # Example: Count lines containing 'error' (case-insensitive)
      ERROR_LINES=$(grep -ic "error" "$INPUT_FILE" || true) # || true to prevent exit on no match
      log "INFO" "Number of lines containing 'error' (case-insensitive) in $INPUT_FILE: $ERROR_LINES"
    else
      log "ERROR" "Input file not found: $INPUT_FILE"
    fi
  fi

  # Process positional arguments
  if [ ${#POSITIONAL_ARGS[@]} -gt 0 ]; then
    log "INFO" "Processing positional arguments:"
    for arg in "${POSITIONAL_ARGS[@]}"; do
      log "INFO" "  - Argument: $arg"
      # Add processing logic for each argument here
    done
  else
    log "INFO" "No positional arguments provided."
  fi

  # 5. Final summary or actions
  log "SUCCESS" "Script execution completed successfully."
  gum style --border double --align center --width 50 --margin "1 2" --padding "2 4" \
    "All Done!" \
    "Have a great day!"
}

# --- Script Entry Point ---
# Call the main function with all script arguments
main "$@"
