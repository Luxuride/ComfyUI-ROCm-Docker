#!/bin/bash
/opt/init_defaults.sh
exec python3.12 -u main.py "$@"
