# 🔧 AI & Cybersecurity Lab Guide

Welcome! This lab is a hands-on sandbox for high-level workshops on AI safety, red teaming, and offensive security. You’ll connect to a set of example services (running on dedicated ports) and use common tooling to explore attacks, defenses, and evaluation workflows.


## Setup Lab

Pick your path and dive in:

- 🏠 **Local Lab Setup** — run everything on your machine  
  → [local/README.md](./local/README.md)

- ☁️ **Online Lab Access** — connect to the hosted lab at `IP_ADDRESS`  
  → [online/README.md](./online/README.md)

**Note**
>> Replace IP_ADDRESS with localhost if running on the same VM, or the VM’s external/public IP for remote access.


# Lab Manageemnt

Assuming you have access to the lab either local or remote, let us explore the lab:

## 🔑 API Keys

Ensure the following keys are present:

```bash
ls ~/.secrets/
ANTHROPIC_API_KEY.txt  GROQ_API_KEY.txt  OPENAI_API_KEY.txt
```

---

## 🧰 Core Tools Overview

| Tool               | Category        | Interface     | Purpose                                 |
| ------------------ | --------------- | ------------- | --------------------------------------- |
| Pentagi            | Cybersecurity   | Web (Docker)  | Cyber lab interface                     |
| AI Demo Agents     | AI Red Team     | Web (Docker)  | Prompt injection + eval agents          |
| Twenty             | CRM             | Web (Docker)  | Modern CRM target for API & logic testing |
| ERPNext            | ERP             | Web (Docker)  | Enterprise ERP target for business logic |
| EspoCRM            | CRM             | Web (Docker)  | Standard CRM target for vulnerability testing |
| Garak              | LLM Testing     | CLI           | LLM vulnerability scanner               |
| DTX                | LLM Testing     | CLI           | Red teaming & prompt evaluation         |
| Promptfoo          | LLM Evaluation  | CLI / Web     | Prompt eval framework                   |
| Vulhub             | Exploit Labs    | Web (Docker)  | Vulnerable app playground               |
| Metasploit         | Offensive Sec   | CLI / Console | Exploitation framework                  |
| Amass              | Recon           | CLI           | Attack surface mapping                  |
| Subfinder          | Recon           | CLI           | Subdomain enumeration                   |
| Nuclei             | Scanning        | CLI           | Vulnerability scanner                   |
| Nmap               | Scanning        | CLI           | Port and service scanner                |
| llm                | LLM CLI Utility | CLI           | Run LLM prompts, chat, embeddings, etc. |
| **Autogen Studio** | Agent Workflow  | Web / CLI     | Visual multi-agent design & execution   |
| Reaper             | Offensive AI   | Web (Docker)  | Real-world LLM exploitation & scanning |
| CAI Framework       | Offensive AI   | CLI / Shell   | Autonomous multi-agent penetration testing |
|DVMCP                | AI Red Team    | Web (Docker)  |  Deliberately vulnerable MCP server for red teaming and security training |

---

## 🔐 Pentagi (Cyber Lab Environment)

```bash
cd labs/pentagi/
docker compose up -d
```

* Access: `https://IP_ADDRESS:8443`
* Stop: `docker compose down`

---

## 🤖 AI Security Demo Agents

```bash
cd labs/ai-red-teaming-training/lab/vuln_apps/dtx_vuln_app_lab/
docker compose up -d
```

| Name             | URL                                              |
| ---------------- | ------------------------------------------------ |
| Chatbot Demo     | [http://IP_ADDRESS:17860](http://IP_ADDRESS:17860) |
| RAG Demo         | [http://IP_ADDRESS:17861](http://IP_ADDRESS:17861) |
| Tool Agents Demo | [http://IP_ADDRESS:17862](http://IP_ADDRESS:17862) |
| Text2SQL Demo    | [http://IP_ADDRESS:17863](http://IP_ADDRESS:17863) |
| DVMCP Demo       | [http://IP_ADDRESS:18567-18576](http://IP_ADDRESS:18567-18576) |

* Stop: `docker compose down`

---

## 🧪 Garak (LLM Scanner)

```bash
garak --model_type test.Blank --probes test.Test
```

* Output: `results.json` (optional)
* Stop: `Ctrl+C`

---

## 🧼 DTX (Prompt Security Evaluation)

**Option 1: Red Team Test (Airbench + IBM Model)**

```bash
dtx redteam run --agent echo --eval ibm38
```

**Option 2: Signature Match (Garak Dataset)**

```bash
dtx redteam run --agent echo --dataset garak -o
```

**Custom Output:**

```bash
--yml my_report.yml
```

* Default output: `report.yml`

---

## 🧠 Promptfoo (Prompt Evaluation)

```bash
promptfoo test
promptfoo dev  # Launches Web UI at http://IP_ADDRESS:8080
```

* Stop: `Ctrl+C`

---

## 🧨 Vulhub (Vulnerable CVE Labs)

Example: Drupal RCE – `CVE-2019-6341`

```bash
cd labs/vulhub/drupal/CVE-2019-6341
docker compose up -d
```

* Access via specified port (check `docker-compose.yml`)
* Stop: `docker compose down`

Explore all labs:

```bash
cd labs/vulhub/
ls
```

---

## ⚔️ Metasploit Framework

### ▶️ First-time setup

```bash
msfconsole
# Answer 'yes' to database setup
```

### ▶️ Check DB Status

```bash
db_status
# Output: Connected to msf...
```

### ▶️ Exit

```bash
exit
```

* Metasploit will remember environment on next launch.

---

## 🌐 Recon & Scanning Tools

### 🔎 Amass

```bash
amass enum -d example.com
```

### 🔎 Subfinder

```bash
subfinder -d example.com
```

### ⚡ Nuclei

```bash
nuclei -u http://example.com
```

---

### ⚡ Nmap

```bash
nmap -sV -Pn -T4 -p- example.com
```

---

## 🧩 CRM/ERP apps (Docker)

### Twenty (CRM)

**Installation:**
Run the installation script:
```bash
setup/scripts/tools/install-twenty.sh
```

**Start:**
```bash
setup/scripts/tools/labs/webapps/twenty/start.sh
```

**Stop:**
```bash
setup/scripts/tools/labs/webapps/twenty/stop.sh
```

**Setup:**
-   Access the application at `http://IP_ADDRESS:17001` (binds to `0.0.0.0`).
-   Follow the on-screen instructions to create your account.

---

### ERPNext (ERP)

**Installation:**
Run the installation script:
```bash
setup/scripts/tools/install-erpnext.sh
```

**Start:**
```bash
setup/scripts/tools/labs/webapps/erpnext/start.sh
```

**Stop:**
```bash
setup/scripts/tools/labs/webapps/erpnext/stop.sh
```

**Setup:**
-   Access the application at `http://IP_ADDRESS:17002` (binds to `0.0.0.0`).
-   **Default User:** `Administrator`
-   **Default Password:** `admin`

> [!NOTE]
> ERPNext uses port `17002` by default. If you need to change it, set the `ERP_HTTP_PORT` environment variable before starting.

---

### EspoCRM (CRM)

**Installation:**
Run the installation script:
```bash
setup/scripts/tools/install-espocrm.sh
```

**Start:**
```bash
setup/scripts/tools/labs/webapps/espocrm/start.sh
```

**Stop:**
```bash
setup/scripts/tools/labs/webapps/espocrm/stop.sh
```

**Setup:**
-   Access the application at `http://IP_ADDRESS:17003` (binds to `0.0.0.0`; websockets on `17004`).
-   **Default User:** `admin`
-   **Default Password:** `password`

> [!NOTE]
> EspoCRM uses port `17003` (and websocket `17004`) by default. If you need to change them, set the `ESPOCRM_HTTP_PORT` and `ESPOCRM_WEBSOCKET_PORT` environment variables before starting.

---

## 🤖 LLM CLI Toolkit (`llm`)


### ✨ Run Prompt

```bash
llm "Ten fun names for a pet pelican"
```

### 📄 Extract Text from Image

```bash
llm "extract text" -a scanned-document.jpg
```

### 🧠 Explain Code

```bash
cat myfile.py | llm -s "Explain this code"
```

---

### 🔌 Plugins

#### Gemini Plugin

```bash
llm install llm-gemini
llm keys set gemini
llm -m gemini-2.0-flash "Tell me facts about Mountain View"
```

#### Anthropic Plugin

```bash
llm install llm-anthropic
llm keys set anthropic
llm -m claude-4-opus "Facts about turnips"
```

#### Ollama Plugin (Local Models)

```bash
llm install llm-ollama
ollama pull llama3.2:latest
llm -m llama3.2:latest "What is the capital of France?"
```

---

### 💬 Interactive Chat

```bash
llm chat -m gpt-4.1
```

* Type `exit` to quit
* Type `!multi` for multiline input

---

## 🤖 Tool: Autogen Studio (Agent Workflow GUI)

> **Autogen Studio** is a visual interface for creating and running multi-agent workflows using Microsoft's [Autogen framework](https://github.com/microsoft/autogen).

---

### ▶️ Step 1: Export Your OpenAI API Key

Make sure your OpenAI key is available, for example in `~/.secrets/OPENAI_API_KEY.txt`.

```bash
export OPENAI_API_KEY=$(cat ~/.secrets/OPENAI_API_KEY.txt)
```

Or set it manually:

```bash
export OPENAI_API_KEY=sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

---

### ▶️ Step 2: Launch Autogen Studio with `tmux` (background mode)

Use `tmux` to keep Autogen Studio running even after you disconnect:

```bash
tmux new -d -s autogenstudio 'autogenstudio ui --port 18081 --host 0.0.0.0'
```

Your Autogen Studio server will continue running in the background.

---

### ▶️ Step 3: Access the UI

In your browser:

```
http://IP_ADDRESS:18081
```

Or replace `IP_ADDRESS` with your remote server's IP if accessing externally.

---

### ⏹ Stop / Reattach the Session

To reattach to the tmux session later:

```bash
tmux attach -t autogenstudio
```

To stop the server, hit `Ctrl + C` inside the session, then:

```bash
exit
```

To kill the session from outside:

```bash
tmux kill-session -t autogenstudio
```


## 🕵️ Reaper (Offensive LLM Exploitation Tool)

```bash
cd labs/reaper
docker compose up -d
````

* Access: `http://IP_ADDRESS:18000`
* Stop: `docker compose down`


---

## 🤖 CAI Framework (Collaborative AI Pentesting)

CAI treats penetration testing as a collaboration between human operators and AI agents. It automates distinct phases like:

- Reconnaissance
- Vulnerability Discovery
- Exploitation
- Privilege Escalation
- Reporting

These agents:
- Run real terminal commands
- Interact with GUI applications using OCR + mouse control
- Chain tasks across systems to complete full exploit paths

---

### ▶️ Step 1: Export OpenAI API Key

Make sure your key is stored in the default location:


```bash
export OPENAI_API_KEY=$(cat ~/.secrets/OPENAI_API_KEY.txt)
```

---

### ▶️ Step 2: Run CAI Framework

```bash
cai
```

This starts an interactive session where CAI agents guide and automate the penetration process.

---

### ⏹️ To Exit

Press:

```bash
Ctrl + C
```


---

## 🧨 Damn Vulnerable Model Context Protocol (DVMCP)

To start the server 

```bash
cd labs/webapps/mcp/damn
./start_service.sh
```

To stop the server 

```bash
docker stop dvmcp
```

To debug in the server 

```bash
docker logs -f dvmcp
```

To run the server with clearing data

```bash
./fresh_start.sh
```

---


## Validate the Installations 

Run the following script and check the logs

Default: logs to terminal only
```
./validate_installation.sh
```

Optional: logs to file and stdout
```
./validate_installation.sh --log ~/dtx-validate.log
```


## ✅ Summary Table

| Tool               | Start / Usage Example           | Access / Output               |
| ------------------ | ------------------------------- | ----------------------------- |
| Pentagi            | `docker compose up -d`          | `https://IP_ADDRESS:8443`      |
| Demo Agents        | `docker compose up -d`          | `http://IP_ADDRESS:17860+`     |
| Garak              | `garak --model openai:...`      | CLI or `results.json`         |
| DTX                | `dtx redteam run ...`           | `report.yml`                  |
| Promptfoo          | `promptfoo dev`                 | `http://IP_ADDRESS:8080`       |
| Vulhub             | `docker compose up -d` per CVE  | Based on lab setup            |
| Metasploit         | `msfconsole`, `db_status`       | CLI Shell                     |
| Amass              | `amass enum -d target.com`      | Subdomain list                |
| Subfinder          | `subfinder -d target.com`       | Subdomain list                |
| Nuclei             | `nuclei -u http://target.com`   | Vulnerability findings        |
| Nmap               | `nmap -sV -p- target.com`       | Port & service details        |
| llm                | `llm "your prompt"`             | Terminal response / chat mode |
| **Autogen Studio** | `autogenstudio ui --port 18081` | `http://IP_ADDRESS:18081`      |
| Reaper             | `docker compose up -d`          | `http://IP_ADDRESS:18000`       |
| **AI Red Teaming Playground Labs** | `~/labs/webapps/AI-Red-Teaming-Playground-Labs/start.sh` / `stop.sh` | `http://IP_ADDRESS:15000` (login via `?auth=...`) |
Labs launch on http://IP_ADDRESS:4001 … http://IP_ADDRESS:4012
| DVMCP             | `./start_service.sh`            | `http://IP_ADDRESS:18567-18576`       |
