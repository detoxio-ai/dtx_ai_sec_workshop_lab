#!/usr/bin/env bash
set -euxo pipefail

echo "🚀 Installing full lab extras (this may take a while)..."

TARGET_USER="dtx"
HOME="/home/$TARGET_USER"
cd $HOME

# ---- Shell PATHs ----
cat >> /home/$TARGET_USER/.bashrc <<'BRC'
export PATH="$HOME/.asdf/bin:$HOME/.asdf/shims:$PATH"
. "$HOME/.asdf/asdf.sh"
. "$HOME/.asdf/completions/asdf.bash"
export PATH="$HOME/.local/bin:$PATH"
source "$HOME/.local/bin/env" 2>/dev/null || true
export PATH="$HOME/.npm-global/bin:$PATH"
export PATH="$HOME/.ollama/bin:$PATH"
export GOBIN="$HOME/.local/bin"
export PATH="$GOBIN:$PATH"
export PATH="$PATH:/usr/local/go/bin"
BRC

# NVM Installation
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
nvm --version


# ---- Python tools ----
source $HOME/.local/bin/env
uv tool install "dtx[torch]>=0.26.0"
uv tool install "garak"
uv tool install "textattack[tensorflow]"
uv tool install "huggingface_hub[cli,torch]"
uv tool install "llm"
uv tool install "cai-framework"

# ---- Secrets -> files + export on login ----
SECRETS_DIR="/home/$TARGET_USER/.secrets"
mkdir -p "$SECRETS_DIR"
echo "" > "$SECRETS_DIR/OPENAI_API_KEY.txt"
echo "" > "$SECRETS_DIR/GROQ_API_KEY.txt"
chown -R $TARGET_USER:$TARGET_USER "/home/$TARGET_USER/"
chmod 700 "$SECRETS_DIR" || true

cat >> /home/$TARGET_USER/.bashrc <<'BRC'
[ -f "$HOME/.secrets/OPENAI_API_KEY.txt" ] && export OPENAI_API_KEY=$(cat "$HOME/.secrets/OPENAI_API_KEY.txt")
[ -f "$HOME/.secrets/GROQ_API_KEY.txt" ]   && export GROQ_API_KEY=$(cat "$HOME/.secrets/GROQ_API_KEY.txt")
BRC

# ---- Labs repos ----
LABS_DIR="/home/$TARGET_USER/labs"
sudo -u "$TARGET_USER" bash -lc "mkdir -p '$LABS_DIR' && cd '$LABS_DIR' && \
  git clone https://github.com/detoxio-ai/ai-red-teaming-training.git || true && \
  git clone https://github.com/detoxio-ai/dtx_ai_sec_workshop_lab.git || true"

# ---- Run lab install scripts if present ----
INSTALL_DIR="/home/$TARGET_USER/labs/dtx_ai_sec_workshop_lab/setup/scripts/tools"
for script in install-dtx-demo-lab.sh install-pentagi.sh install-vulnhub-lab.sh; do
  if [ -f "$INSTALL_DIR/$script" ]; then
    echo "🚀 Running $script"
    chmod +x "$INSTALL_DIR/$script"
    sudo -u "$TARGET_USER" bash "$INSTALL_DIR/$script" || true
  fi
done

# ---- Copy validator if present ----
VALIDATE_SCRIPT="$INSTALL_DIR/../validate_installation.sh"
if [ -f "$VALIDATE_SCRIPT" ]; then
  cp "$VALIDATE_SCRIPT" "/home/$TARGET_USER/validate_installation.sh"
  chown "$TARGET_USER:$TARGET_USER" "/home/$TARGET_USER/validate_installation.sh"
fi


# ---- ProjectDiscovery Tools ----
. $HOME/.asdf/asdf.sh
export GOBIN=$HOME/.local/bin
mkdir -p $GOBIN
go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
go install -v github.com/projectdiscovery/nuclei/v3/cmd/nuclei@latest
go install -v github.com/projectdiscovery/subfinder/v2/cmd/subfinder@latest
CGO_ENABLED=0 go install -v github.com/owasp-amass/amass/v5/cmd/amass@main

# ---- PentestGPT ----
TMP_DIR="$(mktemp -d)"
git clone --depth=1 https://github.com/GreyDGL/PentestGPT "$TMP_DIR/PentestGPT"
rm -rf "$TMP_DIR/PentestGPT/benchmark"
uv tool install "$TMP_DIR/PentestGPT"
rm -rf "$TMP_DIR"

# ---- Metasploit + searchsploit ----
sudo apt-get install -y nmap
curl -sSL https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb > msfinstall
chmod 755 msfinstall
yes | ./msfinstall || true
yes | msfdb init || true
sudo snap install searchsploit || true

# ---- promptfoo + Playwright (Chrome only) ----
. $HOME/.asdf/asdf.sh
sudo npm install -g promptfoo
sudo npm install -g playwright
playwright install chrome || true

# ------- Models Import -------
ollama pull smollm2 || true
ollama pull qwen3:0.6b || true
ollama pull llama-guard3:1b-q3_K_S || true

echo "👉 If you have API keys (OpenAI, Anthropic, Groq), save them in ~/.secrets/"
echo "   Example: echo 'sk-xxxxx' > ~/.secrets/OPENAI_API_KEY.txt"

echo "✅ Full lab setup complete!"
