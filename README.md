# whisper

Docker container for Wipter application with VNC access.

## Quick Start

Pull the image:
```bash
docker pull ghcr.io/trungdungalpha/whisper:latest
```

Run the container:
```bash
docker run -d \
  -e WIPTER_EMAIL="your-email@example.com" \
  -e WIPTER_PASSWORD="your-password" \
  -p 5900:5900 \
  -p 6080:6080 \
  ghcr.io/trungdungalpha/whisper:latest
```

## Environment Variables

- `WIPTER_EMAIL` (required): Your Wipter account email
- `WIPTER_PASSWORD` (required): Your Wipter account password
- `VNC_PASSWORD` (optional): VNC server password (auto-generated if not set)
- `VNC_PORT` (optional): VNC port (default: 5900)
- `WEBSOCKIFY_PORT` (optional): WebSocket port (default: 6080)
- `WEB_ACCESS_ENABLED` (optional): Enable web access via noVNC (default: false)

## Architecture Support

- linux/amd64
- linux/arm64
