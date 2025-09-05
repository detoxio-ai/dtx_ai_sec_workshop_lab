# 🛡️ AI & Cybersecurity Lab

A hands-on sandbox for **AI security**—practice adversarial testing of LLMs, harden AI apps, and explore how AI can both attack and defend systems. The lab ships runnable services, curated targets, and a practical toolchain (Docker, uv/Python, Node via asdf, Go + appsec tools, Ollama, NGINX, Metasploit, nuclei/httpx/subfinder, etc.).

---

## 🔎 About the Lab

* Build intuition for **LLM risks** (jailbreaks, prompt injection, tool abuse, data exfiltration).
* Evaluate **guards/filters** (e.g., Prompt/Llama Guard) and measure trade-offs.
* Use AI as a **copilot for security**: triage findings, summarize evidence, bootstrap reports.
* Designed for workshops, purple-team drills, and repeatable experiments.

---

## 🧪 Use Cases

### AI Red Teaming

* Craft/automate **jailbreak & prompt-injection** attacks and track bypass rates.
* Probe **agent/tool misuse** scenarios and validate least-privilege configs.
* Evaluate defenses (prompts, filters, output checks, retrieval hardening) and **re-test**.

### AI for Pentesting

* **Recon copilot:** aggregate subfinder/httpx/nuclei output and propose next steps.
* Generate payload variants and rationale for **scoped, ethical** exploitation practice.
* **Report assistant:** turn terminal evidence into CWE/OWASP-mapped draft write-ups.

---

## 🚀 Setup (pick one)
* **Kalki VM** → [`setup/vm/README.md`](setup/vm/README.md)
* **Setup yourself** → [`setup/local/README.md`](setup/local/README.md)
* **Google Cloud Platform (Terraform + Make)** → [`setup/gcp/README.md`](setup/gcp/README.md)
* **Hosted / Online Instance (provided by Trainer)** → [`setup/online/README.md`](setup/online/README.md)

**Additional Setup (Recommended): GPUs & Online Models (Groq, OpenAI, Detoxio Gateway)** → [`setup/optionals/README.md`](setup/optionals/README.md)

---

## 📦 Repo Map

* [`setup/`](setup) – installation guides & scripts

  * [`local/`](setup/local) · [`gcp/`](setup/gcp) · [`online/`](setup/online) · [`optionals/`](setup/optionals) · [`scripts/`](setup/scripts)

---

## 🔐 Safety & Ethics

Use only on systems you own or have **explicit permission** to test. Keep API keys and secrets **out of version control**.

---

## 📜 License

Licensed under **GNU General Public License v2.0 (GPL-2.0)**.
See [`LICENSE`](LICENSE) for details.
