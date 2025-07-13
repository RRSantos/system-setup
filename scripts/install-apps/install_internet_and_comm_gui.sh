SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/shared_functions.sh"

sudo apt update && sudo apt install flatpak -y


install_chrome
install_thunderbird

install_ferdium