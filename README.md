# opencode-web-host

A Dockerized environment that hosts **OpenCode Web** with automatic storage synchronization to Backblaze B2 (S3-compatible storage) and an integrated HTTP proxy layer. 

The container exposes a proxy on port `10000` that routes traffic internally to OpenCode (`4096`), handles health checks, and manages a background backup loop to keep your workspace persistent.

## Architecture & Mechanics

* **Storage Sync (`rclone`):** On startup, the container syncs your workspace data down from Backblaze B2. A background process triggers every 3 minutes (180 seconds) to sync your local variations back to B2, excluding `.git` directories.
* **Proxy Layer (`proxy.js`):** A native Node.js HTTP server listening on `0.0.0.0:10000`. It catches traffic, exposes a `/ping` health check endpoint, and transparently pipes all other requests to OpenCode running locally on port `4096`.
* **Workspace Lifecycle (`entrypoint.sh`):** Configures your storage credentials on the fly, triggers the initial data pull, spins up the auto-save loop, and launches both the proxy server and the `@opencode/cli` server.

## Repository Layout

* `Dockerfile` — Sets up the environment using `node:20-slim`, installs system utilities (`rclone`, `git`, `curl`), globalizes the `@opencode/cli`, and exposes port 10000.
* `entrypoint.sh` — The orchestration bash script that sets up runtime file states, background syncing, and processes.
* `proxy.js` — The lightweight proxy script handling the `10000` -> `4096` stream mapping and uptime endpoint.

## Getting Started

### Environment Variables
The container relies on the following environment configurations to hook up storage and secure the application:

| Variable | Description |
| :--- | :--- |
| `B2_ACCESS_KEY_ID` | Your Backblaze B2 Application Key ID. |
| `B2_SECRET_ACCESS_KEY` | Your Backblaze B2 Application Key value. |
| `B2_ENDPOINT` | The S3 endpoint URL provided by your B2 bucket. |
| `B2_BUCKET_NAME` | The target B2 bucket where workspace files live. |
| `SECRET_PASSWORD` | Sets the access password for the `opencode serve` command line. |

### Building and Running the Container

1. **Build the image locally:**
   ```bash
   docker build -t opencode-web-host .
   ```

2. **Run the container with your keys:**
   ```bash
   docker run -d \
     -p 10000:10000 \
     -e B2_ACCESS_KEY_ID="your_key_id" \
     -e B2_SECRET_ACCESS_KEY="your_secret_key" \
     -e B2_ENDPOINT="://backblazeb2.com" \
     -e B2_BUCKET_NAME="your-workspace-bucket" \
     -e SECRET_PASSWORD="your-secure-password" \
     --name opencode-host \
     opencode-web-host
   ```

## API / Health Verification

Once the container is online, you can verify the status of the proxy layer externally by curling the heartbeat path:

```bash
curl http://localhost:10000/ping
```

**Expected Response:**
```json
{ "status": "ok", "message": "Pong! OpenCode is awake." }
```
If the backend application is still setting up or pulling large files from B2 via the sync phase, requests to other paths will safely drop back a `502 Bad Gateway` status page until the service bounds to port `4096`.
