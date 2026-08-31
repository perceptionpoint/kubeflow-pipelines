#!/bin/bash

set -ex

# Transitive deps (e.g. node-releases) have started declaring `engines: node >=18`,
# which yarn treats as fatal while this image is still on node 14. License text
# generation doesn't execute any of that code, so the check is safe to skip.
YARN="npx yarn --ignore-engines"

# 1. Install yarn
npm install -D yarn@1.22.19

# 2. Set up yarn: It will convert from package.json to yarn.lock
$YARN import

# 3. Generate full license texts in one file
$YARN licenses generate-disclaimer > dependency-licenses.txt

# 4. Generate full license texts for Frontend server
pushd server
$YARN import
$YARN install
$YARN licenses generate-disclaimer > dependency-licenses.txt
popd

# 5. Merge two licenses to one file in server/dependency-licenses.txt
cat dependency-licenses.txt >> server/dependency-licenses.txt

# Reference for usage of yarn:
# List all packages with their license
# $ npx yarn licenses list | less

# Summarize licenses
# $ npx yarn licenses list | grep License | sort -u | cut -d: -f2
