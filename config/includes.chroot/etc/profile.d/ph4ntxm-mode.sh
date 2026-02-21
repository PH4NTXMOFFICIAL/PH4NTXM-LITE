#!/bin/sh

MODE_FILE=/run/ph4ntxm/mode

if [ -f "$MODE_FILE" ]; then
    PH4NTXM_MODE="$(cat "$MODE_FILE")"
else
    PH4NTXM_MODE=linux
fi

export PH4NTXM_MODE