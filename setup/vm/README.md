# Introduction

Welcome! 🎉
This guide sets up the **DTX demo lab** using a **Simple Plug and Play VM** (no Terraform, no cloud). You’ll get Docker, uv/Python, Node (via asdf), Go + AppSec tools, Ollama, NGINX, and the Detox labs cloned and ready. 

> Legal note: several tools are offensive-security utilities. Use only on systems you own or have explicit permission to test.

---
## 📂 Virtual Machine Details
- Pre-configured with all required tools  
- Services auto-start: **Nginx, Ollama**  
- Security & AI tooling ready to use out-of-the-box  

---

## 🔑 Credentials
- **User:** `dtx`  
- **Password:** `dtx`  

# Prerequisites

* **OS:** Ubuntu Server 22.04 or 24.04 (x86\_64)
* **Hardware (minimum):** **16 GB RAM**, **250+ GB disk**, **4+ vCPU**
* **Tool:** `VirtualBox`
* **Image:** [Kalki.ova](https://huggingface.co/datasets/detoxioai/dtx-ai-sec-lab/blob/main/kalki.ova)

---


# Steps to Setup Labs:

[![Setup Tutorial](./thumbnail.png)](https://www.youtube.com/watch?v=rKCMBK2kqGM)

- Install Oracle Virtualbox
- Download the [Kalki.ova](https://huggingface.co/datasets/detoxioai/dtx-ai-sec-lab/blob/main/kalki.ova)
- Open the ```Kalki.ova``` with Oracle VirtualBox ( It will started to import the labs )
- Once Import is done, Set the configuration by press the setting
- - **RAM:** 16GB RAM ( Min 8GB of RAM recommended ) 
- - **HDD:** 250GB HDD ( Min 50GB of HDD recommended )
- - **CPU :** 8 Core 
- Then Start the machine 
- Enter the Username & Password: ``` dtx : dtx ```
- Paste API keys in .secret Directory
``` bash
 echo '< OPENAI_API_KEY >' > ~/.secrets/OPENAI_API_KEY.txt
 echo '< GROQ_API_KEY >' > ~/.secrets/GROQ_API_KEY.txt
```
- Run the Tool_setup.sh file 
``` bash
sudo ./Tool_Setup.sh 
```

## Additional Configs 
- Create SSH key using 
``` bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```
- and paste the id_ed25519.pub in the ```~/.ssh/authorized_keys``` 
- Now you can access the machine using your hostmachine terminal without password 
``` bash
ssh dtx@< machine ip >
```
