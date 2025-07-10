SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPT_DIR}/shared_functions.sh"

sudo apt update && sudo apt install -y apt-transport-https wget gpg


install_vscode
install_sql_beekeeper
install_mongodb_compass
install_httpie
install_ardm
install_kitty
