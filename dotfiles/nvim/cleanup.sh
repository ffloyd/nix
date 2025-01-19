#!/usr/bin/env bash

# This script cleans up the directories created by neovim.
# It's useful when you want to check how you confuguration behaves when it's
# initialized for the first time.
#
# `:h standard-path` helped me write this script

config_dir="${XDG_CONFIG_HOME:=${HOME}/.config}/nvim"
data_dir="${XDG_DATA_HOME:=${HOME}/.local/share}/nvim"
state_dir="${XDG_STATE_HOME:=${HOME}/.local/state}/nvim"
cache_dir="${XDG_CACHE_HOME:=${HOME}/.cache}/nvim"

echo "Config dir: ${config_dir}"
echo ""
echo "Directories to be removed:"
echo "  Data dir:   ${data_dir}"
echo "  State dir:  ${state_dir}"
echo "  Cache dir:  ${cache_dir}"

rm -rf $data_dir
rm -rf $state_dir
rm -rf $cache_dir
