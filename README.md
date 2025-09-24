# system-setup
dotfiles, scripts and configs to setup my new machines


## Configuring onedrive sync with rclone
1. Make sure rclone are already installed
    ```bash
    rclone --version
    ```
1. Configure ondrive sync with `rclone config` command.
    > ATTENTION: Use **personal_onedrive** as the name of rclone remote sync
1. Run the script to configure systemd to mount onedrive local folder at startup:
    ```bash
    ./scripts/dev/rclone/personal_onedrive.sh
    ```
1. Verify if it's running by executing:
    ```bash
    sudo systemctl status rclone_personal_onedrive.service
    ```

