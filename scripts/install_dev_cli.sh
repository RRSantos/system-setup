SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
echo "script dir: $SCRIPT_DIR"
source "${SCRIPT_DIR}/shared_functions.sh"

sudo apt update && sudo apt install -y git neovim curl software-properties-common \
	unzip apt-transport-https ca-certificates gnupg gnupg-agent

install_kind
install_kubectl
install_kubectx
install_kubens
install_helm
install_docker
config_docker_groups
install_az_cli
install_gcloud
install_aws_cli
install_k6
install_terraform



