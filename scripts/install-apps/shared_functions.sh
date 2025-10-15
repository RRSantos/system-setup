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

is_appimage_installed() {
  local app_name="$1"

  # Verifica arquivos .AppImage em diretórios comuns
  if find ~ ~/.local/bin ~/Downloads -path "$HOME/onedrive_local/*" -prune -o -type f -iname "${app_name}.AppImage" 2>/dev/null | grep -q .; then
    return 0  # true
  fi

  # Verifica atalhos .desktop contendo o nome
  if grep -i "${app_name}" ~/.local/share/applications/*.desktop 2>/dev/null | grep -q .; then
    return 0  # true
  fi

  # Verifica no PATH
  if command -v "$app_name" >/dev/null 2>&1; then
    return 0  # true
  fi

  return 1  # false
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

install_k3d(){
  if ! command_exists k3d; then
    K3D_VERSION=v5.8.3
    curl -L https://github.com/k3d-io/k3d/releases/download/${K3D_VERSION}/k3d-linux-amd64 -o k3d
    #curl -L https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | TAG=v5.0.0 bash
    #curl -Lo ./kind https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-amd64
    sudo install -o root -g root -m 0755 k3d /usr/local/bin/k3d
    rm "k3d"
  else
    echo "  >> k3d already installed <<"
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
  if [[ -f ~/.config/autostart/ferdium.desktop ]]; then
    rm ~/.config/autostart/ferdium.desktop
  fi
  if [[ -f ~/.local/share/applications/ferdium.desktop ]]; then
    rm ~/.local/share/applications/ferdium.desktop
  fi
  stow -d ~/system-setup/dotfiles -t ~/ ferdium
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
  FONT_DIR=$HOME/.local/share/fonts
  NF_VERSION=v3.4.0
  BASE_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/${NF_VERSION}"
  FONTS=(
      "FiraCode.zip"
      "Inconsolata.zip"
      "Meslo.zip"
      "Mononoki.zip"
  )

  if [ ! -d "$FONT_DIR" ]; then
      mkdir -p "$FONT_DIR"
  fi

  for font_file in "${FONTS[@]}"; do
    curl -L "$BASE_URL/$font_file" -o $font_file
    unzip -o $font_file "*.ttf" -d $FONT_DIR
    rm "$font_file"
  done
  fc-cache -fv

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

install_flameshot(){
  if ! command_exists flameshot; then
    sudo apt update && sudo apt install flameshot -y

  else
    echo "  >> flameshot is already installed <<"
  fi
}

install_onlyoffice(){
  if ! is_flatpak_installed org.onlyoffice.desktopeditors; then
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak install flathub org.onlyoffice.desktopeditors -y
  else
    echo "  >> onlyoffice is already installed <<"
  fi
}

install_evince(){
  if ! command_exists evince; then
    sudo apt install evince -y

  else
    echo "  >> evince is already installed <<"
  fi
}

install_bruno(){
  if ! command_exists bruno; then
    sudo mkdir -p /etc/apt/keyrings
    sudo apt update && sudo apt install gpg curl -y
    curl -fsSL "https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x9FA6017ECABE0266" | gpg --dearmor | sudo tee /etc/apt/keyrings/bruno.gpg > /dev/null
    echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/bruno.gpg] http://debian.usebruno.com/ bruno stable" | sudo tee /etc/apt/sources.list.d/bruno.list
    sudo apt update && sudo apt install bruno -y
  else
    echo "  >> bruno is already installed <<"
  fi
}

install_bitwarden(){
  if ! is_flatpak_installed com.bitwarden.desktop; then
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak install flathub com.bitwarden.desktop -y
  else
    echo "  >> bitwarden is already installed <<"
  fi
}

install_remmina(){
  if ! is_flatpak_installed org.remmina.Remmina; then
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak install flathub org.remmina.Remmina -y
  else
    echo "  >> remmina is already installed <<"
  fi
}

install_joplin(){
  if ! is_appimage_installed joplin; then
    sudo add-apt-repository -y universe
    sudo apt install libfuse2t64 -y
    wget -O - https://raw.githubusercontent.com/laurent22/joplin/dev/Joplin_install_and_update.sh | bash
  else
    echo "  >> joplin is already installed <<"
  fi
}

install_qownnotes(){
  if ! is_flatpak_installed org.qownnotes.QOwnNotes; then
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak install flathub org.qownnotes.QOwnNotes -y
  else
    echo "  >> QOwnNotes is already installed <<"
  fi
}

install_draw_io(){
  if ! command_exists drawio; then
  curl -L https://github.com/jgraph/drawio-desktop/releases/download/v28.0.6/drawio-amd64-28.0.6.deb -o drawio-amd64.deb
  sudo dpkg -i drawio-amd64.deb
  rm drawio-amd64.deb
  else
    echo "  >> drawio is already installed <<"
  fi
}

install_rclone(){
  if ! command_exists rclone; then
    sudo -v ; curl https://rclone.org/install.sh | sudo bash
  else
    echo "  >> rclone is already installed <<"
  fi
}

install_onedrive_personal(){
  if ! command_exists onedrive; then
    sudo apt update && sudo apt install onedrive libfuse2t64 -y
  else
    echo "  >> onedrive is already installed <<"
  fi

  if ! is_appimage_installed OneDriveGUI; then
    ONEDRIVE_CLI_APP_IMAGE_URL="https://github.com/bpozdena/OneDriveGUI/releases/download/v1.2.2/OneDriveGUI-1.2.2-x86_64.AppImage"
    INSTALL_DIR="${HOME}/.onedrivegui"
    mkdir -p $INSTALL_DIR
    curl -L $ONEDRIVE_CLI_APP_IMAGE_URL -o OneDriveGUI.AppImage
    chmod a+x OneDriveGUI.AppImage
    mv ./OneDriveGUI.AppImage ${INSTALL_DIR}/
  else
    echo "  >> onedrive-gui is already installed <<"
  fi

  if [[ -f ~/.config/autostart/ondrive_gui.desktop ]]; then
    rm ~/.config/autostart/ondrive_gui.desktop
  fi

  stow -d ~/system-setup/dotfiles -t ~/ ondrive_gui
}

install_obsidian(){
  if ! command_exists obsidian; then
    OBSIDIAN_VERSION=1.9.14

    curl -L "https://github.com/obsidianmd/obsidian-releases/releases/download/v${OBSIDIAN_VERSION}/obsidian_${OBSIDIAN_VERSION}_amd64.deb" -o obsidian.deb
    sudo dpkg -i obsidian.deb
    rm "obsidian.deb"
  else
    echo "  >> obsidian is already installed <<"
  fi
}

