#!/bin/bash

# This script resides in <conda-env>/bin. We need to run engine.sh from <conda-env>

cd "$(dirname "$0")"/..

# Initialize permissions, as explained in the installation document
chmod 666 logstash/sandbox/settings/logstash.yml || true
mkdir -p mydig_projects/.es/data || true
chown -R 1000:1000 mydig_projects/.es || true

./engine.sh "$@"
