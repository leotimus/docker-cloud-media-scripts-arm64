#!/bin/bash
# Rclone variables
_rclone_version="v1.39"
rclone_release="rclone-${_rclone_version}-linux-arm"
rclone_zip="${rclone_release}.zip"
rclone_url="https://github.com/ncw/rclone/releases/download/${_rclone_version}/${rclone_zip}"
# Plexdrive variables
plexdrive_bin="plexdrive-linux-arm7"
plexdrive_url="https://github.com/dweidenfeld/plexdrive/releases/download/5.0.0/${plexdrive_bin}"
# Rclone
wget "$rclone_url"
unzip "$rclone_zip"
chmod a+x "${rclone_release}/rclone"
cp -rf "${rclone_release}/rclone" "/usr/bin/rclone"
rm -rf "$rclone_zip"
rm -rf "$rclone_release"

