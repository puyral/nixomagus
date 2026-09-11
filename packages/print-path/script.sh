#!/bin/bash
set -e

if [ $# -gt 0 ]; then
  echo "$PWD/$1"
else
  echo "$PWD"
fi;
