#!/bin/bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/shared_functions.sh"


sudo apt update && sudo apt install curl flatpak -y

install_brave
install_spotify
install_mmex
