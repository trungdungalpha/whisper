FROM ubuntu:24.04 AS fetcher
ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get -y update && apt-get -y install --no-install-recommends ca-certificates wget xz-utils curl gnupg && rm -rf /var/lib/apt/lists/*
ARG APP_URL_X64
ARG APP_URL_ARM64
RUN set -eux; \
  ARCH="$(dpkg --print-architecture)"; \
  case "$ARCH" in \
    amd64|x86_64) URL="$APP_URL_X64" ;; \
    arm64|aarch64) URL="$APP_URL_ARM64" ;; \
    *) echo "Unsupported architecture: $ARCH" >&2; exit 1 ;; \
  esac; \
  wget -q -O /tmp/app.tar.gz "$URL"; \
  mkdir -p /opt/wipter && tar -xzf /tmp/app.tar.gz -C /opt/wipter && rm -f /tmp/app.tar.gz; \
  BIN="$(find /opt/wipter -type f -name 'wipter-app*' | head -n1)"; \
  [ -n "$BIN" ] || { echo 'wipter-app binary not found'; exit 1; }; \
  chmod +x "$BIN"

FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
LABEL org.opencontainers.image.source="https://github.com/trungdungalpha/whisper"
RUN apt-get -y update && apt-get -y --no-install-recommends install tini openbox xdotool ca-certificates dbus dbus-x11 gnome-keyring libsecret-1-0 python3 python3-venv python3-pip git wget curl gnupg && rm -rf /var/lib/apt/lists/*
RUN python3 -m venv /opt/venv && /opt/venv/bin/pip install --no-cache-dir -U pip wheel websockify
RUN git clone --depth=1 https://github.com/novnc/noVNC.git /noVNC
RUN wget -q -O- https://packagecloud.io/dcommander/turbovnc/gpgkey | gpg --dearmor > /etc/apt/trusted.gpg.d/TurboVNC.gpg && \
    wget -q -O /etc/apt/sources.list.d/turbovnc.list https://raw.githubusercontent.com/TurboVNC/repo/main/TurboVNC.list && \
    apt-get -y update && apt-get -y install turbovnc libwebkit2gtk-4.1-0 && rm -rf /var/lib/apt/lists/*
RUN useradd -m -s /bin/bash wipter && mkdir -p /home/wipter/wipter && chown -R wipter:wipter /home/wipter
USER wipter
WORKDIR /home/wipter
COPY --from=fetcher /opt/wipter/ /home/wipter/wipter/
COPY --chown=wipter:wipter start.sh /home/wipter/start.sh
RUN chmod +x /home/wipter/start.sh
USER root
RUN mkdir -p /tmp/.X11-unix /run/dbus && chmod 1777 /tmp/.X11-unix && chmod 755 /run/dbus
USER wipter
EXPOSE 5900 6080
ENTRYPOINT ["/usr/bin/tini","-s","/home/wipter/start.sh"]
