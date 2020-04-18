#!/bin/sh

set -e

NOCOLOR='\033[0m'
SASSCOLOR='\033[1;34m'
ERRORCOLOR='\033[1;31m'
SUCCESSCOLOR='\033[1;32m'

echo "${SASSCOLOR}== Compiling SASS ================= ${SASSOUTPUT} ${NOCOLOR}"
sass static/css/main.scss > static/css/main.css
if [ $? -eq 0 ]; then
    echo "${SUCCESSCOLOR}======== OK ================ ${NOCOLOR}"
else
    echo "${ERRORCOLOR}======== Fail ================ ${NOCOLOR}"
fi