command_exists() {
  command -v "$1" >/dev/null 2>&1
}

sudo apt update && sudo apt install -y git neovim curl software-properties-common \
	unzip apt-transport-https ca-certificates gnupg gnupg-agent



if ! command_exists terraform; then
  TERRAFORM_VERSION="1.12.2"
  TERRAFORM_ZIP="terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
  
  curl -L "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/${TERRAFORM_ZIP}" -o "$TERRAFORM_ZIP"
  unzip "$TERRAFORM_ZIP"
  sudo install -o root -g root -m 0755 terraform /usr/local/bin/terraform
  rm "$TERRAFORM_ZIP" terraform LICENSE.txt
else
  echo "  >> terraform already installed <<"
fi

if ! command_exists kubectl; then
  KUBECTL_VERSION="v1.33.1"
  curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
  sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
  rm kubectl
else
  echo "  >> kubectl already installed <<"
fi

if ! command_exists az; then
  curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
else
  echo "  >> az CLI already installed <<"
fi

if ! command_exists helm; then
  HELM_VERSION="v3.18.3"
  curl -L "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz" -o "helm-linux-amd64.tar.gz"
  tar  -xzvf "helm-linux-amd64.tar.gz"
  sudo install -o root -g root -m 0755 ./linux-amd64/helm /usr/local/bin/helm
  rm "helm-linux-amd64.tar.gz"
  rm -rf ./linux-amd64
else
  echo "  >> helm already installed <<"
fi

if ! command_exists gcloud; then
  GCLOUD_REPO_FILE="/etc/apt/sources.list.d/google-cloud-sdk.list"
  GCLOUD_KEYRING="/usr/share/keyrings/cloud.google.gpg"

  if [ ! -f "$GCLOUD_KEYRING" ]; then
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o "$GCLOUD_KEYRING"
  fi

  if ! grep -q "cloud-sdk main" "$GCLOUD_REPO_FILE"; then
    echo "deb [signed-by=$GCLOUD_KEYRING] https://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a "$GCLOUD_REPO_FILE"
  fi

  sudo apt-get update && sudo apt-get install google-cloud-cli -y
else
  echo "  >> gcloud cli already installed <<"
fi


if ! command_exists aws; then
  AWSCLI_VERSION=2.27.48
  curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64-${AWSCLI_VERSION}.zip" -o "awscliv2.zip"
  unzip -o awscliv2.zip
  sudo ./aws/install
   rm awscliv2.zip
   rm -rf ./aws
else
  echo "  >> aws cli already installed <<"
fi


if ! command_exists docker; then
  # Variáveis para caminhos de arquivo
  DOCKER_KEYRING_DIR="/etc/apt/keyrings"
  DOCKER_KEYRING_FILE="${DOCKER_KEYRING_DIR}/docker.asc"
  DOCKER_REPO_FILE="/etc/apt/sources.list.d/docker.list"
  DOCKER_REPO_LINE="deb [arch=$(dpkg --print-architecture) signed-by=${DOCKER_KEYRING_FILE}] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable"


  sudo apt-get update
  sudo apt-get install -y ca-certificates curl

  sudo install -m 0755 -d "$DOCKER_KEYRING_DIR"

  if [ ! -f "$DOCKER_KEYRING_FILE" ] || ! sudo gpg --no-default-keyring --keyring "$DOCKER_KEYRING_FILE" --list-keys >/dev/null 2>&1; then
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o "$DOCKER_KEYRING_FILE"
    sudo chmod a+r "$DOCKER_KEYRING_FILE"
  fi

  if ! sudo grep -qF "$DOCKER_REPO_LINE" "$DOCKER_REPO_FILE"; then
    echo "$DOCKER_REPO_LINE" | sudo tee "$DOCKER_REPO_FILE" > /dev/null
  fi

  sudo apt-get update && sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

else
  echo "  >> docker already installed <<"
fi

if ! getent group docker > /dev/null; then
  sudo groupadd docker
else
  echo "  >> 'docker' group already exists <<"
fi

if ! id -nG "$USER" | grep -qw "docker"; then
  sudo usermod -aG docker "$USER"
else
  echo "  >> User '$USER' is already member of 'docker' group <<"
fi


if ! command_exists kubens; then
  KUBENS_VERSION=v0.9.5
  curl -L "https://github.com/ahmetb/kubectx/releases/download/${KUBENS_VERSION}/kubens_${KUBENS_VERSION}_linux_x86_64.tar.gz" -o "kubens.tar.gz"
  tar  -xzvf "kubens.tar.gz"
  sudo install -o root -g root -m 0755 kubens /usr/local/bin/kubens
  rm ./kubens.tar.gz ./kubens
else
  echo "  >> kubens already installed <<"
fi

if ! command_exists kubectx; then
  KUBECTX_VERSION=v0.9.5
  curl -L "https://github.com/ahmetb/kubectx/releases/download/${KUBECTX_VERSION}/kubectx_${KUBECTX_VERSION}_linux_x86_64.tar.gz" -o "kubectx.tar.gz"
  tar  -xzvf "kubectx.tar.gz"
  sudo install -o root -g root -m 0755 kubectx /usr/local/bin/kubectx
  rm ./kubectx.tar.gz ./kubectx
else
  echo "  >> kubectx already installed <<"
fi


if ! command_exists kind; then
  KIND_VERSION=v0.29.0
  curl -Lo ./kind https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-amd64
  sudo install -o root -g root -m 0755 kind /usr/local/bin/kind
  rm "kind"
else
  echo "  >> kind already installed <<"
fi


if ! command_exists k6; then
  K6_VERSION=v1.1.0
  curl -L https://github.com/grafana/k6/releases/download/${K6_VERSION}/k6-${K6_VERSION}-linux-amd64.tar.gz -o k6.tar.gz
  tar -xzvf "k6.tar.gz"
  sudo install -o root -g root -m 0755 k6-${K6_VERSION}-linux-amd64/k6 /usr/local/bin/k6
  rm "k6.tar.gz"
  rm -rf ./k6-${K6_VERSION}-linux-amd64
else
  echo "  >> k6 already installed <<"
fi
