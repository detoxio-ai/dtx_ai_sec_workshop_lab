#!/bin/bash
# Installer for Damn Vulnerable MCP Server (DV-MCP)
set -e

# Variables
BASE_DIR="/home/dtx/labs/webapp/mcp/damn"
REPO_URL="https://github.com/harishsg993010/damn-vulnerable-MCP-server.git"
CONTAINER_NAME="dvmcp"
IMAGE_NAME="dvmcp"

echo "🔍 Checking if directory exists: $BASE_DIR"
if [ -d "$BASE_DIR" ]; then
  echo "✅ Directory already exists: $BASE_DIR"
else
  echo "📂 Creating directory: $BASE_DIR"
  mkdir -p "$BASE_DIR"
fi

cd "$BASE_DIR"

# Clone repo
if [ ! -d "$BASE_DIR/damn-vulnerable-MCP-server" ]; then
  echo "📦 Cloning repository..."
  git clone "$REPO_URL"
else
  echo "✅ Repository already exists."
fi


# Build Docker image
cd "$BASE_DIR/damn-vulnerable-MCP-server"
echo "🐳 Building Docker image: $IMAGE_NAME"
docker build -t "$IMAGE_NAME" .

# Create start_service.sh
START_SCRIPT="$BASE_DIR/start_service.sh"
echo "⚙️ Creating start_service.sh"
cat > "$START_SCRIPT" <<'EOL'
#!/bin/bash
set -e
BASE_DIR="/home/dtx/labs/webapp/mcp/damn"
source "$BASE_DIR/.env"

CONTAINER_NAME="dvmcp"
IMAGE_NAME="dvmcp"

echo "🚀 Starting container: $CONTAINER_NAME on ports 18567:18576"

# Remove old container if exists
if docker ps -a --format '{{.Names}}' | grep -Eq "^${CONTAINER_NAME}\$"; then
  echo "⚠️ Container $CONTAINER_NAME already exists. Removing..."
  docker stop "$CONTAINER_NAME" || true
  docker rm "$CONTAINER_NAME" || true
fi

docker run -d -restart unless-stopped \
  --name "$CONTAINER_NAME" \
  -p 18567-18576:"9001-9010\
  "$IMAGE_NAME"

# Verify container is running
sleep 2
if docker ps --format '{{.Names}}' | grep -Eq "^${CONTAINER_NAME}\$"; then
  echo "✅ Container $CONTAINER_NAME is running."
else
  echo "❌ Failed to start container $CONTAINER_NAME"
  exit 1
fi
EOL
chmod +x "$START_SCRIPT"

# Create stop_service.sh
STOP_SCRIPT="$BASE_DIR/stop_service.sh"
echo "⚙️ Creating stop_service.sh"
cat > "$STOP_SCRIPT" <<'EOL'
#!/bin/bash
set -e
CONTAINER_NAME="dvmcp"

if docker ps -a --format '{{.Names}}' | grep -Eq "^${CONTAINER_NAME}\$"; then
  echo "🛑 Stopping and removing container: $CONTAINER_NAME"
  docker stop "$CONTAINER_NAME" || true
  docker rm "$CONTAINER_NAME" || true
else
  echo "ℹ️ No container named $CONTAINER_NAME found."
fi
EOL
chmod +x "$STOP_SCRIPT"

echo "✅ Installation complete!"
echo "➡️ To start: $START_SCRIPT"
echo "➡️ To stop:  $STOP_SCRIPT"

echo "🚀 Starting container: $CONTAINER_NAME on ports 18567:18576"

# Remove old container if exists
if docker ps -a --format '{{.Names}}' | grep -Eq "^${CONTAINER_NAME}\$"; then
  echo "⚠️ Container $CONTAINER_NAME already exists. Removing..."
  docker stop "$CONTAINER_NAME" || true
  docker rm "$CONTAINER_NAME" || true
fi

docker run -d -restart unless-stopped \
  --name "$CONTAINER_NAME" \
  -p 18567-18576:"9001-9010\
  "$IMAGE_NAME"

# Verify container is running
sleep 2
if docker ps --format '{{.Names}}' | grep -Eq "^${CONTAINER_NAME}\$"; then
  echo "✅ Container $CONTAINER_NAME is running."
else
  echo "❌ Failed to start container $CONTAINER_NAME"
  exit 1
fi
