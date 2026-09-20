FROM node:20-slim

# Install core rclone, git, curl, and unzip dependencies
RUN apt-get update && apt-get install -y rclone git curl unzip && rm -rf /var/lib/apt/lists/*

# Install OpenCode
RUN npm install -g @opencode/cli

WORKDIR /workspace

# Copy the server configuration files
COPY entrypoint.sh /entrypoint.sh
COPY proxy.js /proxy.js
RUN chmod +x /entrypoint.sh

EXPOSE 10000

ENTRYPOINT ["/entrypoint.sh"]
