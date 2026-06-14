#!/bin/bash
set -e

for dir in models input output custom_nodes user; do
    target="/opt/ComfyUI/${dir}"
    source="/opt/ComfyUI_defaults/${dir}"
    if [ -d "$source" ] && [ -d "$target" ]; then
        if [ -z "$(ls -A "$target" 2>/dev/null)" ]; then
            cp -a "$source"/. "$target"/
        else
            for subdir in "$source"/*/; do
                subdir_name="$(basename "$subdir")"
                if [ ! -e "$target/$subdir_name" ]; then
                    cp -a "$subdir" "$target"/
                fi
            done
        fi
    fi
done