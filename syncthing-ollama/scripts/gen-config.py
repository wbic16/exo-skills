#!/usr/bin/env python3
"""
gen-config.py
Generate Syncthing config JSON for ranch machines.
Usage: python3 gen-config.py [--output config.json]
"""

import json
import sys
from pathlib import Path

# Ranch machine definitions
MACHINES = {
    "aurora-continuum": {
        "ip": "192.168.1.101",  # Update with actual ranch IPs
        "port": 22000,
        "device_id": None,  # Will be obtained from actual Syncthing instance
    },
    "halcyon-vector": {
        "ip": "192.168.1.102",
        "port": 22000,
    },
    "logos-prime": {
        "ip": "192.168.1.103",
        "port": 22000,
    },
    "chrysalis-hub": {
        "ip": "192.168.1.104",
        "port": 22000,
    },
    "lilly": {
        "ip": "192.168.1.105",
        "port": 22000,
    },
}

MODELS_PATH = "/usr/share/ollama/.ollama/models"
FOLDER_ID = "ollama-models"

def generate_base_config():
    """Generate base Syncthing configuration."""
    return {
        "version": 31,
        "folders": [
            {
                "id": FOLDER_ID,
                "label": "ollama-models",
                "path": MODELS_PATH,
                "type": "receiveAndSend",
                "rescanIntervalS": 3600,
                "fsWatcherEnabled": True,
                "fsWatcherDelayS": 10,
                "ignorePerms": False,
                "autoNormalize": True,
                "minDiskFreePercent": 1,
                "maxConflicts": -1,
                "disableSparseFiles": False,
                "disableTempIndexes": False,
                "paused": False,
                "weakHashThresholdPct": 25,
                "markerName": ".syncthing",
                "copyOwnershipFromParent": False,
                "modTimeWindowS": 2,
                "maxConcurrentWrites": 2,
                "disableTimestamps": False,
                "trashCanPath": "",
                "trashCanCapacityMB": 0,
                "versioningFactory": "trashcan",
                "versioning": {
                    "params": {
                        "cleanupIntervalS": "3600"
                    },
                    "type": "trashcan"
                },
                "syncOwnershipFromParent": False,
                "sendOwnership": False,
                "sendStaticBlocks": False,
                "blockPullOrder": "standard",
                "pullMinLatency": 0,
                "pullMaxLatency": 0,
                "pullPause": 0,
                "pullPauseHealth": 0,
                "pullPauseHealthRatio": 0.0,
                "pullPauseHealthCustom": 0,
                "pullPauseHealthCustomTotal": 0,
                "pullFullRescan": False,
                "pullPauseS": 0,
                "pushAndPull": False,
                "scanProgressIntervalS": 0,
                "scanOwnershipInterval": 0,
                "sendCaseOnly": False,
                "caseSensitiveFS": True,
                "followSymlinks": False,
                "copyRangeMethod": "standard",
                "caseLimitUpTo": 0,
                "prepareDisabled": False,
                "skipIntegrityCheck": False,
                "skipSymlinkValidation": False,
                "restoreRecycleBinPath": "",
                "restoreRecycleBinPathMaxFiles": 0,
                "devices": [
                    {
                        "deviceID": "<DEVICE_ID>",
                        "introducedBy": "",
                        "name": machine,
                        "addresses": [
                            f"tcp://{config['ip']}:{config['port']}"
                        ],
                        "compression": "metadata",
                        "certName": "",
                        "introducer": False,
                        "skipIntroductionRemovals": False,
                        "introducedAtMs": 0,
                        "lastSeenMs": 0,
                        "statusBothFolders": "",
                        "autoAcceptFolders": False,
                        "maxRequestKiB": 0,
                        "pauseWhenInUseThreshold": 0,
                        "pauseWhenInUseGoalBytes": 0,
                        "pauseWhenInUseFraction": 0.0,
                        "actionRateLimit": 0,
                        "actionRateLimitEnablesQueue": False,
                        "ignoreDelete": False,
                        "allowedNetworks": [],
                        "discoveryServersDefault": True,
                    }
                    for machine, config in MACHINES.items()
                ],
            }
        ],
        "devices": [
            {
                "deviceID": "<DEVICE_ID>",
                "name": machine,
                "addresses": [
                    "dynamic",
                    f"tcp://{config['ip']}:{config['port']}"
                ],
                "compression": "metadata",
                "certName": "",
                "introducer": False,
                "skipIntroductionRemovals": False,
                "introducedAtMs": 0,
                "lastSeenMs": 0,
                "statusBothFolders": "",
                "autoAcceptFolders": False,
                "maxRequestKiB": 0,
                "pauseWhenInUseThreshold": 0,
                "pauseWhenInUseGoalBytes": 0,
                "pauseWhenInUseFraction": 0.0,
                "actionRateLimit": 0,
                "actionRateLimitEnablesQueue": False,
                "ignoreDelete": False,
                "allowedNetworks": [],
                "discoveryServersDefault": True,
            }
            for machine, config in MACHINES.items()
        ],
    }

def main():
    output_file = "syncthing-config.json"
    
    # Parse arguments
    for arg in sys.argv[1:]:
        if arg.startswith("--output="):
            output_file = arg.split("=")[1]
        elif arg == "--help":
            print(__doc__)
            sys.exit(0)
    
    config = generate_base_config()
    
    # Write config
    with open(output_file, "w") as f:
        json.dump(config, f, indent=2)
    
    print(f"✅ Configuration template written to: {output_file}")
    print("")
    print("⚠️  IMPORTANT:")
    print("  1. Replace <DEVICE_ID> with actual device IDs from each machine")
    print("  2. Update IP addresses to match your ranch LAN")
    print("  3. This is a template; manual web UI configuration is recommended")
    print("")

if __name__ == "__main__":
    main()
