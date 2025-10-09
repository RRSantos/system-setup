SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/shared_functions.sh"

sudo apt update && sudo apt install flatpak -y


install_onlyoffice
install_flameshot
install_evince
install_qownnotes
install_onedrive_personal