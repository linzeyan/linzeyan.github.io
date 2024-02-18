#!/usr/bin/env bash

set -e
symbol='```'

export RELEASE_NOTES=$(curl -s --header "PRIVATE-TOKEN: $CI_JOB_TOKEN" "https://gitlab.newfuturetv.com/api/v4/projects/$CI_PROJECT_ID/releases/$CI_COMMIT_TAG" | jq -r '.description')

ops-cli telegram text -c ${TELEGRAM_CHATID} -t ${TELEGRAM_TOKEN} -a "${symbol}markdown $(echo "$RELEASE_NOTES") ${symbol}"
