#!/usr/bin/env bash
set -euxo pipefail

USER="${username}"
GO_VERSION="1.24.5"

# Create user if not exists
if ! id -u "$USER" >/dev/null 2>&1; then
  useradd -m -s /bin/bash "$USER"
fi

# Add to sudo group
usermod -aG sudo "$USER"

# Setup authorized key
mkdir -p /home/$USER/.ssh
echo "${ssh_public_key}" > /home/$USER/.ssh/authorized_keys
chmod 700 /home/$USER/.ssh
chmod 600 /home/$USER/.ssh/authorized_keys
chown -R $USER:$USER /home/$USER/.ssh

# Add passwordless sudo privileges
echo "$USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-$USER
chmod 440 /etc/sudoers.d/90-$USER

# Harden SSH
sed -i 's/^#\?PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart sshd

# === Base Packages ===
apt-get update
apt-get install -y \
  apt-transport-https \
  gcc \
  ca-certificates \
  curl \
  gnupg \
  lsb-release \
  git \
  sudo

# === Docker Installation ===
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /tmp/docker.gpg
gpg --batch --yes --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg /tmp/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] \
  https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" \
  > /etc/apt/sources.list.d/docker.list
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io
usermod -aG docker "$USER"

# === Install ASDF ===
sudo -u $USER git clone https://github.com/asdf-vm/asdf.git "/home/$USER/.asdf" --branch v0.14.0
sudo -u $USER bash -c 'echo ". \$HOME/.asdf/asdf.sh" >> ~/.bashrc'
sudo -u $USER bash -c 'echo ". \$HOME/.asdf/completions/asdf.bash" >> ~/.bashrc'

# === Install uv ===
sudo -u $USER bash -c 'curl -LsSf https://astral.sh/uv/install.sh | sh'
sudo -u $USER bash -c 'echo "source \$HOME/.local/bin/env" >> ~/.bashrc'

# === Python via uv ===
sudo -u $USER bash -c 'bash -lc "source \$HOME/.local/bin/env && uv python install 3.12"'

# === Python Tools via uv ===
sudo -u $USER bash -c 'bash -lc "
  source \$HOME/.local/bin/env
  uv tool install \"dtx[torch]>=0.26.0\" --with protobuf
  uv tool install \"garak\"
  uv tool install \"textattack[tensorflow]\"
  uv tool install \"huggingface_hub[cli,torch]\"
"'

# === Node.js via ASDF + promptfoo ===
sudo -u $USER bash -c 'bash -lc "
  . \$HOME/.asdf/asdf.sh
  asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git || true
  bash \$HOME/.asdf/plugins/nodejs/bin/import-release-team-keyring
  asdf install nodejs lts
  asdf global nodejs lts
  npm install -g promptfoo
"'

# === Install Ollama ===
curl -fsSL https://ollama.com/install.sh | sh
systemctl enable ollama
systemctl start ollama

chown dtx:dtx -R /home/$USER/.*

# === Pull Ollama Models ===
ollama pull smollm2 || true
ollama pull qwen3:0.6b || true
ollama pull llama-guard3:1b-q3_K_S || true

# === Update PATH and .bashrc ===
cat >> /home/$USER/.bashrc <<'EOF'

# === User environment setup ===

# ASDF
export PATH="$HOME/.asdf/bin:$HOME/.asdf/shims:$PATH"
. "$HOME/.asdf/asdf.sh"
. "$HOME/.asdf/completions/asdf.bash"

# uv
export PATH="$HOME/.local/bin:$PATH"
source "$HOME/.local/bin/env" 2>/dev/null || true

# npm global bin (optional)
export PATH="$HOME/.npm-global/bin:$PATH"

# ollama (optional)
export PATH="$HOME/.ollama/bin:$PATH"

# go custom binary path
export GOBIN="$HOME/.local/bin"
export PATH="$GOBIN:$PATH"

EOF

# === Write Generic Secrets ===
SECRETS_DIR="/home/$USER/.secrets"
mkdir -p "$SECRETS_DIR"

%{ for key, value in secrets_json ~}
cat <<EOF > "$SECRETS_DIR/${key}.txt"
${value}
EOF
%{ endfor ~}

chown -R $USER:$USER "/home/$USER/"
chmod 700 "$SECRETS_DIR"
chmod 600 "$SECRETS_DIR"/*.txt

# === Export API Keys from Secrets in .bashrc ===
cat >> /home/$USER/.bashrc <<'EOF'

# === Export API keys from secrets directory ===
if [ -f "$HOME/.secrets/OPENAI_API_KEY.txt" ]; then
  export OPENAI_API_KEY=$(cat "$HOME/.secrets/OPENAI_API_KEY.txt")
fi

if [ -f "$HOME/.secrets/GROQ_API_KEY.txt" ]; then
  export GROQ_API_KEY=$(cat "$HOME/.secrets/GROQ_API_KEY.txt")
fi

if [ -f "$HOME/.secrets/HF_TOKEN.txt" ]; then
  export HF_TOKEN=$(cat "$HOME/.secrets/HF_TOKEN.txt")
fi

EOF


# === Move and run install-dtx-demo-lab.sh ===
LABS_DIR="/home/$USER/labs"
REPO_URL="https://github.com/detoxio-ai/ai-red-teaming-training.git"

sudo -u "$USER" bash -c "
  mkdir -p '$LABS_DIR'
  cd '$LABS_DIR'
  git clone '$REPO_URL'
"

# === Move and run install-dtx-demo-lab.sh ===
REPO_URL="https://github.com/detoxio-ai/dtx_ai_sec_workshop_lab.git"

sudo -u "$USER" bash -c "
  mkdir -p '$LABS_DIR'
  cd '$LABS_DIR'
  git clone '$REPO_URL'
"


# === Run lab install scripts ===
INSTALL_DIR="/home/$USER/labs/dtx_ai_sec_workshop_lab/setup/scripts/tools"

for script in install-dtx-demo-lab.sh install-pentagi.sh install-vulnhub-lab.sh; do
  if [ -f "$INSTALL_DIR/$script" ]; then
    echo "🚀 Running $script"
    chmod +x "$INSTALL_DIR/$script"
    sudo -u "$USER" bash "$INSTALL_DIR/$script" || true
  fi
done

# === Copy validate_installation.sh if exists ===
VALIDATE_SCRIPT="$INSTALL_DIR/../validate_installation.sh"
if [ -f "$VALIDATE_SCRIPT" ]; then
  cp "$VALIDATE_SCRIPT" "/home/$USER/validate_installation.sh"
  chown "$USER:$USER" "/home/$USER/validate_installation.sh"
  echo "✅ Copied validate_installation.sh to /home/$USER/"
fi

# === Install Go via ASDF and tools into ~/.local/bin ===
sudo -u $USER bash -c 'bash -lc "
  . \$HOME/.asdf/asdf.sh
  asdf plugin add golang https://github.com/asdf-community/asdf-golang.git || true
  asdf install golang '"$GO_VERSION"'
  asdf global golang '"$GO_VERSION"'
  export GOBIN=\$HOME/.local/bin
  mkdir -p \$GOBIN
  go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
  go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
  go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
  CGO_ENABLED=0 go install -v github.com/owasp-amass/amass/v5/cmd/amass@main
"'

# === Install LLM CLI and set OpenAI key ===
sudo -u $USER bash -c 'bash -lc "
  source \$HOME/.local/bin/env
  uv tool install \"llm\"
  OPENAI_KEY=\$(cat \$HOME/.secrets/OPENAI_API_KEY.txt)
  llm keys set openai --value \"\$OPENAI_KEY\"
"'

# === Install Nmap ===
sudo apt-get install -y nmap

# === Install Tmux ===
sudo -u "$USER" bash -c 'bash -lc "
  echo \"🧰 Installing tmux...\"
  sudo apt-get install -y tmux

  echo \"📝 Writing .tmux.conf with Ctrl+Shift arrow navigation only...\"
  cat <<EOF > \$HOME/.tmux.conf
# --- Vim-style navigation ---
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# --- Ctrl+Shift+Arrow keys ---
# These escape sequences work in terminals that support them
bind -n C-S-Left select-pane -L
bind -n C-S-Right select-pane -R
bind -n C-S-Up select-pane -U
bind -n C-S-Down select-pane -D

# --- Mouse support ---
set -g mouse on

# --- Better visuals (optional) ---
set -g status-bg colour235
set -g status-fg white
set -g pane-border-style fg=white
set -g pane-active-border-style fg=brightgreen

# Increase scrollback history size
set -g history-limit 100000
EOF

  echo \"🔄 Reloading tmux config if in session...\"
  tmux has-session 2>/dev/null && tmux source-file \$HOME/.tmux.conf || true

  echo \"✅ tmux installed and configured with Ctrl+Shift arrow navigation only.\"
"'


# === Install Pentestgpt ===
sudo -u "$USER" bash -lc '
# Temporary directory for cloning PentestGPT
TMP_DIR="$(mktemp -d)"
git clone --depth=1 https://github.com/GreyDGL/PentestGPT "$TMP_DIR/PentestGPT"

# Remove broken submodule reference
rm -rf "$TMP_DIR/PentestGPT/benchmark"

# Install using uv from local path
uv tool install "$TMP_DIR/PentestGPT"

# Clean up temporary directory
rm -rf "$TMP_DIR"
'


# === Install CAI and other tools ===
sudo -u $USER bash -c 'bash -lc "
  source \$HOME/.local/bin/env
  uv tool install \"cai-framework\"
"'

## Install Reaper and other tools
for script in install-reaper.sh; do
  if [ -f "$INSTALL_DIR/$script" ]; then
    echo "🚀 Running $script"
    chmod +x "$INSTALL_DIR/$script"
    sudo -u "$USER" bash "$INSTALL_DIR/$script" || true
  fi
done

chown dtx:dtx -R /home/$USER


# === Create ~/.aisecurity venv and install core ML packages ===
sudo -u "$USER" bash -lc '
  set -e
  source "$HOME/.local/bin/env" 2>/dev/null || true

  PY_BIN=$( (uv python find 3.12 2>/dev/null) || command -v python3.12 || command -v python3 || echo python )
  "$PY_BIN" -m venv "$HOME/.aisecurity"

  source "$HOME/.aisecurity/bin/activate"
  python -m pip install --upgrade pip
  pip install --upgrade torch nltk transformers datasets
  deactivate
'

# === Source the venv now and run the NLTK download script (if present) ===
sudo -u "$USER" bash -lc '
  set -e
  if [ ! -d "$HOME/.aisecurity" ]; then
    echo "~/.aisecurity venv not found"; exit 1
  fi

  DL_SCRIPT="$HOME/labs/dtx_ai_sec_workshop_lab/setup/scripts/tools/download_nltk.sh"
  if [ -x "$DL_SCRIPT" ]; then
    source "$HOME/.aisecurity/bin/activate"
    "$DL_SCRIPT" || true
    deactivate || true
    touch "$HOME/.aisecurity/.nltk_downloaded" || true
  else
    echo "NLTK download script not found at $DL_SCRIPT"
  fi
'

# === Add convenient aliases and a one-time bootstrap to .bashrc ===
sudo -u "$USER" bash -lc '
  # Aliases to "source" the aisecurity venv
  if ! grep -q "activate_aisec" "$HOME/.bashrc"; then
    cat >> "$HOME/.bashrc" << "EOF"
# === ai-security helpers ===
alias activate_aisec="source $HOME/.aisecurity/bin/activate"
alias source_aisec="source $HOME/.aisecurity/bin/activate"
alias source_aisecurity="source $HOME/.aisecurity/bin/activate"
EOF
  fi

  # First-login NLTK bootstrap (runs once if not already done)
  if ! grep -q ".nltk_downloaded" "$HOME/.bashrc"; then
    cat >> "$HOME/.bashrc" << "EOF"

# === ai-security NLTK bootstrap ===
if [ -d "$HOME/.aisecurity" ] && [ ! -f "$HOME/.aisecurity/.nltk_downloaded" ]; then
  if [ -x "$HOME/labs/dtx_ai_sec_workshop_lab/setup/scripts/tools/download_nltk.sh" ]; then
    source "$HOME/.aisecurity/bin/activate"
    "$HOME/labs/dtx_ai_sec_workshop_lab/setup/scripts/tools/download_nltk.sh" || true
    deactivate || true
    touch "$HOME/.aisecurity/.nltk_downloaded" || true
  fi
fi
EOF
  fi
'


# === Run demo apps ===
INSTALL_DIR="/home/$USER/labs/dtx_ai_sec_workshop_lab/setup/scripts/tools"

# Ensure uv is on PATH for this session
export PATH="/home/dtx/.local/bin:$PATH"

for script in install-finbot-ctf-demo.sh install-openai-cs-agents-demo.sh install-ai-red-teaming-playground-labs.sh; do
  # Only source .bashrc if it exists
  [ -f "$HOME/.bashrc" ] && source "$HOME/.bashrc"

  if [ -f "$INSTALL_DIR/$script" ]; then
    echo "🚀 Running $script"
    chmod +x "$INSTALL_DIR/$script"
    # Preserve PATH for the child process (sudo can drop env vars)
    sudo --preserve-env=PATH -u "$USER" bash "$INSTALL_DIR/$script" || true
  fi
done



# === Install Metasploit ===
sudo -u $USER bash -c 'bash -lc "
  curl -sSL https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall
  chmod 755 msfinstall
  sudo rm -f /usr/share/keyrings/metasploit-framework.gpg
  yes | ./msfinstall > /dev/null 2>&1 || true
  yes | msfdb init > /dev/null 2>&1 || true
"'

sudo -u $USER bash -c 'bash -lc "
  sudo snap install searchsploit
"'

sudo -u $USER bash -c 'bash -lc "
  source \$HOME/.bashrc
  # Install AutoGenStudio via uv
  echo \"🚀 Installing autogenstudio via uv...\"
  uv tool install autogenstudio

  # Install playwright and Chrome only
  echo \"📦 Installing Playwright (Chrome only)...\"
  . \$HOME/.asdf/asdf.sh
  npm install playwright@latest
  npx playwright install chrome

  echo \"All tools installed successfully (Chrome only).\"
"'


sudo -u "$USER" bash -c 'bash -lc "
set -e

SHARED_DIR=\$HOME/shared
NGINX_CONF=/etc/nginx/sites-available/shared

echo \"🔧 Installing NGINX...\"
sudo apt update && sudo apt install -y nginx

echo \"📁 Creating shared directory at \$SHARED_DIR...\"
mkdir -p \$SHARED_DIR

if [ ! -f \$SHARED_DIR/index.html ]; then
  echo \"<h1>Hello from shared!</h1>\" > \$SHARED_DIR/index.html
fi

echo \"🔐 Setting directory and file permissions...\"
chmod o+x \"\$HOME\"
chmod o+x \"\$SHARED_DIR\"
chmod o+r \"\$SHARED_DIR\"/* || true
find \"\$SHARED_DIR\" -type d -exec chmod o+x {} \;
find \"\$SHARED_DIR\" -type f -exec chmod o+r {} \;

echo \"📝 Creating NGINX config at \$NGINX_CONF...\"
sudo bash -c \"cat > \$NGINX_CONF\" <<EOF
server {
    listen 80 default_server;
    server_name _;

    root \$HOME/shared;
    index index.html;

    location / {
        try_files \\\$uri \\\$uri/ =404;
    }

    location /shared/ {
        alias \$HOME/shared/;
        index index.html;
        autoindex on;
        autoindex_exact_size off;
    }
}
EOF

echo \"🔗 Enabling NGINX site...\"
sudo ln -sf \$NGINX_CONF /etc/nginx/sites-enabled/shared
sudo rm -f /etc/nginx/sites-enabled/default

echo \"🔄 Testing and reloading NGINX...\"
sudo nginx -t
sudo systemctl reload nginx

echo \"✅ NGINX is now serving: \$SHARED_DIR\"
"'
