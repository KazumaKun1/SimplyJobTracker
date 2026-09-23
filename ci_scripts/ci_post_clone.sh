#!/bin/sh
set -e

echo "REVENUECAT_API_KEY = ${REVENUECAT_API_KEY}" > "${CI_PRIMARY_REPOSITORY_PATH}/SimplyJobTracker/Common/Resources/Config.xcconfig"
