# 🚀 Online Lab Access Guide (High-Level Workshop)

Welcome to the **Online Lab**! 🎉
This environment has been set up for a **hands-on, high-level workshop**, giving you access to a variety of tools and services that run on dedicated ports. Each service showcases different aspects of AI safety, red teaming, and offensive security testing.

Think of it as your own **sandbox** — you’ll be able to log in, explore, and interact with different demo applications and security tools. All you need is the **server address** (`IP_ADDRESS`) and the **private key** provided to you (either a `.ppk` file for Windows or an `id_ed25519` key for Linux/macOS/WSL).

The lab exposes several example services on the following ports:
**8443, 17860–17863, 8080, 18081, 18000**

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

## 🔎 Verify access (direct, no tunnel)

Open these in your browser:

```
https://IP_ADDRESS:8443          (self-signed TLS expected)
http://IP_ADDRESS:17860
http://IP_ADDRESS:17861
http://IP_ADDRESS:17862
http://IP_ADDRESS:17863
http://IP_ADDRESS:8080
http://IP_ADDRESS:18081
http://IP_ADDRESS:18000
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
-L 8080:localhost:8080 \
-L 18081:localhost:18081 \
-L 18000:localhost:18000 \
dtx@IP_ADDRESS
```

Then open locally:

```
https://localhost:8443
http://localhost:17860
http://localhost:17861
http://localhost:17862
http://localhost:17863
http://localhost:8080
http://localhost:18081
http://localhost:18000
```

### B) PuTTY tunnels (Windows)

1. **Session**: `IP_ADDRESS`
2. **Connection → SSH → Tunnels** → Add these (repeat for each):

   * **Source port** `8443`  → **Destination** `127.0.0.1:8443`  → **Add**
   * `17860` → `127.0.0.1:17860` → **Add**
   * `17861` → `127.0.0.1:17861` → **Add**
   * `17862` → `127.0.0.1:17862` → **Add**
   * `17863` → `127.0.0.1:17863` → **Add**
   * `8080`  → `127.0.0.1:8080`  → **Add**
   * `18081` → `127.0.0.1:18081` → **Add**
   * `18000` → `127.0.0.1:18000` → **Add**
3. Back to **Session** → **Open**
4. Browse to the **localhost** URLs shown above.

---
