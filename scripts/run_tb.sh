#!/bin/bash

#Base paths
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
PROJ_ROOT="$(realpath "$SCRIPT_DIR/..")"

#User inputs
TESTBENCH="$(realpath "$1")"
SIM_NAME=$2
OUTPUT_DIR="$(realpath "$3")"

# Check for correct usage
if [ "$#" -lt 3 ]; then
  echo "Usage: $0 <testbench.v> <sim_name> <output_dir>"
  exit 1
fi

#Set variables
VVP_FILE="${OUTPUT_DIR}/${SIM_NAME}.vvp"
VCD_FILE="${OUTPUT_DIR}/${SIM_NAME}.vcd"

#Other file paths for readability
INCLUDES="${PROJ_ROOT}/includes/*.vh"
RTL="${PROJ_ROOT}/rtl/*v"
TB_UTILS="${PROJ_ROOT}/tb_utils/*v"

# List all files to compile
IVERILOG_FILES="$TESTBENCH $INCLUDES $RTL $TB_UTILS"

echo "[+] Compiling..."
iverilog -g2012 -D DUMP_PATH="\"${VCD_FILE}\"" \
                -I "${PROJ_ROOT}/includes" \
                -o "$VVP_FILE" $IVERILOG_FILES \
                || exit 1

echo "[+] Running simulation..."
vvp "$VVP_FILE" || exit 1
