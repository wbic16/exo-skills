#!/bin/bash
# install-syncthing.sh
# Automated installation and basic setup of Syncthing for Ollama models
# Usage: sudo ./install-syncthing.sh [machine-name]

set -e

MACHINE_NAME="${1:-$(hostname)}"
OLLAMA_USER="ollama"
MODELS_PATH="/usr/share/ollama/.ollama/models"

echo "🔱 Syncthing Ollama Installer"
echo "Machine: $MACHINE_NAME"
echo "Models path: $MODELS_PATH"
echo ""

# Step 1: Install Syncthing
echo "[1/5] Installing Syncthing..."
apt-get update -qq
apt-get install -y -qq syncthing 2>/dev/null
syncthing --version
echo "✅ Syncthing installed"
echo ""

# Step 2: Create systemd service
echo "[2/5] Creating systemd service..."
tee /etc/systemd/system/syncthing-ollama.service > /dev/null <<EOF
[Unit]
Description=Syncthing (Ollama Models)
After=network.target

[Service]
Type=notify
User=$OLLAMA_USER
Group=$OLLAMA_USER
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
echo "✅ Systemd service created"
echo ""

# Step 3: Fix permissions on models directory
echo "[3/5] Setting permissions on models directory..."
if [ -d "$MODELS_PATH" ]; then
  chown -R $OLLAMA_USER:$OLLAMA_USER "$MODELS_PATH"
  chmod -R u+rwX,g+rX,o- "$MODELS_PATH"
  echo "✅ Permissions set"
else
  echo "⚠️  Models directory not found: $MODELS_PATH"
  echo "   Creating directory..."
  mkdir -p "$MODELS_PATH"
  chown -R $OLLAMA_USER:$OLLAMA_USER "$MODELS_PATH"
  chmod -R u+rwX,g+rX,o- "$MODELS_PATH"
  echo "✅ Directory created and permissions set"
fi
echo ""

# Step 4: Enable and start service
echo "[4/5] Starting Syncthing service..."
systemctl daemon-reload
systemctl enable syncthing-ollama
systemctl start syncthing-ollama
sleep 2
if systemctl is-active --quiet syncthing-ollama; then
  echo "✅ Service started and enabled"
else
  echo "❌ Service failed to start. Check logs:"
  systemctl status syncthing-ollama
  exit 1
fi
echo ""

# Step 5: Get device ID
echo "[5/5] Retrieving device information..."
SYNCTHING_HOME="/var/lib/syncthing"
if [ -d "$SYNCTHING_HOME" ]; then
  DEVICE_ID=$(su - $OLLAMA_USER -s /bin/bash -c "syncthing --home=$SYNCTHING_HOME --show-device" 2>/dev/null || echo "PENDING")
  if [ "$DEVICE_ID" != "PENDING" ]; then
    echo "✅ Device ID: $DEVICE_ID"
  else
    echo "⏳ Device ID will be available after first sync startup"
  fi
else
  echo "⏳ Syncthing home directory not yet initialized"
  echo "   It will be created on first startup"
fi
echo ""

echo "========================================="
echo "✅ Installation Complete"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. Access Syncthing web UI on this machine:"
echo "   ssh -L 8384:localhost:8384 user@$MACHINE_NAME"
echo "   Then open: http://localhost:8384"
echo ""
echo "2. Configure folder: /usr/share/ollama/.ollama/models"
echo "   Folder ID: ollama-models"
echo ""
echo "3. Add other ranch machines as remote devices"
echo "4. Monitor sync progress in the web UI"
echo ""
