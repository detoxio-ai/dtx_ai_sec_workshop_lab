
#!/bin/bash
# Installer for MCP Inspector (from registry)
set -e

# Variables
BASE_DIR="/home/dtx/labs/webapps/mcp/mcp_inspector"
IMAGE_NAME="ghcr.io/modelcontextprotocol/inspector:latest"
CONTAINER_NAME="mcp_inspector"

# Port variables (host ports)
CLIENT_PORT=18567
SERVER_PORT=18568

echo "🔍 Checking if directory exists: $BASE_DIR"
if [ -d "$BASE_DIR" ]; then
  echo "✅ Directory already exists: $BASE_DIR"
else
  echo "📂 Creating directory: $BASE_DIR"
  mkdir -p "$BASE_DIR"
fi

cd "$BASE_DIR"

# Pull latest image
echo "🐳 Pulling Docker image: $IMAGE_NAME"
docker pull "$IMAGE_NAME"

# Create start_service.sh
START_SCRIPT="$BASE_DIR/start_service.sh"
echo "⚙️ Creating start_service.sh"
cat > "$START_SCRIPT" <<'EOL'
#!/bin/bash
set -e
CONTAINER_NAME="mcp_inspector"
IMAGE_NAME="ghcr.io/modelcontextprotocol/inspector:latest"
CLIENT_PORT=18567
SERVER_PORT=18568

echo "🚀 Starting container: $CONTAINER_NAME (client:$CLIENT_PORT, server:$SERVER_PORT)"

# Remove old container if exists
if docker ps -a --format '{{.Names}}' | grep -Eq "^$CONTAINER_NAME$"; then
  echo "⚠️ Container $CONTAINER_NAME already exists. Removing..."
  docker stop "$CONTAINER_NAME" || true
  docker rm "$CONTAINER_NAME" || true
fi

docker run -d \
  --name "$CONTAINER_NAME" \
  -p $CLIENT_PORT:6274 \
  -p $SERVER_PORT:6277 \
  -e HOST=0.0.0.0 \
  -e ALLOWED_ORIGINS=http://127.0.0.1:$CLIENT_PORT \
  "$IMAGE_NAME"

# Wait for log output
sleep 3

# Extract the raw URL with token from logs
RAW_URL=$(docker logs "$CONTAINER_NAME" 2>&1 | grep -Eo "http://0.0.0.0:6274/\?MCP_PROXY_AUTH_TOKEN=[a-f0-9]+")

# Detect public IP dynamically
PUBLIC_IP=$(curl -s ifconfig.me || curl -s api.ipify.org)

# Replace 0.0.0.0:6274 with actual public IP and host port
ACCESS_URL=$(echo "$RAW_URL" | sed "s|0.0.0.0:6274|$PUBLIC_IP:$CLIENT_PORT|")

if [ -n "$ACCESS_URL" ]; then
  echo "✅ MCP Inspector is available at:"
  echo "   $ACCESS_URL"
else
  echo "❌ Could not extract access URL from logs."
  echo "📜 Full logs below:"
  docker logs "$CONTAINER_NAME"
fi
EOL
chmod +x "$START_SCRIPT"

# Create stop_service.sh
STOP_SCRIPT="$BASE_DIR/stop_service.sh"
echo "⚙️ Creating stop_service.sh"
cat > "$STOP_SCRIPT" <<'EOL'
#!/bin/bash
set -e
CONTAINER_NAME="mcp_inspector"

echo "🛑 Stopping container: $CONTAINER_NAME"

if docker ps -a --format '{{.Names}}' | grep -Eq "^$CONTAINER_NAME$"; then
  docker stop "$CONTAINER_NAME" || true
  docker rm "$CONTAINER_NAME" || true
  echo "✅ Container $CONTAINER_NAME stopped and removed."
else
  echo "⚠️ No container named $CONTAINER_NAME found."
fi
EOL
chmod +x "$STOP_SCRIPT"

echo "✅ Installation complete!"

# Run service immediately
echo "🚀 Starting container: $CONTAINER_NAME (client:$CLIENT_PORT, server:$SERVER_PORT)"

if docker ps -a --format '{{.Names}}' | grep -Eq "^${CONTAINER_NAME}\$"; then
  echo "⚠️ Container $CONTAINER_NAME already exists. Removing..."
  docker stop "$CONTAINER_NAME" || true
  docker rm "$CONTAINER_NAME" || true
fi

docker run -d \
  --name "$CONTAINER_NAME" \
  -p $CLIENT_PORT:6274 \
  -p $SERVER_PORT:6277 \
  -e HOST=0.0.0.0 \
  -e ALLOWED_ORIGINS=http://127.0.0.1:$CLIENT_PORT \
  "$IMAGE_NAME"

# Wait for log output
sleep 3

# Extract the raw URL with token from logs
RAW_URL=$(docker logs "$CONTAINER_NAME" 2>&1 | grep -Eo "http://0.0.0.0:6274/\?MCP_PROXY_AUTH_TOKEN=[a-f0-9]+")

# Detect public IP dynamically
PUBLIC_IP=$(curl -s ifconfig.me || curl -s api.ipify.org)

# Replace 0.0.0.0:6274 with actual public IP and host port
ACCESS_URL=$(echo "$RAW_URL" | sed "s|0.0.0.0:6274|$PUBLIC_IP:$CLIENT_PORT|")

if [ -n "$ACCESS_URL" ]; then
  echo "✅ MCP Inspector is available at:"
  echo "   $ACCESS_URL"
else
  echo "❌ Could not extract access URL from logs."
  echo "📜 Full logs below:"
  docker logs "$CONTAINER_NAME"
fi
