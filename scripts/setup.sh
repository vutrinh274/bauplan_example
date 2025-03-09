#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <bucket name> <bauplan branch>"
    exit 1
fi

./scripts/setup_s3.sh "$1"
./scripts/setup_bauplan.sh "$1" "$2"