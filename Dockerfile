FROM node:20-slim


RUN apt-get update && apt-get install -y rclone git curl unzip && rm -rf /var/lib/apt/lists/*


RUN npm install -g @opencode/cli

WORKDIR /workspace


COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 5173

ENTRYPOINT ["/entrypoint.sh"]
