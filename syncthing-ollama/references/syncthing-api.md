# Syncthing API Reference

For programmatic access to Syncthing, enable API in the web UI and use an API key.

## Getting an API Key

1. Open Syncthing web UI (http://localhost:8384)
2. Go to **Settings** → **API**
3. Click **Generate** to create a new API token
4. Copy the token for use in requests

## Common API Endpoints

### System Status

```bash
curl -H "X-API-Key: YOUR_API_KEY" http://localhost:8384/rest/system/status
```

Response includes: uptime, alloc, sys, hostname, version, etc.

### Folder Status

```bash
curl -H "X-API-Key: YOUR_API_KEY" http://localhost:8384/rest/db/status?folder=ollama-models
```

Response includes: `state`, `globalFiles`, `globalDirectories`, `globalDeleted`, `globalBytes`, `localFiles`, `localDirectories`, `localDeleted`, `localBytes`, `needFiles`, `needBytes`, `inSyncFiles`, `inSyncBytes`, `invalid`, `ignorePatterns`, `pullErrors`, `receivedBytes`, `publishedBytes`, `lastFile`, `lastFileDeleted`.

### Folder Completion

```bash
curl -H "X-API-Key: YOUR_API_KEY" http://localhost:8384/rest/db/completion?folder=ollama-models&device=DEVICE_ID
```

Returns percentage completion for a specific device.

### List Folders

```bash
curl -H "X-API-Key: YOUR_API_KEY" http://localhost:8384/rest/config/folders
```

### List Devices

```bash
curl -H "X-API-Key: YOUR_API_KEY" http://localhost:8384/rest/config/devices
```

### Device Statistics

```bash
curl -H "X-API-Key: YOUR_API_KEY" http://localhost:8384/rest/stats/device
```

Shows last seen time and bytes sent/received per device.

### Folder Statistics

```bash
curl -H "X-API-Key: YOUR_API_KEY" http://localhost:8384/rest/stats/folder
```

## Monitoring Script Example

```bash
#!/bin/bash
API_KEY="YOUR_API_KEY"
API_URL="http://localhost:8384"

echo "=== Syncthing Ollama Status ==="
echo ""
echo "System:"
curl -s -H "X-API-Key: $API_KEY" "$API_URL/rest/system/status" | jq '.{uptime, version, hostname}'
echo ""

echo "Folder Status:"
curl -s -H "X-API-Key: $API_KEY" "$API_URL/rest/db/status?folder=ollama-models" | jq '.{state, inSyncBytes, needBytes, globalBytes}'
echo ""

echo "Device Completion:"
for device in aurora halcyon logos chrys lilly; do
  DEVICE_ID=$(curl -s -H "X-API-Key: $API_KEY" "$API_URL/rest/config/devices" | jq -r ".[] | select(.name==\"$device\") | .deviceID")
  if [ -n "$DEVICE_ID" ]; then
    COMPLETION=$(curl -s -H "X-API-Key: $API_KEY" "$API_URL/rest/db/completion?folder=ollama-models&device=$DEVICE_ID" | jq '.completion')
    printf "  %-20s %.1f%%\n" "$device:" "$COMPLETION"
  fi
done
```

## Troubleshooting API Access

**Connection refused:**
- Verify Syncthing is running: `systemctl status syncthing-ollama`
- Check if GUI is enabled in config

**401 Unauthorized:**
- Verify API key is correct
- Regenerate key if needed in web UI

**404 Not Found:**
- Check endpoint spelling
- Verify folder ID and device ID exist
