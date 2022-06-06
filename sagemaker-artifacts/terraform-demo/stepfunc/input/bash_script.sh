#!/bin/bash

cd /opt/ml/processing/input/code/

set -e

if [[ -f 'requirements.txt' ]]; then
    # Some py3 containers has typing, which may breaks pip install
    pip uninstall --yes typing
    pip install -r requirements.txt
fi

python preprocessing.py "$@"

# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved. SPDX-License-Identifier: MIT-0
