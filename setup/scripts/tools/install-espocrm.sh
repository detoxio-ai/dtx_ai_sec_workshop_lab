#!/bin/bash
set -e

# Configuration
APP_NAME="espocrm"
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SETUP_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
WEBAPPS_DIR="$SCRIPT_DIR/labs/webapps"
INSTALL_DIR="$WEBAPPS_DIR/$APP_NAME"
REPO_URL="https://github.com/espocrm/espocrm.git"
DOCKER_DIR="$SETUP_ROOT/docker/$APP_NAME"

# Create directories
mkdir -p "$WEBAPPS_DIR"
mkdir -p "$DOCKER_DIR"
cd "$WEBAPPS_DIR"

# Clone repository
if [ ! -d "$INSTALL_DIR/.git" ]; then
    if [ -d "$INSTALL_DIR" ]; then
        echo "Existing $INSTALL_DIR found but not a git repo. Moving aside."
        mv "$INSTALL_DIR" "${INSTALL_DIR}.bak-$(date +%s)"
    fi
    echo "Cloning $APP_NAME..."
    git clone "$REPO_URL" "$APP_NAME"
else
    echo "$APP_NAME already cloned."
fi

cd "$INSTALL_DIR"

# Ensure docker env file exists
if [ -f "$DOCKER_DIR/.env.example" ] && [ ! -f "$DOCKER_DIR/.env" ]; then
    cp "$DOCKER_DIR/.env.example" "$DOCKER_DIR/.env"
fi

# Create start.sh
cat <<'EOF' > start.sh
#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SETUP_ROOT="$(cd "$SCRIPT_DIR/../../../../.." && pwd)"
COMPOSE_FILE="$SETUP_ROOT/docker/espocrm/docker-compose.yml"
ENV_FILE="${ESPOCRM_ENV_FILE:-$SETUP_ROOT/docker/espocrm/.env}"
ENV_TEMPLATE="$SETUP_ROOT/docker/espocrm/.env.example"

ensure_docker() {
    if ! command -v docker >/dev/null 2>&1; then
        echo "Docker is required but not found in PATH. Install Docker Engine and retry." >&2
        exit 1
    fi

    if docker info >/dev/null 2>&1; then
        return
    fi

    echo "Docker daemon is not running. Attempting to start it..." >&2

    if command -v systemctl >/dev/null 2>&1; then
        if systemctl start docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
            return
        fi
    fi

    if command -v service >/dev/null 2>&1; then
        if service docker start >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
            return
        fi
    fi

    echo "Docker daemon is unavailable or not accessible. Start it manually (e.g. 'sudo systemctl start docker') and rerun this script." >&2
    exit 1
}

ensure_env() {
    if [ ! -f "$ENV_FILE" ] && [ -f "$ENV_TEMPLATE" ]; then
        cp "$ENV_TEMPLATE" "$ENV_FILE"
        echo "Created $ENV_FILE from template."
    fi
}

if [ ! -f "$COMPOSE_FILE" ]; then
    echo "docker-compose.yml not found at $COMPOSE_FILE. Create it first (see EspoCRM docker-compose docs) and retry." >&2
    exit 1
fi

ensure_env
ensure_docker

compose_cmd=(docker compose -f "$COMPOSE_FILE")
if [ -f "$ENV_FILE" ]; then
    compose_cmd+=(--env-file "$ENV_FILE")
fi
compose_cmd+=(up -d)

"${compose_cmd[@]}"
EOF
chmod +x start.sh

# Create stop.sh
cat <<'EOF' > stop.sh
#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SETUP_ROOT="$(cd "$SCRIPT_DIR/../../../../.." && pwd)"
COMPOSE_FILE="$SETUP_ROOT/docker/espocrm/docker-compose.yml"
ENV_FILE="${ESPOCRM_ENV_FILE:-$SETUP_ROOT/docker/espocrm/.env}"
ENV_TEMPLATE="$SETUP_ROOT/docker/espocrm/.env.example"

ensure_docker() {
    if ! command -v docker >/dev/null 2>&1; then
        echo "Docker is required but not found in PATH. Install Docker Engine and retry." >&2
        exit 1
    fi

    if docker info >/dev/null 2>&1; then
        return
    fi

    echo "Docker daemon is not running. Attempting to start it..." >&2

    if command -v systemctl >/dev/null 2>&1; then
        if systemctl start docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
            return
        fi
    fi

    if command -v service >/dev/null 2>&1; then
        if service docker start >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
            return
        fi
    fi

    echo "Docker daemon is unavailable or not accessible. Start it manually (e.g. 'sudo systemctl start docker') and rerun this script." >&2
    exit 1
}

ensure_env() {
    if [ ! -f "$ENV_FILE" ] && [ -f "$ENV_TEMPLATE" ]; then
        cp "$ENV_TEMPLATE" "$ENV_FILE"
        echo "Created $ENV_FILE from template."
    fi
}

if [ ! -f "$COMPOSE_FILE" ]; then
    echo "docker-compose.yml not found at $COMPOSE_FILE. Nothing to stop." >&2
    exit 1
fi

ensure_env
ensure_docker

compose_cmd=(docker compose -f "$COMPOSE_FILE")
if [ -f "$ENV_FILE" ]; then
    compose_cmd+=(--env-file "$ENV_FILE")
fi

compose_cmd+=(down --remove-orphans)

"${compose_cmd[@]}"
EOF
chmod +x stop.sh

echo "$APP_NAME installed in $INSTALL_DIR"
echo "Use $INSTALL_DIR/start.sh to start and $INSTALL_DIR/stop.sh to stop."
