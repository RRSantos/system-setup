SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
echo "script dir: $SCRIPT_DIR"
source "${SCRIPT_DIR}/shared_functions.sh"

sudo apt update && sudo apt install -y apt-transport-https wget gpg


install_vscode
install_codium
install_sql_beekeeper
install_mongodb_compass
install_httpie
install_bruno
install_ardm
install_kitty
install_remmina
install_draw_io