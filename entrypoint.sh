#!/bin/bash

# 1. configure Rclone for Backblaze B2
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

# 2. Background loop: Every 3 minutes, backup changes back to B2 automatically
(
  while true; do
    sleep 180
    echo "Auto-saving workspace back to Backblaze..."
    rclone sync /workspace b2_storage:${B2_BUCKET_NAME} --exclude ".git/**"
  done
) &

# 3. Create the Network Proxy Tunnel
# This intercepts Render's public requests on port 10000 and tunnels them directly into OpenCode on 127.0.0.1:4096
echo "Starting network proxy tunnel (10000 -> 4096)..."
socat TCP-LISTEN:10000,fork TCP:127.0.0.1:4096 &

# 4. Boot up the OpenCode Web interface server
echo "Starting OpenCode Web..."
export OPENCODE_SERVER_PASSWORD=${SECRET_PASSWORD}
opencode serve
