#!/bin/bash
#
# Command-line script to execute ripping using the Docker container.
#

set -e

if [ "$#" -ne 3 ]; then
    echo "Requires three arguments: name of the Docker image, base path, and acquisition sub-directory"
    exit 1
fi

BASE_PATH="${2}"
ACQUISITION_SUBDIR="${3}"

if [ ! -d "${BASE_PATH}" ]; then
    echo "Base directory missing: ${BASE_PATH}"
    exit 2
fi

# Pass both base path and acquisition subdirectory separately
docker run \
       -it \
       --rm \
       --volume=${BASE_PATH}:/data \
       --env=BASE_PATH="/data" \
       --env=ACQUISITION_DIR="${ACQUISITION_SUBDIR}" \
       --env=USER_NAME=${USER} \
       --env=USER_UID=$(id -u ${USER}) \
       --env=USER_GID=$(id -g ${USER}) \
       --env=USER_HOME=${HOME} \
       --workdir=/home/${USER} \
       --env=USE_XVFB=yes \
       --env=XVFB_SERVER=:95 \
       --env=XVFB_SCREEN=0 \
       --env=XVFB_RESOLUTION=320x240x8 \
       --env=DISPLAY=:95 \
       --hostname=bruker-ripper \
       --name=bruker-ripper \
       --shm-size=1g \
       --env=TZ=America/Los_Angeles \
       ${1}
