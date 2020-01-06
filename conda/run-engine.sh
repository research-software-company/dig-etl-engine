#!/bin/bash

# This script resides in <conda-env>/bin. We need to run engine.sh from <conda-env>

cd "$(dirname "$0")"/..
./engine.sh "$@"
