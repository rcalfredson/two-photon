#!/bin/bash

# The container executable. This script takes no arguments and just performs 
# minimal environment setup prior to running the main script.

set -e

# USE_XVFB means xvfb is already running. If it is unset, xvfb-run should wrap commands.
[[ -z "${USE_XVFB}" ]] && CMDPREFIX=xvfb-run

echo
echo "Copying wine environment."
echo
TEMPDIR="$(mktemp -d)"
export WINEPREFIX="${TEMPDIR}/.wine"
export WINEARCH="win32"
cp -r /home/wineuser/.wine "${WINEPREFIX}"

echo "Executing conversion process."
echo
echo $PATH

# Ensure ACQUISITION_DIR is set
if [[ -z "${ACQUISITION_DIR}" ]]; then
    echo "Error: ACQUISITION_DIR environment variable not set."
    exit 1
fi

# BASE_PATH is always /data inside the container
${CMDPREFIX} 2p --base-path /data --acquisition "${ACQUISITION_DIR}" raw2tiff
