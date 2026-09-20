FROM node:20-slim

# Install rclone, git, curl, and unzip
RUN apt-get update && apt-get install -y rclone git curl unzip && rm -rf /var/lib/apt/lists/*

# Install OpenCode and the lightweight proxy library
RUN npm install -g @opencode/cli http-proxy

WORKDIR /workspace

# Copy the server files
COPY entrypoint.sh /entrypoint.sh
COPY proxy.js /proxy.js
RUN chmod +x /entrypoint.sh

EXPOSE 10000

ENTRYPOINT ["/entrypoint.sh"]
