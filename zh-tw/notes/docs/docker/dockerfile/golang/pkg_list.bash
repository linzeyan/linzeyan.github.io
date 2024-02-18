#!/usr/bin/env bash

FILE=$(mktemp)
DESTFILE="pkg_list"

for i in $(ls ~/work); do cat ~/work/${i}/go.mod >>"${FILE}"; done

# remove module
sed -i '' '/^module/d' "${FILE}"

# remove go
sed -i '' '/^go .*$/d' "${FILE}"

# remove toolchain
sed -i '' '/^toolchain .*$/d' "${FILE}"

# remove replace
sed -i '' '/^replace .*$/d' "${FILE}"

# remove require
sed -i '' '/^require .*$/d' "${FILE}"

# remove tab
sed -i '' 's/\t//g' "${FILE}"

# remove space and string after it
sed -i '' 's/ .*$//g' "${FILE}"

# remove )
sed -i '' '/)/d' "${FILE}"

# remove empty lines
sed -i '' '/^$/d' "${FILE}"

# final
sort -n "${FILE}" | uniq >"${DESTFILE}"
