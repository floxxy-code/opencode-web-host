#!/bin/bash

mkdir -p ~/.config/rclone
cat <<EOF > ~/.config/rclone/rclone.conf
[b2_storage]
type = s3
provider = Other
access_key_id = ${B2_ACCESS_KEY_ID}
secret_access_key = ${B2_SECRET_ACCESS_KEY}
endpoint = ${B2_ENDPOINT}
EOF

echo "Pulling latest project files from Backblaze B2..."
rclone sync b2_storage:${B2_BUCKET_NAME} /workspace --verbose

(
  while true; do
    sleep 180
    echo "Auto-saving workspace back to Backblaze..."
    rclone sync /workspace b2_storage:${B2_BUCKET_NAME} --exclude ".git/**"
  done
) &

echo "Starting smart proxy layer..."
node /proxy.js &

echo "Starting OpenCode Web..."
export OPENCODE_SERVER_PASSWORD=${SECRET_PASSWORD}
export XDG_DATA_HOME=/workspace/.opencode-data
export XDG_CONFIG_HOME=/workspace/.opencode-data

cd /workspace
opencode serve
