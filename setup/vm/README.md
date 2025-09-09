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
 mkdir -p ~/.secrets/
 echo '< OPENAI_API_KEY >' > ~/.secrets/OPENAI_API_KEY.txt
 echo '< GROQ_API_KEY >' > ~/.secrets/GROQ_API_KEY.txt
```
- Run the Tool_setup.sh file 
``` bash
sudo ./Tool_Setup.sh 
```

### Enable Ports Forwarding to Host

#### Assuming NAT Interface

##### **Enable ports inside the VM Instance**

```
cd $HOME/labs/dtx_ai_sec_workshop_lab/ && git pull origin main && cd $HOME
sudo $HOME/labs/dtx_ai_sec_workshop_lab/setup/scripts/tools/open_ufw_ports.sh
```

##### **Enable port forwaring at VM instance at VMbox level**

**Crucial Prerequisite for Both Methods:**
Before you start, open the VirtualBox application and ensure your **"DTX AI Security Labs GUI"** virtual machine is completely **Powered Off**. This will prevent the "machine is already locked" error.

-----

### Option 1: Using the VirtualBox Graphical Interface (GUI)

This method involves manually adding each rule through the VirtualBox settings window. It's straightforward but requires repeating steps.

1.  **Open VirtualBox** and select the `"DTX AI Security Labs GUI"` VM from the list.

2.  Click the **Settings** button (the gear icon).

3.  In the Settings window, go to the **Network** section.

4.  Make sure **Adapter 1** is enabled and **Attached to: NAT**.

5.  Expand the **Advanced** section by clicking on it.

6.  Click the **Port Forwarding** button. This will open a new window showing the list of rules.

7.  Click the **"Adds new port forwarding rule"** icon (a green square with a `+`).

8.  A new row will appear. Fill in the details for the first port. For example, for port **11436**:

      * **Name:** `tcp-11436` (this is just a description)
      * **Protocol:** `TCP`
      * **Host IP:** Leave this blank (it will listen on all host network interfaces)
      * **Host Port:** `11436`
      * **Guest IP:** Leave this blank
      * **Guest Port:** `11436`

9.  **Repeat Step 7 and 8** for every single port in your list.

10. Once you have added all the rules, click **OK** on the Port Forwarding window, and then **OK** on the main Settings window to save everything.

-----

### Option 2: Using a Single Command in Your Host's Terminal

This method is much faster as it uses a single command to add all the rules at once. This should be run on your main computer, not inside the VM.

1.  **Open a terminal or command prompt on your host machine:**

      * **Windows:** Open **PowerShell** or **Command Prompt**.
      * **macOS / Linux:** Open the **Terminal** application.

2.  **Copy and paste the entire command block below** into your terminal. This command contains your specific VM name and the complete list of ports.

    ```bash
    for port in 11436 17860 17861 17862 17863 18000 18081 28080 8080 3389 10001 3000 15000 14000 14001 14002 14003 14004 14005 14006 14007 14008 14009 14010 14011 14012 18567 18568 18569 18570 18571 18572 18573 18574 18575 18576; do echo "Adding rule for port $port..."; VBoxManage modifyvm "DTX AI Security Labs GUI" --natpf1 "tcp-$port,tcp,,$port,,$port"; done; echo "All rules added successfully."
    ```

3.  **Press Enter to run the command.** It will loop through each port and apply the forwarding rule automatically.

### Final Step (After Using Either Option)

After you have added the rules using either the GUI or the command line, you can **start your VM**. The final and necessary step is to **configure the firewall inside the Ubuntu VM** to allow incoming traffic on these same ports.





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

# **Frequently Asked Questions (FAQ) for VirtualBox Errors**

This guide provides solutions to common errors encountered when setting up virtual machines in Oracle VirtualBox, particularly on a Linux host system.

Of course. Here is the extended FAQ guide, incorporating the common USB permissions error and the OVA import issue you mentioned, while maintaining the clear, solution-oriented format of the original text.

-----

### Frequently Asked Questions (FAQ) for VirtualBox Errors

This guide provides solutions to common errors encountered when setting up and managing virtual machines in Oracle VirtualBox, particularly on a Linux host system.

#### 1\. Network Adapter Not Found Error

  * **Q: Why does VirtualBox show the error "Could not start the machine... because the following physical network interfaces were not found"?**
  * **Symptom:** You try to start your VM and receive an error message listing a specific network card that was not found, such as "MediaTek Wi-Fi 6 MT7921 Wireless LAN Card".
  * **Cause:** This happens because your VM's network settings are configured in **"Bridged Adapter"** mode and are tied to a *specific* physical network card on your computer. VirtualBox cannot start the VM because it can't find or access that exact card. This could be because your Wi-Fi is off, you've moved the VM to a new computer, or the card's name has changed.
  * **Solution (Recommended): Switch to NAT**
    This is the easiest fix and works for most use cases, allowing your VM to access the internet.
    1.  Select your VM in the VirtualBox main window and click **Settings**.
    2.  Go to the **Network** tab.
    3.  In the **"Adapter 1"** tab, find the **"Attached to:"** dropdown menu.
    4.  Change the selection from "Bridged Adapter" to **"NAT"**.
    5.  Click **OK** and start your VM.
  * **Solution (Alternative): Re-select the Bridged Adapter**
    Use this option only if you specifically need your VM to appear as a separate device on your local network.
    1.  Go to **Settings \> Network \> Adapter 1**.
    2.  Ensure **"Attached to:"** is set to "Bridged Adapter".
    3.  In the **"Name:"** dropdown menu below it, select a **currently active** network connection from the list (e.g., your Ethernet port or a different Wi-Fi adapter).
    4.  Click **OK** and start your VM.

#### 2\. KVM / AMD-V Virtualization Conflict

  * **Q: How do I fix the error "VirtualBox can't enable the AMD-V extension. Please disable the KVM kernel extension... (VERR\_SVM\_IN\_USE)"?**
  * **Symptom:** Your VM fails to start, and the error message mentions **AMD-V** (for AMD CPUs) or **VT-x** (for Intel CPUs) and complains that it is already in use (`VERR_SVM_IN_USE`). It specifically mentions disabling **KVM**.
  * **Cause:** Your computer's CPU has hardware virtualization features that allow VMs to run efficiently. However, only **one program** (a hypervisor) can use these features at a time. On Linux, the built-in hypervisor is called **KVM** (Kernel-based Virtual Machine). This error means KVM is currently active, preventing VirtualBox from accessing the CPU's virtualization features.
  * **Solution (Temporary Fix): Unload the KVM Module**
    This is the best option if you switch between VirtualBox and other virtualization tools (like QEMU/GNOME Boxes). This command is temporary and will reset upon reboot.
    1.  Open a Terminal on your host Linux machine.
    2.  Run the following commands to unload the KVM modules:
        ```bash
        # For AMD Processors
        sudo modprobe -r kvm_amd
        sudo modprobe -r kvm

        # For Intel Processors
        # sudo modprobe -r kvm_intel
        # sudo modprobe -r kvm
        ```
    3.  Try starting your VirtualBox VM again. It should now work.
  * **Solution (Permanent Fix): Blacklist the KVM Module**
    Use this option only if you plan to use VirtualBox exclusively for virtualization.
    1.  Open a Terminal and create a new configuration file with a text editor:
        ```bash
        sudo nano /etc/modprobe.d/blacklist-kvm.conf
        ```
    2.  Add the following lines to the file (use `kvm_amd` for an AMD system):
        ```
        blacklist kvm_amd
        blacklist kvm
        ```
    3.  Save the file and exit (`Ctrl+X`, then `Y`, then `Enter`).
    4.  **Reboot your computer.** KVM will no longer load on startup.

#### 3\. USB Device Access Forbidden Error

  * **Q: Why can't VirtualBox access my USB devices? I get an `NS_ERROR_FAILURE (0X00004005)` error.**
  * **Symptom:** When you try to attach a USB device to a running VM (via the `Devices > USB` menu), you get an error dialog. The details mention `NS_ERROR_FAILURE` and a message like "VirtualBox is not currently allowed to access USB devices."
  * **Cause:** For security, Linux operating systems do not let standard users have low-level control over hardware. The VirtualBox installation creates a special user group called `vboxusers` specifically for this purpose. If your user account is not a member of this group, the OS will deny VirtualBox's request to connect a USB device.
  * **Solution: Add Your User to the `vboxusers` Group**
    1.  Open a Terminal.
    2.  Run the following command to add your current user to the group. You will need to enter your password.
        ```bash
        sudo usermod -aG vboxusers $USER
        ```
    3.  **This is the most important step:** The change only takes effect after a new session starts. You must either **log out and log back in**, or simply **reboot your computer**.
    4.  (Optional) After logging back in, you can verify your membership by typing `groups` in a terminal and checking for `vboxusers` in the output.
    5.  Remember, for full USB 2.0/3.0 support, you must also install the **VirtualBox Extension Pack** from the official website.

