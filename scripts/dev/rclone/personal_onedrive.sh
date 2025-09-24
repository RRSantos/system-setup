#!/bin/bash
mkdir -p ~/onedrive_local

sudo cp systemd/rclone_personal_onedrive.service /etc/systemd/system/

sudo systemctl daemon-reload

sudo systemctl enable rclone_personal_onedrive.service

sudo systemctl start rclone_personal_onedrive.service