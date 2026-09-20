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
# Download your workspace files from B2 into Render's temporary memory
rclone sync b2_storage:${B2_BUCKET_NAME} /workspace --verbose

(
  while true; do
    sleep 180
    echo "Auto-saving workspace back to Backblaze..."
    rclone sync /workspace b2_storage:${B2_BUCKET_NAME} --exclude ".git/**"
  done
) &


echo "Starting OpenCode Web..."


export OPENCODE_SERVER_PASSWORD=${SECRET_PASSWORD}


export HOST=0.0.0.0
export OPENCODE_HOST=0.0.0.0


export PORT=10000
export OPENCODE_PORT=10000


opencode serve
