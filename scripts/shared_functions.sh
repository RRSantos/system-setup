command_exists() {
  command -v "$1" >/dev/null 2>&1
}

is_flatpak_installed() {
  # Verifica se um argumento foi fornecido
  if [ -z "$1" ]; then
    echo "Erro: ID do aplicativo Flatpak não fornecido para 'check_flatpak_installed'." >&2
    return 1
  fi

  local FLATPAK_ID="$1"

  if flatpak info "$FLATPAK_ID" &> /dev/null; then
    return 0
  else
    return 1
  fi
}

# DEV CLI

install_go(){
  if ! command_exists go; then
    GO_VERSION="1.24.4"
    curl -L "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" -o "go-linux.tar.gz"
    sudo tar -C /usr/local -xzf go-linux.tar.gz
    rm "go-linux.tar.gz"
  else
    echo "  >> go is already installed <<"
  fi
}

install_gke_gcloud_auth_plugin(){
  if ! command_exists gke-gcloud-auth-plugin; then
    sudo apt install google-cloud-cli-gke-gcloud-auth-plugin -y
  else
    echo "  >> gke-gcloud-auth-plugin is already installed <<"
  fi
}

install_terraform(){
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
}

install_terragrunt(){
  if ! command_exists terragrunt; then
    GO_VERSION="1.24.4"
    curl -L "https://github.com/gruntwork-io/terragrunt/releases/download/v0.83.0/terragrunt_linux_amd64" -o "terragrunt"
    sudo install -o root -g root -m 0755 terragrunt /usr/local/bin/terragrunt
    rm "terragrunt"
  else
    echo "  >> terragrunt is already installed <<"
  fi
}

install_kubectl(){
  if ! command_exists kubectl; then
    KUBECTL_VERSION="v1.33.1"
    curl -LO "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
  else
    echo "  >> kubectl already installed <<"
  fi
}

install_az_cli(){
  if ! command_exists az; then
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
  else
    echo "  >> az CLI already installed <<"
  fi
}

install_helm(){
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
}

install_gcloud(){

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
}

install_aws_cli(){

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
}

install_docker(){
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
}

config_docker_groups(){
  if ! getent group docker > /dev/null; then
    sudo groupadd docker
  else
    echo "  >> 'docker' group already exists <<"
  fi

  if ! id -nG "$USER" | grep -qw "docker"; then
    sudo usermod -aG docker "$USER"
    newgrp docker
  else
    echo "  >> User '$USER' is already member of 'docker' group <<"
  fi
}

install_kubens(){
  if ! command_exists kubens; then
    KUBENS_VERSION=v0.9.5
    curl -L "https://github.com/ahmetb/kubectx/releases/download/${KUBENS_VERSION}/kubens_${KUBENS_VERSION}_linux_x86_64.tar.gz" -o "kubens.tar.gz"
    tar  -xzvf "kubens.tar.gz"
    sudo install -o root -g root -m 0755 kubens /usr/local/bin/kubens
    rm ./kubens.tar.gz ./kubens
  else
    echo "  >> kubens already installed <<"
  fi
}

install_kubectx(){
  if ! command_exists kubectx; then
    KUBECTX_VERSION=v0.9.5
    curl -L "https://github.com/ahmetb/kubectx/releases/download/${KUBECTX_VERSION}/kubectx_${KUBECTX_VERSION}_linux_x86_64.tar.gz" -o "kubectx.tar.gz"
    tar  -xzvf "kubectx.tar.gz"
    sudo install -o root -g root -m 0755 kubectx /usr/local/bin/kubectx
    rm ./kubectx.tar.gz ./kubectx
  else
    echo "  >> kubectx already installed <<"
  fi
}

install_kind(){
  if ! command_exists kind; then
    KIND_VERSION=v0.29.0
    curl -Lo ./kind https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-amd64
    sudo install -o root -g root -m 0755 kind /usr/local/bin/kind
    rm "kind"
  else
    echo "  >> kind already installed <<"
  fi
}

install_k6(){
  if ! command_exists k6; then
    K6_VERSION=v1.1.0
    curl -L https://github.com/grafana/k6/releases/download/${K6_VERSION}/k6-${K6_VERSION}-linux-amd64.tar.gz -o k6.tar.gz
    tar -xzvf "k6.tar.gz"
    sudo install -o root -g root -m 0755 k6-${K6_VERSION}-linux-amd64/k6 /usr/local/bin/k6
    rm "k6.tar.gz"
    rm -rf ./k6-${K6_VERSION}-linux-amd64
  else
    echo "  >> k6 is already installed <<"
  fi
}

# DEV GUI

install_vscode(){
  if ! command_exists code; then
    echo "code code/add-microsoft-repo boolean true" | sudo debconf-set-selections

    MS_KEYRING_DIR="/etc/apt/keyrings"
    MS_KEYRING_FILE="${MS_KEYRING_DIR}/packages.microsoft.gpg"
    VSCODE_REPO_FILE="/etc/apt/sources.list.d/vscode.list"
    VSCODE_REPO_LINE="deb [arch=amd64,arm64,armhf signed-by=${MS_KEYRING_FILE}] https://packages.microsoft.com/repos/code stable main"

    sudo install -d -m 0755 "$MS_KEYRING_DIR"

    if [ ! -f "$MS_KEYRING_FILE" ] || ! sudo gpg --no-default-keyring --keyring "$MS_KEYRING_FILE" --list-keys >/dev/null 2>&1; then
      wget -qO- https://packages.microsoft.com/keys/microsoft.asc | sudo gpg --dearmor | sudo tee "$MS_KEYRING_FILE" > /dev/null
      sudo chmod a+r "$MS_KEYRING_FILE" # Garante que as permissões estejam corretas
    else
      echo "  >> Microsoft GPG key already validated <<"
    fi

    if ! sudo grep -qF "$VSCODE_REPO_LINE" "$VSCODE_REPO_FILE"; then
      echo "$VSCODE_REPO_LINE" | sudo tee "$VSCODE_REPO_FILE" > /dev/null
    else
      echo "  >> VSCode repo already configured <<"
    fi

    if [ -f "packages.microsoft.gpg" ]; then
      rm -f packages.microsoft.gpg
    fi

    sudo apt update && sudo apt install -y code
  else
    echo "  >> vscode is already installed <<"
  fi
}


install_sql_beekeeper(){
  if ! command_exists beekeeper-studio; then
    BEEKEEPER_VERSION=5.2.12
    curl -L "https://github.com/beekeeper-studio/beekeeper-studio/releases/download/v${BEEKEEPER_VERSION}/beekeeper-studio_${BEEKEEPER_VERSION}_amd64.deb" -o beekeeper-studio.deb
    sudo dpkg -i beekeeper-studio.deb
    rm "beekeeper-studio.deb"
  else
    echo "  >> beekeeper-studio is already installed <<"
  fi
}

install_mongodb_compass(){
  if ! command_exists mongodb-compass; then
    COMPASS_VERSION=1.46.5
    curl -L https://downloads.mongodb.com/compass/mongodb-compass_${COMPASS_VERSION}_amd64.deb -o mongodb-compass.deb
    sudo dpkg -i mongodb-compass.deb
    rm "mongodb-compass.deb"
  else
    echo "  >> mongodb-compass is already installed <<"
  fi
}

install_httpie(){
  if ! command_exists httpie; then
    HTTP_REPO_FILE="/etc/apt/sources.list.d/httpie.list"
    HTTP_REPO_LINE="deb [arch=amd64 signed-by=/usr/share/keyrings/httpie.gpg] https://packages.httpie.io/deb ./"
    if ! sudo grep -qF "$HTTP_REPO_LINE" "$HTTP_REPO_FILE"; then
      echo "$HTTP_REPO_LINE" | sudo tee "$HTTP_REPO_FILE" > /dev/null
    fi

    curl -SsL https://packages.httpie.io/deb/KEY.gpg | sudo gpg --dearmor -o /usr/share/keyrings/httpie.gpg
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/httpie.gpg] https://packages.httpie.io/deb ./" | sudo tee /etc/apt/sources.list.d/httpie.list > /dev/null
    sudo apt update &&  sudo apt install httpie -y

  else
    echo "  >> httpie is already installed <<"
  fi
}


install_ardm(){
  if ! command_exists another-redis-desktop-manager; then
    sudo snap install another-redis-desktop-manager

  else
    echo "  >> another-redis-desktop-manager is already installed <<"
  fi
}

# INTERNET GUI

install_chrome(){
  if ! command_exists google-chrome; then
  curl -L https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb -o google-chrome.deb
  sudo dpkg -i google-chrome.deb
  rm google-chrome.deb
  else
    echo "  >> google-chrome is already installed <<"
  fi
}


# COMM GUI
install_thunderbird(){
  if ! is_flatpak_installed org.mozilla.Thunderbird; then
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak install flathub org.mozilla.Thunderbird -y
  else
    echo "  >> thunderbird is already installed <<"
  fi
}


install_ms_teams(){
  if ! command_exists teams-for-linux; then
  sudo snap install teams-for-linux
  else
    echo "  >> teams-for-linux is already installed <<"
  fi
}

install_ferdium(){
  if ! command_exists ferdium; then
    FERDIUM_VERSION=7.1.0
    curl -L https://github.com/ferdium/ferdium-app/releases/download/v${FERDIUM_VERSION}/Ferdium-linux-${FERDIUM_VERSION}-amd64.deb -o ferdium-linux.deb
    sudo dpkg -i ferdium-linux.deb
    rm ferdium-linux.deb
  else
    echo "  >> ferdium is already installed <<"
  fi
}

## BASE

install_brave(){
  if ! command_exists brave-browser; then
    curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    curl -fsSLo /etc/apt/sources.list.d/brave-browser-release.sources https://brave-browser-apt-release.s3.brave.com/brave-browser.sources

    sudo apt update && sudo apt install brave-browser -y
  else
    echo "  >> brave-browser is already installed <<"
  fi
}

install_spotify(){
  if ! command_exists spotify-client; then
    curl -sS https://download.spotify.com/debian/pubkey_C85668DF69375001.gpg | gpg --dearmor --yes -o /etc/apt/trusted.gpg.d/spotify.gpg
    echo "deb https://repository.spotify.com stable non-free" | tee /etc/apt/sources.list.d/spotify.list

    sudo apt-get update && sudo apt-get install spotify-client -y

  else
    echo "  >> spotify-client is already installed <<"
  fi
}

install_mmex(){
  if ! is_flatpak_installed flathub org.moneymanagerex.MMEX; then
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak install flathub org.moneymanagerex.MMEX -y
  else
    echo "  >> thunderbird is already installed <<"
  fi
}

configure_zsh(){
  DESIRED_SHELL=$(which zsh)

  if [ "$SHELL" != "$DESIRED_SHELL" ]; then
      chsh -s "$DESIRED_SHELL"
  else
      echo "  >> zsh is already configured <<"
  fi

  if [ ! -d "$HOME/.oh-my-zsh" ]; then
      sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  else
      echo "  >> oh-my-zsh is already installed <<"
  fi
}

configure_dotfiles(){
  #git clone https://github.com/RRSantos/system-setup.git ~/system-setup

  if [[ -f ~/.zshrc ]]; then
  rm ~/.zshrc
  fi
  stow -d ~/system-setup/dotfiles -t ~/ zsh

  if [[ -f ~/.p10k.zsh ]]; then
    rm ~/.p10k.zsh
  fi
  stow -d ~/system-setup/dotfiles -t ~/ p10k

  if [[ -f ~/.gitconfig ]]; then
    rm ~/.gitconfig
  fi
  stow -d ~/system-setup/dotfiles -t ~/ gitconfig

  if [[ -d ~/.config/kitty ]]; then
    rm -rf ~/.config/kitty
  fi
  stow -d ~/system-setup/dotfiles -t ~/ kitty
}


install_powerlevel10k(){
  POWERLEVEL10K_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"
  if [ ! -d "$POWERLEVEL10K_DIR" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$POWERLEVEL10K_DIR"
  else
      echo "  >> Powerlevel10k is already installed <<"
  fi
}


install_fonts(){
  FONT_DIR="$HOME/.local/share/fonts"
  FONTS=(
      "MesloLGS%20NF%20Regular.ttf"
      "MesloLGS%20NF%20Bold.ttf"
      "MesloLGS%20NF%20Italic.ttf"
      "MesloLGS%20NF%20Bold%20Italic.ttf"
  )
  BASE_URL="https://github.com/romkatv/powerlevel10k-media/raw/master"

  if [ ! -d "$FONT_DIR" ]; then
      mkdir -p "$FONT_DIR"
  fi

  DOWNLOAD_NEEDED=false
  for font_file in "${FONTS[@]}"; do
      font_file_decoded=$(echo "$font_file" | sed 's/%20/ /g')
      FONT_PATH="$FONT_DIR/$font_file_decoded"
      if [ ! -f "$FONT_PATH" ]; then
          wget -P "$FONT_DIR" "$BASE_URL/$font_file"
          DOWNLOAD_NEEDED=true
      else
          echo "  >> '$font_file_decoded' font already installed <<"
      fi
  done

  if $DOWNLOAD_NEEDED; then
      fc-cache -fv
  fi
}

install_kitty(){
  if ! command_exists kitty; then
    curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
    cp $HOME/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/
    # If you want to open text files and images in kitty via your file manager also add the kitty-open.desktop file
    cp $HOME/.local/kitty.app/share/applications/kitty-open.desktop $HOME/.local/share/applications/
    # Update the paths to the kitty and its icon in the kitty desktop file(s)
    sed -i "s|Icon=kitty|Icon=$(readlink -f $HOME)/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" $HOME/.local/share/applications/kitty*.desktop
    sed -i "s|Exec=kitty|Exec=$(readlink -f $HOME)/.local/kitty.app/bin/kitty|g" $HOME/.local/share/applications/kitty*.desktop
    # Make xdg-terminal-exec (and hence desktop environments that support it use kitty)
    echo 'kitty.desktop' > $HOME/.config/xdg-terminals.list
  else
    echo "  >> kitty is already installed <<"
  fi
}