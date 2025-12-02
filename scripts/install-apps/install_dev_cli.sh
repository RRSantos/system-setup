SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
echo "script dir: $SCRIPT_DIR"
source "${SCRIPT_DIR}/shared_functions.sh"

sudo apt update && sudo apt install -y git curl software-properties-common \
	unzip apt-transport-https ca-certificates gnupg gnupg-agent

install_k3d
install_kind
install_kubectl
install_kubectx
install_kubens
install_go
install_helm
install_docker
config_docker_groups
install_az_cli
install_gcloud
install_gke_gcloud_auth_plugin
install_aws_cli
install_k6
install_terraform
install_terragrunt
install_neovim



