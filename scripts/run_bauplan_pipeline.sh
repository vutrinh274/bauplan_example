#!/bin/bash

PROJECT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && cd .. && pwd)/pipeline"

bauplan run --namespace adventure --project-dir "$PROJECT_PATH"