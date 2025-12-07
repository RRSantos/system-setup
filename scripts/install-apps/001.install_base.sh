#!/bin/bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/shared_functions.sh"

# base apps
sudo apt update && sudo apt install curl flatpak fzf git stow tree zsh htop -y