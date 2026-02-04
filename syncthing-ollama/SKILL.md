---
name: syncthing-ollama
description: Setup and manage Syncthing for peer-to-peer Ollama model sharing across ranch machines. Use when configuring distributed model synchronization, enabling all machines to share a unified model library, or troubleshooting model replication issues across the network.
---

# Syncthing Ollama Skill

Syncthing enables decentralized P2P replication of Ollama models across your ranch network (aurora-continuum, halcyon-vector, logos-prime, chrysalis-hub, lilly). Once configured, all machines sync `/usr/share/ollama/.ollama/models` automatically, reducing bandwidth and ensuring every machine has access to the full model library.

## Quick Setup

### 1. Install Syncthing on All Machines

On each ranch machine (aurora-continuum, halcyon-vector, logos-prime, chrysalis-hub, lilly), run:

```bash
sudo apt-get update && sudo apt-get install -y syncthing
```

Verify installation:

```bash
syncthing --version
```

### 2. Create Syncthing Systemd Service for Ollama User

On each machine, create a dedicated systemd service to run Syncthing as the `ollama` user (models are owned by ollama):

```bash
sudo tee /etc/systemd/system/syncthing-ollama.service > /dev/null <<EOF
[Unit]
Description=Syncthing (Ollama Models)
After=network.target

[Service]
Type=notify
User=ollama
Group=ollama
ProtectSystem=full
ProtectHome=yes
NoNewPrivileges=yes
PrivateTmp=yes
Environment="STNORESTART=yes"
Environment="STNODEFAULTFOLDER=yes"
ExecStart=/usr/bin/syncthing serve --no-browser --logfile=default
ExecReload=/bin/kill -HUP \$MAINPID
Restart=on-failure
RestartSec=5
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
EOF
```

Enable and start the service:

```bash
sudo systemctl daemon-reload
sudo systemctl enable syncthing-ollama
sudo systemctl start syncthing-ollama
```

Verify it's running:

```bash
sudo systemctl status syncthing-ollama
```

### 3. Grant Access to Ollama Models Directory

Syncthing needs write permissions to `/usr/share/ollama/.ollama/models`. If it doesn't have access, fix permissions:

```bash
sudo chown -R ollama:ollama /usr/share/ollama/.ollama/models
sudo chmod -R u+rwX,g+rX,o- /usr/share/ollama/.ollama/models
```

### 4. Configure Syncthing via Web UI

Syncthing runs a web interface on each machine. To access it, SSH into each machine and port-forward:

```bash
ssh -L 8384:localhost:8384 user@aurora-continuum
# Then open http://localhost:8384 in your browser
```

Repeat for each machine.

**On the first machine (aurora-continuum):**

1. Open http://localhost:8384
2. Go to **Settings** → **General** and set a username/password if needed
3. Go to **Folders** → **Add Folder**
   - **Label:** `ollama-models`
   - **Folder ID:** `ollama-models` (same on all machines)
   - **Folder Path:** `/usr/share/ollama/.ollama/models`
   - **Folder Type:** `Receive & Send` (all machines send and receive)
   - Click **Save**

**On subsequent machines (halcyon-vector, logos-prime, etc.):**

1. Open their web UI (http://localhost:8384)
2. Go to **Settings** → **General** and set same username/password (optional but recommended)
3. Go to **Folders** → **Add Folder**
   - Same **Label:** `ollama-models`
   - Same **Folder ID:** `ollama-models`
   - Same **Folder Path:** `/usr/share/ollama/.ollama/models`
   - Same **Folder Type:** `Receive & Send`
4. Click **Save**

### 5. Connect Devices

On aurora-continuum (or any machine), go to **Remote Devices** → **Add Device**. You'll see a QR code or device ID.

On the next machine (e.g., halcyon-vector):
1. Click **Remote Devices** → **Add Device**
2. Scan the QR code from aurora-continuum OR paste its device ID
3. Name it (e.g., `aurora-continuum`)
4. Click **Save**

**Repeat this bidirectionally for all pairs:**
- Aurora ↔ Halcyon
- Aurora ↔ Logos
- Aurora ↔ Chrysalis
- Aurora ↔ Lilly
- (And optionally between non-aurora pairs for better mesh connectivity)

### 6. Verify Replication

Monitor the sync progress from the web UI. Each machine shows:
- Folder status (Up to Date / Syncing / etc.)
- Bytes synced
- Last sync time

Initial sync of 153GB may take hours depending on network speed. Syncthing will:
1. Scan local models
2. Exchange metadata with peers
3. Download missing models in parallel from available peers
4. Verify integrity with checksums

Once all machines show "Up to Date," replication is complete.

## Monitoring & Maintenance

### Check Sync Status

```bash
# View last synced time and status
curl -H "X-API-Key: YOUR_API_KEY" http://localhost:8384/rest/db/status?folder=ollama-models | jq
```

### View Syncthing Logs

```bash
sudo journalctl -u syncthing-ollama -f
```

### Restart Syncthing

```bash
sudo systemctl restart syncthing-ollama
```

### Reset Folder (if needed)

If sync gets stuck, reset by removing local state:

```bash
sudo systemctl stop syncthing-ollama
sudo rm -rf /usr/share/ollama/.ollama/models/.stversions
sudo systemctl start syncthing-ollama
```

## Troubleshooting

**Models not syncing?**
- Check firewall: Syncthing needs TCP/UDP on ports 22000 and 21027 (discovery)
- Verify folder path exists: `ls -la /usr/share/ollama/.ollama/models`
- Check permissions: `sudo ls -la /usr/share/ollama/.ollama/models`

**High CPU or bandwidth?**
- Syncthing performs continuous scanning; this is normal during initial sync
- Adjust scan interval in **Settings** → **Options** → **Folder Rescan Interval**
- Set to 3600+ seconds (1+ hour) to reduce CPU after initial sync

**Device not connecting?**
- Verify port forwarding (22000/tcp open between machines)
- Check DNS resolution: `ping aurora-continuum` from halcyon-vector
- Manually add device IDs instead of relying on discovery

## Advanced: Direct Device Connection

For faster connectivity, optionally configure static addresses for each machine in **Remote Devices** → **Advanced** → **Addresses**:

Example for aurora-continuum on halcyon-vector's device config:
```
tcp://192.168.x.x:22000
```

Replace with actual ranch LAN IPs.

## API Configuration (Optional)

For programmatic access, enable API access and generate an API key in **Settings** → **API**. Use the API to monitor status:

```bash
curl -H "X-API-Key: YOUR_API_KEY" http://localhost:8384/rest/system/status | jq
```

See `references/syncthing-api.md` for full API reference.
