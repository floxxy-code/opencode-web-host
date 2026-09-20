FROM node:20-slim

# Install rclone, git, and socat
RUN apt-get update && apt-get install -y rclone git curl unzip socat && rm -rf /var/lib/apt/lists/*

# Intall OpenCode
RUN npm install -g @opencode/cli

WORKDIR /workspace

# Copy the startup script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 10000

ENTRYPOINT ["/entrypoint.sh"]
