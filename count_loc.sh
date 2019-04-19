#!/bin/bash

printf "Lines of code (.sml files): "
find ./ -path ./src/NLFFI-Generated -prune -o -name "*.sml" -exec wc -l {} \; | sed 's/ .*$//' | paste -sd+ - | bc