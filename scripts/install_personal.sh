#!/bin/bash

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/shared_functions.sh"


apt update && apt install curl flatpak -y

install_brave
install_spotify
install_mmex
