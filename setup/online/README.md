# 🚀 Online Lab Access Guide (High-Level Workshop)

Welcome to the **Online Lab**! 🎉
This environment has been set up for a **hands-on, high-level workshop**, giving you access to a variety of tools and services that run on dedicated ports. Each service showcases different aspects of AI safety, red teaming, and offensive security testing.

Think of it as your own **sandbox** — you’ll be able to log in, explore, and interact with different demo applications and security tools. All you need is the **server address** (`IP_ADDRESS`) and the **private key** provided to you (either a `.ppk` file for Windows or an `id_ed25519` key for Linux/macOS/WSL).

The lab exposes several example services on the following ports:
**8443, 17860–17863, 18081, 18000, 15000, 17001, 17002, 17003, 4001–4012**

Depending on your setup:

* 🪟 **Windows users** connect using **PuTTY** with a `.ppk` key
* 💻 **Linux/macOS/WSL users** connect using the terminal with the provided SSH key
* 🔐 **If you have firewall restrictions**, you’ll use **SSH tunnels** to forward ports and access services via `localhost`

---

## ✅ Prerequisites (provided to you)

* Public **IP/DNS**: `IP_ADDRESS`
* **SSH key**:

  * Windows: `.ppk` (PuTTY)
  * Linux/macOS/WSL: `id_ed25519`
* (Optional) Your network allows outbound SSH (port 22). If not, use SSH tunnels below.

---

## ❓ Quick selector

* **Windows?** Use **PuTTY** with `.ppk`.
* **Linux/macOS/WSL?** Use **OpenSSH** with `id_ed25519`.
* **Firewalled?** Use the **single-command SSH tunnel** (or PuTTY tunnels) and browse via `localhost`.

---

## 🔐 Connect (Linux/macOS/WSL)

```bash
chmod 600 id_ed25519
ssh -i id_ed25519 -o IdentitiesOnly=yes dtx@IP_ADDRESS
```

## 🪟 Connect (Windows / PuTTY)

1. Open **PuTTY**
2. **Host Name**: `dtx@IP_ADDRESS`
3. **Connection → SSH → Auth** → select your **.ppk** under *Private key file for authentication*
4. **Open**

---
## 🖥️ Connect via RDP

If you prefer a full **desktop environment** for the workshop:

```bash
export DTX_PASSWORD=<passwd>
./labs/dtx_ai_sec_workshop_lab/setup/scripts/tools/setup-xrdp.sh
```

Once the setup finishes, use any RDP client to connect to the server:

* **Linux/macOS**: `rdesktop`, `Remmina`, or another RDP client
* **Windows**: Use the built-in **Remote Desktop Connection**

👉 Connect to the server using the same `IP_ADDRESS` and the password you exported in the `DTX_PASSWORD` variable.

After logging in, you’ll have access to the same lab tools and services as in the SSH setup — now through a graphical desktop session.

---


## 🔎 Verify access (direct, no tunnel)

Open these in your browser:

```
https://IP_ADDRESS:8443          (self-signed TLS expected)
http://IP_ADDRESS:17860
http://IP_ADDRESS:17861
http://IP_ADDRESS:17862
http://IP_ADDRESS:17863
http://IP_ADDRESS:18081
http://IP_ADDRESS:18000
http://IP_ADDRESS:15000          (Playground Home UI)
http://IP_ADDRESS:17001          (Twenty CRM)
http://IP_ADDRESS:17002          (ERPNext)
http://IP_ADDRESS:17003          (EspoCRM; websocket on 17004 if needed)
http://IP_ADDRESS:4001..4012     (Playground Labs — one port per lab)
```

CLI spot-checks from your laptop:

```bash
# macOS/Linux
nc -vz IP_ADDRESS 8443
curl -I http://IP_ADDRESS:18081

# Windows PowerShell
Test-NetConnection IP_ADDRESS -Port 8443
```

If these fail, your network likely blocks inbound access—use tunnels.

---

## 🔀 If firewalled: create a tunnel

### A) One-shot SSH tunnel (Linux/macOS/WSL)

Forwards remote ports to your **local** machine:

```bash
ssh -i id_ed25519 -o IdentitiesOnly=yes -N \
-L 8443:localhost:8443 \
-L 17860:localhost:17860 -L 17861:localhost:17861 \
-L 17862:localhost:17862 -L 17863:localhost:17863 \
-L 18081:localhost:18081 \
-L 18000:localhost:18000 \
-L 15000:localhost:15000 \
-L 17001:localhost:17001 \
-L 17002:localhost:17002 \
-L 17003:localhost:17003 \
# websocket (optional)
# -L 17004:localhost:17004 \
# Labs (choose any between 4001–4012, one -L per port you plan to use)
# -L 4001:localhost:4001 -L 4002:localhost:4002 ... -L 4012:localhost:4012 \
dtx@IP_ADDRESS
```

Then open locally:

```
https://localhost:8443
http://localhost:17860
http://localhost:17861
http://localhost:17862
http://localhost:17863
http://localhost:18081
http://localhost:18000
http://localhost:15000
http://localhost:17001
http://localhost:17002
http://localhost:17003
# websocket (optional): ws://localhost:17004
```

### B) PuTTY tunnels (Windows)

1. **Session**: `IP_ADDRESS`
2. **Connection → SSH → Tunnels** → Add these (repeat for each):

   * **Source port** `8443`  → **Destination** `127.0.0.1:8443`  → **Add**
   * `17860` → `127.0.0.1:17860` → **Add**
   * `17861` → `127.0.0.1:17861` → **Add**
   * `17862` → `127.0.0.1:17862` → **Add**
   * `17863` → `127.0.0.1:17863` → **Add**
   * `18081` → `127.0.0.1:18081` → **Add**
   * `18000` → `127.0.0.1:18000` → **Add**
   * `15000` → `127.0.0.1:15000` → **Add**
   * `17001` → `127.0.0.1:17001` → **Add** (Twenty CRM)
   * `17002` → `127.0.0.1:17002` → **Add** (ERPNext)
   * `17003` → `127.0.0.1:17003` → **Add** (EspoCRM HTTP)
   * `17004` → `127.0.0.1:17004` → **Add** (EspoCRM websocket, optional)
   * (Labs) Add any of 4001–4012 → 127.0.0.1:<same port>
3. Back to **Session** → **Open**
4. Browse to the **localhost** URLs shown above.

---
