#!/bin/bash

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <bucket name> <bauplan branch>"
    exit 1
fi


./scripts/clean_up_s3.sh "$1"
./scripts/clean_up_bauplan.sh "$2"