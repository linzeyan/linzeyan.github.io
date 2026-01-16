#!/bin/sh

set -e
cd docs
gitbook build .
sed -i 's/confirm: true/confirm: false/' /www/docs/_book/gitbook/gitbook-plugin-fontsettings/fontsettings.js
gitbook serve
