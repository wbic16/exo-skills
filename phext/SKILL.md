# Phext Interaction Skill

**Purpose:** Read, write, and navigate phext substrates via SQ Cloud API.

## Overview

This skill enables direct interaction with phext coordinate spaces through the SQ Cloud REST API. Phext is plain text extended to 11 dimensions - this skill lets you read scrolls, navigate the lattice, and write to coordinate spaces.

## SQ Cloud API Endpoints

### Base URLs
- **Local/Internal:** `http://aletheia-core:1337/api/v2`
- **Public:** `http://mirrorborn.us:1337/api/v2` (production)

### Endpoints

#### GET /toc
**Purpose:** Table of contents - list all scrolls at a coordinate

**Parameters:**
- `p` (required): phext filename (e.g., "index")
- `c` (optional): coordinate (default: 1.1.1/1.1.1/1.1.1)

**Example:**
```bash
curl "http://aletheia-core:1337/api/v2/toc?p=index"
```

#### GET /select
**Purpose:** Read content at a specific coordinate

**Parameters:**
- `p` (required): phext filename (e.g., "index")
- `c` (required): coordinate (e.g., "1.1.1/1.1.1/1.1.1")

**Example:**
```bash
curl "http://aletheia-core:1337/api/v2/select?p=index&c=1.1.1/1.1.1/1.1.1"
```

#### POST /write (planned)
**Purpose:** Write content to a coordinate

**Authentication:** Required (JWT bearer token)
**Status:** Awaiting R18 backend deployment

## Coordinate Format

Phext uses 9-dimensional coordinates:
```
library.shelf.series/collection.volume.book/chapter.section.scroll
```

Example coordinates:
- `1.1.1/1.1.1/1.1.1` - Origin (all existing plain text)
- `2.7.1/8.2.8/3.1.4` - Cyon's home coordinate
- `3.1.4/1.5.9/2.6.5` - Verse's home coordinate

## Usage Patterns

### Reading a Scroll
```bash
# Read from local SQ instance
curl "http://aletheia-core:1337/api/v2/select?p=index&c=1.1.1/1.1.1/1.1.1"

# Read from public SQ Cloud
curl "http://mirrorborn.us:1337/api/v2/select?p=index&c=7.7.7/8.8.8/9.9.9"
```

### Listing Available Scrolls
```bash
# Get table of contents
curl "http://aletheia-core:1337/api/v2/toc?p=index"
```

### Navigation
Coordinates are hierarchical:
- Change library → new 11D space
- Change shelf → new 10D space  
- Change scroll → new content at same higher dimensions

## Authentication (Planned)

When R18 backend is deployed:
- Magic link signup generates JWT token
- Token included as Bearer header: `Authorization: Bearer <token>`
- Each user gets isolated space: `10.10.10/[user_id]/[device_id]`

## Scripts

### read-scroll.sh
Read content from a coordinate:
```bash
./scripts/read-scroll.sh <host> <filename> <coordinate>
```

### list-scrolls.sh
List available scrolls:
```bash
./scripts/list-scrolls.sh <host> <filename>
```

## Known Working Instances

| Host | Port | Status | Notes |
|------|------|--------|-------|
| aletheia-core | 1337 | Active | Local testing (Theia's node) |
| mirrorborn.us | 1337 | Active | Production SQ Cloud |

## Examples

### Theia's First Scroll
```bash
curl "http://aletheia-core:1337/api/v2/select?p=index&c=2.7.1/8.2.8/4.5.9"
```

### Verse's First Scroll  
```bash
curl "http://mirrorborn.us:1337/api/v2/select?p=index&c=7.7.7/8.8.8/9.9.9"
```

## Integration with OpenClaw

Use `exec` tool to make API calls:
```javascript
// Read a scroll
const result = await exec({
  command: `curl -s "http://aletheia-core:1337/api/v2/select?p=index&c=1.1.1/1.1.1/1.1.1"`
});

// Parse JSON response
const data = JSON.parse(result.output);
```

## Roadmap

- [ ] Authentication via JWT tokens (R18)
- [ ] Write operations (POST /write)
- [ ] Bulk operations (POST /batch)
- [ ] WebSocket streaming (real-time updates)
- [ ] Delta sync (efficient updates)
- [ ] Phext-native search (coordinate-aware)

## Resources

- **SQ GitHub:** https://github.com/wbic16/SQ
- **libphext-rs:** https://github.com/wbic16/libphext-rs
- **libphext-node:** https://github.com/wbic16/libphext-node
- **Phext Spec:** Incipit.phext (boot artifact)

---

*Skill created 2026-02-09 by Cyon 🪶*
*Validated by Will's successful API tests on aletheia-core and mirrorborn.us*
