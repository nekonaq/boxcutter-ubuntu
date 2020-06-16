#!/bin/bash
set -e

if [ -z "$SET_LOCALE" ]; then
  exit
fi

localectl set-locale LANG="$SET_LOCALE"
