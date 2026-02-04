# Syncthing Ollama Troubleshooting Guide

## Common Issues

### Service Won't Start

**Symptom:** `systemctl status syncthing-ollama` shows failed or inactive

**Causes & Solutions:**

1. **Permissions issue**
   ```bash
   # Check ollama user exists
   id ollama
   
   # Fix home directory
   sudo usermod -d /var/lib/syncthing ollama
   sudo mkdir -p /var/lib/syncthing
   sudo chown ollama:ollama /var/lib/syncthing
   ```

2. **Port already in use**
   ```bash
   sudo lsof -i :22000
   sudo lsof -i :21027
   # Kill conflicting process or change port in Syncthing config
   ```

3. **Check logs**
   ```bash
   sudo journalctl -u syncthing-ollama -n 50 --no-pager
   ```

### Sync Stuck or Not Starting

**Symptom:** Folder shows "Syncing" but progress isn't advancing

**Solutions:**

1. **Check folder status**
   ```bash
   sudo systemctl stop syncthing-ollama
   ls -la /usr/share/ollama/.ollama/models/
   sudo systemctl start syncthing-ollama
   ```

2. **Reset sync state (if necessary)**
   ```bash
   sudo systemctl stop syncthing-ollama
   # Backup first!
   sudo tar -czf /var/lib/syncthing-backup.tar.gz /var/lib/syncthing/
   
   # Reset (this will re-scan the folder)
   sudo rm -rf /var/lib/syncthing/model/
   sudo systemctl start syncthing-ollama
   ```

3. **Monitor in real-time**
   ```bash
   sudo journalctl -u syncthing-ollama -f
   ```

### Devices Not Connecting

**Symptom:** Remote device shows "Disconnected" in web UI

**Solutions:**

1. **Test network connectivity**
   ```bash
   ping aurora-continuum
   nc -zv aurora-continuum 22000
   ```

2. **Check firewall**
   ```bash
   sudo ufw allow 22000/tcp
   sudo ufw allow 21027/udp
   sudo ufw reload
   ```

3. **Verify addresses in config**
   - Open web UI → Remote Devices
   - Edit device → Addresses
   - Ensure IP and port are correct: `tcp://192.168.x.x:22000`

4. **Force reconnection**
   - Web UI → Remote Device → "Restart"
   - Or restart service: `sudo systemctl restart syncthing-ollama`

### High CPU Usage

**Symptom:** Syncthing process using 50%+ CPU

**Causes & Solutions:**

1. **Continuous scanning** (normal during initial sync)
   - Reduce scan frequency in web UI → Settings → Options → Folder Rescan Interval
   - Set to 3600 (1 hour) or higher after initial sync

2. **Large number of files**
   - Ollama models are usually large blobs, shouldn't be an issue
   - If many small files: increase `staggeredVersioningCleanupDelayS`

3. **Disk I/O bottleneck**
   - Check disk activity: `iostat -x 1`
   - May need to upgrade storage or reduce concurrent writes

### Folder Showing Different Bytes

**Symptom:** Same folder shows different byte counts on different machines

**Causes & Solutions:**

1. **Sync in progress**
   - This is normal; wait for all machines to reach "Up to Date"
   - Check completion percentage in web UI

2. **Symlinks or special files**
   - Syncthing may handle symlinks differently
   - Check: Settings → Options → Follow Symlinks

3. **File conflicts**
   - Check for `.sync-conflict` files
   - Web UI shows pull errors
   - Resolve conflicts manually or use trash can versioning

### Models Directory Permissions

**Symptom:** Syncthing can't write to `/usr/share/ollama/.ollama/models`

**Solutions:**

```bash
# Verify permissions
ls -la /usr/share/ollama/.ollama/models/

# Fix ownership
sudo chown -R ollama:ollama /usr/share/ollama/.ollama/models

# Fix permissions (user=read+write+execute, group=read+execute, other=none)
sudo chmod -R u+rwX,g+rX,o- /usr/share/ollama/.ollama/models

# Verify
ls -la /usr/share/ollama/.ollama/models/
```

### Need to Stop Sync Temporarily

**Pause folder (don't delete data):**
```bash
# Web UI → Folder → Pause
# Or REST API:
curl -X POST -H "X-API-Key: YOUR_API_KEY" \
  "http://localhost:8384/rest/config/folders/ollama-models" \
  -d '{"paused": true}'
```

**Resume:**
```bash
# Web UI → Folder → Resume
# Or API:
curl -X POST -H "X-API-Key: YOUR_API_KEY" \
  "http://localhost:8384/rest/config/folders/ollama-models" \
  -d '{"paused": false}'
```

### Remove Device from Sync

**Via Web UI:**
1. Go to Remote Devices
2. Click device → "Remove"
3. Confirm

**Note:** This only removes from this machine's perspective; doesn't affect other devices.

### Restore from Trash Can Versioning

Syncthing creates `.stversions` folder with old/deleted files:

```bash
# List old versions
ls -la /usr/share/ollama/.ollama/models/.stversions/

# Restore a file (copy from .stversions back to main folder)
sudo cp /usr/share/ollama/.ollama/models/.stversions/old-model .
```

## Performance Optimization

### Reduce Scan Overhead

```bash
# Edit folder settings
# Settings → Folder → Rescan Interval
# Set to 3600+ seconds (once per hour or less)
```

### Tune Block Size

For faster sync of large blobs:
```bash
# Web UI → Settings → Options → Folder Block Size
# Default is 128 KB; models may benefit from larger blocks (256-512 KB)
```

### Monitor Network Usage

```bash
# Watch real-time bandwidth
nethogs
# or
iftop

# Check Syncthing's bandwidth in logs
sudo journalctl -u syncthing-ollama -f | grep -i "transmitted\|received"
```

## Backup & Recovery

**Backup Syncthing state before major changes:**

```bash
sudo tar -czf ~/syncthing-backup-$(date +%Y%m%d).tar.gz \
  /var/lib/syncthing/ \
  /usr/share/ollama/.ollama/models/
```

**Restore:**

```bash
sudo tar -xzf ~/syncthing-backup-20260203.tar.gz -C /
sudo systemctl restart syncthing-ollama
```

## When to Reset vs. Fix

| Issue | Reset? | Why |
|-------|--------|-----|
| Stuck sync, 0% progress | Yes | State may be corrupted |
| Device won't connect | No | Just fix network/firewall |
| High CPU after weeks | Yes | Cache may have grown |
| Permission denied errors | No | Fix permissions with chmod |
| One file corrupted | No | Delete `.sync-conflict-*` |
