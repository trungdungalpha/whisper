#!/bin/bash
set -e
[ -z "${WIPTER_EMAIL:-}" ] && { echo "Missing WIPTER_EMAIL"; exit 1; }
[ -z "${WIPTER_PASSWORD:-}" ] && { echo "Missing WIPTER_PASSWORD"; exit 1; }

eval "$(dbus-launch --sh-syntax)" || true
echo 'mypassword' | gnome-keyring-daemon --unlock --replace || true

rm -f /tmp/.X1-lock || true
rm -rf /tmp/.X11-unix || true

mkdir -p "$HOME/.vnc"
VNC_PASSWORD=${VNC_PASSWORD:-$(tr -dc 'A-Za-z0-9' </dev/urandom | head -c12)}
echo -n "$VNC_PASSWORD" | /opt/TurboVNC/bin/vncpasswd -f > "$HOME/.vnc/passwd"
chmod 400 "$HOME/.vnc/passwd"

VNC_PORT=${VNC_PORT:-5900}
WEBSOCKIFY_PORT=${WEBSOCKIFY_PORT:-6080}
WEB_ACCESS_ENABLED=${WEB_ACCESS_ENABLED:-false}

if [ "$WEB_ACCESS_ENABLED" = "true" ]; then
  /opt/TurboVNC/bin/vncserver -rfbauth "$HOME/.vnc/passwd" -geometry 1200x800 -rfbport "$VNC_PORT" -wm openbox :1
  /opt/venv/bin/websockify --web=/noVNC "$WEBSOCKIFY_PORT" localhost:"$VNC_PORT" &
else
  /opt/TurboVNC/bin/vncserver -rfbauth "$HOME/.vnc/passwd" -geometry 1200x800 -rfbport "$VNC_PORT" -wm openbox :1
fi

export DISPLAY=:1
cd "$HOME/wipter"
"$HOME/wipter/wipter-app" &
if ! [ -f "$HOME/.wipter-configured" ]; then
  for _ in $(seq 1 60); do [ "$(xdotool search --name Wipter | wc -l)" -ge 1 ] && break; sleep 2; done
  xdotool search --name Wipter | tail -n1 | xargs xdotool windowfocus || true
  sleep 2; xdotool key Tab Tab Tab; sleep 1
  xdotool type "$WIPTER_EMAIL"; sleep 1
  xdotool key Tab; sleep 1
  xdotool type "$WIPTER_PASSWORD"; sleep 1
  xdotool key Return; sleep 6
  xdotool search --name Wipter | tail -n1 | xargs xdotool windowclose || true
  touch "$HOME/.wipter-configured"
fi
fg %"$HOME/wipter/wipter-app"
