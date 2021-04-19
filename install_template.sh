#!/bin/bash

# Script to setup the template files
# This script must be run once before generating the .html files
if [[ ! (-d how_template) ]]
then
    tmp=$(mktemp -d) &&
    git clone --depth 1 https://github.com/ocsigen/ocsigen.github.io.git $tmp &&
    mv $tmp/{template,how_template} &&
    mv $tmp/how_template .
fi
