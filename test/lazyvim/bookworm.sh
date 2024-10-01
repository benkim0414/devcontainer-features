#!/bin/bash

set -e

# Optional: Import test library
source dev-container-features-test-lib

# Definition specific tests
check "config" ls $HOME/.config

# Report result
reportResults
