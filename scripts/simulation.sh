#! /bin/bash

echo -e $INFO ./scripts/simulation.sh

# Run hostapd with parameters
. ./hostapd/$1.sh 2>/dev/null
echo -e "$INFO Started simulation with config: $1"
